import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';
import 'local_storage_stub.dart'
    if (dart.library.js_interop) 'local_storage_web.dart';

/// Local SQLite persistence for offline-first notes & sync queue.
/// Uses `sqflite` on mobile/native platforms and falls back to `localStorage`
/// on Flutter Web so offline mode works across all targets.
class LocalDatabaseService {
  static const String _dbName = 'notes_offline.db';
  static const String _tableName = 'notes';
  static const String _webStorageKey = 'offline_notes_db_v1';

  Database? _db;
  final List<NoteModel> _memoryFallback = [];

  Future<Database?> _getDatabase() async {
    if (kIsWeb) return null;
    if (_db != null) return _db;
    try {
      final dbPath = await getDatabasesPath();
      final fullPath = p.join(dbPath, _dbName);
      _db = await openDatabase(
        fullPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              local_id INTEGER PRIMARY KEY AUTOINCREMENT,
              note_id TEXT NOT NULL,
              user_id TEXT NOT NULL,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              latitude TEXT NOT NULL,
              longitude TEXT NOT NULL,
              status INTEGER NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              is_synced INTEGER NOT NULL DEFAULT 1,
              sync_action TEXT NOT NULL DEFAULT 'none'
            )
          ''');
        },
      );
      return _db;
    } catch (_) {
      // Fallback for environments without sqflite plugin (e.g. unit/widget tests)
      return null;
    }
  }

  List<NoteModel> _readWebOrMemory() {
    if (kIsWeb) {
      final raw = readWebStorage(_webStorageKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => NoteModel.fromLocalMap(e as Map<String, dynamic>))
          .toList();
    }
    return List<NoteModel>.from(_memoryFallback);
  }

  void _writeWebOrMemory(List<NoteModel> items) {
    if (kIsWeb) {
      final encoded = jsonEncode(
        items.map((n) => n.toLocalMap(includeLocalId: true)).toList(),
      );
      writeWebStorage(_webStorageKey, encoded);
      return;
    }
    _memoryFallback
      ..clear()
      ..addAll(items);
  }

  /// Returns all visible notes for [userId] (excluding pending deletes).
  Future<List<NoteModel>> getNotes(String userId) async {
    final db = await _getDatabase();
    if (db != null) {
      final rows = await db.query(
        _tableName,
        where: 'user_id = ? AND sync_action != ?',
        whereArgs: [userId, 'delete'],
        orderBy: 'local_id DESC',
      );
      return rows.map(NoteModel.fromLocalMap).toList();
    }

    return _readWebOrMemory()
        .where((n) => n.userId == userId && n.syncAction != 'delete')
        .toList();
  }

  /// Returns all notes for [userId] that still need to be synced to MockAPI.
  Future<List<NoteModel>> getUnsyncedNotes(String userId) async {
    final db = await _getDatabase();
    if (db != null) {
      final rows = await db.query(
        _tableName,
        where: 'user_id = ? AND is_synced = 0',
        whereArgs: [userId],
        orderBy: 'local_id ASC',
      );
      return rows.map(NoteModel.fromLocalMap).toList();
    }

    return _readWebOrMemory()
        .where((n) => n.userId == userId && !n.isSynced)
        .toList();
  }

  /// Inserts a new note into local SQLite and returns it with [localId] set.
  Future<NoteModel> insertNote(NoteModel note) async {
    final db = await _getDatabase();
    if (db != null) {
      final id = await db.insert(_tableName, note.toLocalMap());
      return note.copyWith(localId: id);
    }

    final items = _readWebOrMemory();
    final nextId = items.isEmpty
        ? 1
        : items.map((e) => e.localId ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final inserted = note.copyWith(localId: nextId);
    items.add(inserted);
    _writeWebOrMemory(items);
    return inserted;
  }

  /// Updates an existing note in local SQLite (matched by localId or noteId).
  Future<void> updateNote(NoteModel note) async {
    final db = await _getDatabase();
    if (db != null) {
      if (note.localId != null) {
        await db.update(
          _tableName,
          note.toLocalMap(),
          where: 'local_id = ?',
          whereArgs: [note.localId],
        );
      } else {
        await db.update(
          _tableName,
          note.toLocalMap(),
          where: 'user_id = ? AND note_id = ?',
          whereArgs: [note.userId, note.noteId],
        );
      }
      return;
    }

    final items = _readWebOrMemory();
    final idx = items.indexWhere((n) =>
        (note.localId != null && n.localId == note.localId) ||
        (n.userId == note.userId && n.noteId == note.noteId));
    if (idx >= 0) {
      items[idx] = note;
      _writeWebOrMemory(items);
    }
  }

  /// Permanently removes a note from local SQLite.
  Future<void> deleteNote(NoteModel note) async {
    final db = await _getDatabase();
    if (db != null) {
      if (note.localId != null) {
        await db.delete(
          _tableName,
          where: 'local_id = ?',
          whereArgs: [note.localId],
        );
      } else {
        await db.delete(
          _tableName,
          where: 'user_id = ? AND note_id = ?',
          whereArgs: [note.userId, note.noteId],
        );
      }
      return;
    }

    final items = _readWebOrMemory();
    items.removeWhere((n) =>
        (note.localId != null && n.localId == note.localId) ||
        (n.userId == note.userId && n.noteId == note.noteId));
    _writeWebOrMemory(items);
  }

  /// Replaces synced server notes for [userId] while preserving any local
  /// unsynced changes (`is_synced = 0`).
  Future<void> cacheServerNotes(
    String userId,
    List<NoteModel> serverNotes,
  ) async {
    final unsynced = await getUnsyncedNotes(userId);
    final unsyncedNoteIds = unsynced.map((n) => n.noteId).toSet();

    final db = await _getDatabase();
    if (db != null) {
      await db.transaction((txn) async {
        await txn.delete(
          _tableName,
          where: 'user_id = ? AND is_synced = 1',
          whereArgs: [userId],
        );
        for (final note in serverNotes) {
          if (unsyncedNoteIds.contains(note.noteId)) continue;
          await txn.insert(
            _tableName,
            note
                .copyWith(isSynced: true, syncAction: 'none')
                .toLocalMap(),
          );
        }
      });
      return;
    }

    final items = _readWebOrMemory();
    items.removeWhere((n) => n.userId == userId && n.isSynced);
    var nextId = items.isEmpty
        ? 1
        : items.map((e) => e.localId ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    for (final note in serverNotes) {
      if (unsyncedNoteIds.contains(note.noteId)) continue;
      items.add(
        note.copyWith(
          localId: nextId++,
          isSynced: true,
          syncAction: 'none',
        ),
      );
    }
    _writeWebOrMemory(items);
  }
}
