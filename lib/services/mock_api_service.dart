import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_model.dart';

class MockApiException implements Exception {
  final String message;
  const MockApiException(this.message);

  @override
  String toString() => message;
}

class MockApiService {
  static const String baseUrl = 'https://6b07948e58419b87a4385759.mockapi.io';

  final http.Client _client;

  MockApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ==================== USERS CRUD & GET BY ID ====================

  Future<List<UserModel>> getUsers() async {
    final res = await _client.get(Uri.parse('$baseUrl/users'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException('Gagal memuat data pengguna (${res.statusCode})');
    }
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> getUserById(String userId) async {
    final res = await _client.get(Uri.parse('$baseUrl/users/$userId'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException(
        'Gagal memuat user #$userId (${res.statusCode})',
      );
    }
    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<UserModel> createUser({
    required String name,
    required String avatar,
    required String password,
  }) async {
    final now = DateTime.now().toIso8601String();
    final res = await _client.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'avatar': avatar,
        'password': password,
        'created_at': now,
        'updated_at': now,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException('Gagal mendaftarkan user (${res.statusCode})');
    }
    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<UserModel> updateUser(UserModel user) async {
    final now = DateTime.now().toIso8601String();
    final res = await _client.put(
      Uri.parse('$baseUrl/users/${user.userId}'),
      headers: _headers,
      body: jsonEncode({
        'name': user.name,
        'avatar': user.avatar,
        'password': user.password,
        'updated_at': now,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException('Gagal memperbarui user (${res.statusCode})');
    }
    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteUser(String userId) async {
    final res = await _client.delete(Uri.parse('$baseUrl/users/$userId'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException('Gagal menghapus user (${res.statusCode})');
    }
  }

  // ==================== NOTES CRUD & GET BY ID ====================

  Future<List<NoteModel>> getNotes(String userId) async {
    final res = await _client.get(Uri.parse('$baseUrl/users/$userId/notes'));
    if (res.statusCode == 404) {
      return [];
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException('Gagal memuat catatan (${res.statusCode})');
    }
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NoteModel> getNoteById({
    required String userId,
    required String noteId,
  }) async {
    final res = await _client.get(
      Uri.parse('$baseUrl/users/$userId/notes/$noteId'),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException(
        'Gagal memuat detail catatan #$noteId (${res.statusCode})',
      );
    }
    return NoteModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String description,
    required String latitude,
    required String longitude,
    required int status,
  }) async {
    final now = DateTime.now().toIso8601String();
    final res = await _client.post(
      Uri.parse('$baseUrl/users/$userId/notes'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'created_at': now,
        'updated_at': now,
        'userId': userId,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException('Gagal membuat catatan (${res.statusCode})');
    }
    return NoteModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<NoteModel> updateNote(NoteModel note) async {
    final now = DateTime.now().toIso8601String();
    final res = await _client.put(
      Uri.parse('$baseUrl/users/${note.userId}/notes/${note.noteId}'),
      headers: _headers,
      body: jsonEncode({
        'title': note.title,
        'description': note.description,
        'latitude': note.latitude,
        'longitude': note.longitude,
        'status': note.status,
        'updated_at': now,
        'userId': note.userId,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException(
        'Gagal memperbarui catatan #${note.noteId} (${res.statusCode})',
      );
    }
    return NoteModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    final res = await _client.delete(
      Uri.parse('$baseUrl/users/$userId/notes/$noteId'),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MockApiException(
        'Gagal menghapus catatan #$noteId (${res.statusCode})',
      );
    }
  }
}
