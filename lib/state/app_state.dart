import 'package:material_ui/material_ui.dart';
import '../models/note_model.dart';
import '../services/local_database_service.dart';
import '../services/mock_api_service.dart';

enum NoteFilter { all, completed, inProgress }

enum NoteSort { newest, highestStatus, title }

class SyncResult {
  final int syncedCount;
  final int failedCount;
  final String? errorMessage;

  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
    this.errorMessage,
  });

  bool get hasErrors => failedCount > 0;
}

class AppState extends ChangeNotifier {
  final MockApiService api;
  final LocalDatabaseService localDb;

  AppState({MockApiService? api, LocalDatabaseService? localDb})
      : api = api ?? MockApiService(),
        localDb = localDb ?? LocalDatabaseService();

  UserModel? _user;
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  int _pendingSyncCount = 0;
  int get pendingSyncCount => _pendingSyncCount;

  DateTime? _lastSyncAt;
  DateTime? get lastSyncAt => _lastSyncAt;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NoteFilter _filter = NoteFilter.all;
  NoteFilter get filter => _filter;

  NoteSort _sort = NoteSort.newest;
  NoteSort get sort => _sort;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<NoteModel> _notes = [];
  List<NoteModel> get allNotes => List.unmodifiable(_notes);

  List<NoteModel> get filteredNotes {
    Iterable<NoteModel> result = _notes;

    if (_filter == NoteFilter.completed) {
      result = result.where((n) => n.status > 50);
    } else if (_filter == NoteFilter.inProgress) {
      result = result.where((n) => n.status <= 50);
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.description.toLowerCase().contains(q) ||
          n.noteId.toLowerCase().contains(q));
    }

