import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_application_2/main.dart';
import 'package:mobile_application_2/models/note_model.dart';
import 'package:mobile_application_2/services/mock_api_service.dart';
import 'package:mobile_application_2/state/app_state.dart';

class _FakeMockApiService extends MockApiService {
  final List<NoteModel> _serverNotes = [
    const NoteModel(
      noteId: '1',
      userId: '1',
      title: 'title 1',
      description: 'description 1',
      latitude: 'latitude 1',
      longitude: 'longitude 1',
      status: 98,
      createdAt: 'created_at 1',
      updatedAt: 'updated_at 1',
    ),
  ];

  @override
  Future<List<UserModel>> getUsers() async {
    return const [
      UserModel(
        userId: '1',
        name: 'Hanif',
        avatar: 'avatar 1',
        password: 'Hanif3008',
        createdAt: 'created_at 1',
        updatedAt: 'updated_at 1',
      ),
    ];
  }

  @override
  Future<List<NoteModel>> getNotes(String userId) async {
    return List<NoteModel>.from(_serverNotes);
  }

  @override
  Future<NoteModel> createNote({
    required String userId,
    required String title,
    required String description,
    required String latitude,
    required String longitude,
    required int status,
  }) async {
    final created = NoteModel(
      noteId: '${_serverNotes.length + 1}',
      userId: userId,
      title: title,
      description: description,
      latitude: latitude,
      longitude: longitude,
      status: status,
      createdAt: 'now',
      updatedAt: 'now',
    );
    _serverNotes.add(created);
    return created;
  }
}

void main() {
  testWidgets('UserNotesApp logs in via MockAPI popup and displays Notes', (
    WidgetTester tester,
  ) async {
    final appState = AppState(api: _FakeMockApiService());
    await tester.pumpWidget(UserNotesApp(appState: appState));

    expect(find.text('Selamat Datang\nKembali'), findsOneWidget);

    // Fields start empty; enter credentials
    await tester.enterText(find.byType(TextField).at(0), 'Hanif');
    await tester.enterText(find.byType(TextField).at(1), 'Hanif3008');

    await tester.tap(find.text('Masuk').last);
    await tester.pumpAndSettle();

    // Success popup is displayed
    expect(find.text('Login Berhasil!'), findsOneWidget);
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Hanif 👋'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('title 1'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('title 1'), findsOneWidget);
    expect(find.text('description 1'), findsOneWidget);
  });

  test('AppState saves note offline and syncs to MockAPI', () async {
    final fakeApi = _FakeMockApiService();
    final appState = AppState(api: fakeApi);
    final user = (await fakeApi.getUsers()).first;
    await appState.completeAuthentication(user);

    final ok = await appState.createNote(
      title: 'Catatan Offline',
      description: 'Isi offline',
      latitude: '-6.2088',
      longitude: '106.8456',
      status: 50,
      offlineOnly: true,
    );

    expect(ok, isTrue);
    expect(appState.pendingSyncCount, 1);
    expect(
      appState.allNotes.any((n) => n.title == 'Catatan Offline' && !n.isSynced),
      isTrue,
    );

    final result = await appState.syncNotes();
    expect(result.syncedCount, 1);
    expect(result.failedCount, 0);
    expect(appState.pendingSyncCount, 0);
    expect(
      appState.allNotes.any((n) => n.title == 'Catatan Offline' && n.isSynced),
      isTrue,
    );
  });
}