    final list = result.toList();
    list.sort((a, b) {
      switch (_sort) {
        case NoteSort.newest:
          final idA = int.tryParse(a.noteId) ?? 0;
          final idB = int.tryParse(b.noteId) ?? 0;
          return idA.compareTo(idB);
        case NoteSort.highestStatus:
          return b.status.compareTo(a.status);
        case NoteSort.title:
          return a.title.compareTo(b.title);
      }
    });
    return list;
  }

  int get totalCount => _notes.length;
  int get completedCount => _notes.where((n) => n.status > 50).length;
  int get inProgressCount => _notes.where((n) => n.status <= 50).length;

  int get averageStatus {
    if (_notes.isEmpty) return 0;
    final sum = _notes.fold<int>(0, (acc, n) => acc + n.status);
    return (sum / _notes.length).round();
  }

  void setFilter(NoteFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(NoteSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ==================== AUTH (USERS API) ====================

  Future<UserModel?> authenticateLogin({
    required String name,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final users = await api.getUsers();
      final match = users.where(
        (u) =>
            u.name.toLowerCase() == name.trim().toLowerCase() &&
            u.password == password,
      );
      if (match.isEmpty) {
        _errorMessage = 'Nama pengguna atau kata sandi tidak cocok.';
        return null;
      }
      _errorMessage = null;
      return match.first;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserModel?> authenticateRegister({
    required String name,
    required String avatar,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final created = await api.createUser(
        name: name.trim(),
        avatar: avatar.trim().isEmpty ? 'avatar 1' : avatar.trim(),
        password: password,
      );
      _errorMessage = null;
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeAuthentication(UserModel user) async {
    _user = user;
    _notes = [];
    notifyListeners();
    await fetchNotes();
  }

  Future<void> refreshUserById() async {
    final current = _user;
    if (current == null) return;
    _setLoading(true);
    try {
      _user = await api.getUserById(current.userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser({
    required String name,
    required String avatar,
    required String password,
  }) async {
    final current = _user;
    if (current == null) return false;
    _setLoading(true);
    try {
      _user = await api.updateUser(
        current.copyWith(
          name: name.trim(),
          avatar: avatar.trim(),
          password: password,
        ),
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCurrentUser() async {
    final current = _user;
    if (current == null) return false;
    _setLoading(true);
    try {
      await api.deleteUser(current.userId);
      _user = null;
      _notes = [];
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _user = null;
    _notes = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== NOTES (OFFLINE-FIRST SQLITE + MOCKAPI) ====================

  Future<void> _reloadLocalNotes(String userId) async {
    _notes = await localDb.getNotes(userId);
    final unsynced = await localDb.getUnsyncedNotes(userId);
    _pendingSyncCount = unsynced.length;
  }

  Future<void> fetchNotes() async {
    final current = _user;
    if (current == null) return;
    _setLoading(true);
    try {
      await _reloadLocalNotes(current.userId);
      notifyListeners();

      final serverNotes = await api.getNotes(current.userId);
      await localDb.cacheServerNotes(current.userId, serverNotes);
      await _reloadLocalNotes(current.userId);
      _isOffline = false;
      _lastSyncAt = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _isOffline = true;
      await _reloadLocalNotes(current.userId);
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    final current = _user;
    if (current == null) return null;
    if (noteId.startsWith('local_')) {
      final idx = _notes.indexWhere((n) => n.noteId == noteId);
      return idx >= 0 ? _notes[idx] : null;
    }
    try {
      final fresh = await api.getNoteById(
        userId: current.userId,
        noteId: noteId,
      );
      final idx = _notes.indexWhere((n) => n.noteId == noteId);
      if (idx >= 0) {
        final existing = _notes[idx];
        if (existing.isSynced) {
          final updatedLocal = fresh.copyWith(
            localId: existing.localId,
            isSynced: true,
            syncAction: 'none',
          );
          await localDb.updateNote(updatedLocal);
          _notes[idx] = updatedLocal;
          notifyListeners();
        }
      }
      return fresh;
    } catch (e) {
      final idx = _notes.indexWhere((n) => n.noteId == noteId);
      if (idx >= 0) return _notes[idx];
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createNote({
    required String title,
    required String description,
    required String latitude,
    required String longitude,
    required int status,
    bool offlineOnly = false,
  }) async {
    final current = _user;
    if (current == null) return false;
    _setLoading(true);
    final now = DateTime.now().toIso8601String();
    final localNote = NoteModel(
      noteId: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: current.userId,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      status: status,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      syncAction: 'create',
    );

    try {
      final inserted = await localDb.insertNote(localNote);
      if (offlineOnly) {
        await _reloadLocalNotes(current.userId);
        _errorMessage = null;
        return true;
      }

      try {
        final created = await api.createNote(
          userId: current.userId,
          title: title,
          description: description,
          latitude: latitude,
          longitude: longitude,
          status: status,
        );
        await localDb.updateNote(
          created.copyWith(
            localId: inserted.localId,
            isSynced: true,
            syncAction: 'none',
          ),
        );
        _isOffline = false;
        _lastSyncAt = DateTime.now();
      } catch (_) {
        _isOffline = true;
      }

      await _reloadLocalNotes(current.userId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNote(NoteModel note, {bool offlineOnly = false}) async {
    final current = _user;
    if (current == null) return false;
    _setLoading(true);
    final now = DateTime.now().toIso8601String();
    final nextAction = note.syncAction == 'create' ? 'create' : 'update';
    final localUpdated = note.copyWith(
      updatedAt: now,
      isSynced: false,
      syncAction: nextAction,
    );

    try {
      await localDb.updateNote(localUpdated);
      if (offlineOnly || nextAction == 'create') {
        await _reloadLocalNotes(current.userId);
        _errorMessage = null;
        return true;
      }

      try {
        final updated = await api.updateNote(localUpdated);
        await localDb.updateNote(
          updated.copyWith(
            localId: localUpdated.localId,
            isSynced: true,
            syncAction: 'none',
          ),
        );
        _isOffline = false;
        _lastSyncAt = DateTime.now();
      } catch (_) {
        _isOffline = true;
      }

      await _reloadLocalNotes(current.userId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteNote(String noteId) async {
    final current = _user;
    if (current == null) return false;
    _setLoading(true);
    try {
      final idx = _notes.indexWhere((n) => n.noteId == noteId);
      final target = idx >= 0 ? _notes[idx] : null;

      if (target != null && target.syncAction == 'create') {
        await localDb.deleteNote(target);
        await _reloadLocalNotes(current.userId);
        _errorMessage = null;
        return true;
      }

      if (target != null) {
        await localDb.updateNote(
          target.copyWith(isSynced: false, syncAction: 'delete'),
        );
      }

      try {
        await api.deleteNote(userId: current.userId, noteId: noteId);
        if (target != null) {
          await localDb.deleteNote(target);
        }
        _isOffline = false;
        _lastSyncAt = DateTime.now();
      } catch (_) {
        _isOffline = true;
      }

      await _reloadLocalNotes(current.userId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Synchronizes all pending local SQLite changes (create, update, delete)
  /// to MockAPI, then refreshes local cache from the server.
  Future<SyncResult> syncNotes() async {
    final current = _user;
    if (current == null) {
      return const SyncResult(syncedCount: 0, failedCount: 0);
    }

    _isSyncing = true;
    notifyListeners();

    int synced = 0;
    int failed = 0;
    String? lastError;

    try {
      final unsynced = await localDb.getUnsyncedNotes(current.userId);
      for (final note in unsynced) {
        try {
          if (note.syncAction == 'create') {
            final created = await api.createNote(
              userId: current.userId,
              title: note.title,
              description: note.description,
              latitude: note.latitude,
              longitude: note.longitude,
              status: note.status,
            );
            await localDb.updateNote(
              created.copyWith(
                localId: note.localId,
                isSynced: true,
                syncAction: 'none',
              ),
            );
          } else if (note.syncAction == 'update') {
            final updated = await api.updateNote(note);
            await localDb.updateNote(
              updated.copyWith(
                localId: note.localId,
                isSynced: true,
                syncAction: 'none',
              ),
            );
          } else if (note.syncAction == 'delete') {
            if (!note.noteId.startsWith('local_')) {
              await api.deleteNote(
                userId: current.userId,
                noteId: note.noteId,
              );
            }
            await localDb.deleteNote(note);
          }
          synced++;
        } catch (e) {
          failed++;
          lastError = e.toString();
        }
      }

      if (failed == 0) {
        try {
          final serverNotes = await api.getNotes(current.userId);
          await localDb.cacheServerNotes(current.userId, serverNotes);
          _isOffline = false;
          _lastSyncAt = DateTime.now();
          _errorMessage = null;
        } catch (e) {
          _isOffline = true;
          lastError ??= e.toString();
        }
      } else {
        _isOffline = true;
      }

      await _reloadLocalNotes(current.userId);
      return SyncResult(
        syncedCount: synced,
        failedCount: failed,
        errorMessage: lastError,
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
