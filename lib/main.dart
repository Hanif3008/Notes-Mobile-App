import 'package:material_ui/material_ui.dart';
import 'screens/login_register_screen.dart';
import 'screens/main_shell_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UserNotesApp());
}

class UserNotesApp extends StatefulWidget {
  final AppState? appState;

  const UserNotesApp({super.key, this.appState});

  @override
  State<UserNotesApp> createState() => _UserNotesAppState();
}

class _UserNotesAppState extends State<UserNotesApp> {
  late final AppState _appState = widget.appState ?? AppState();

  @override
  void dispose() {
    if (widget.appState == null) {
      _appState.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: MaterialApp(
        title: 'User Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AnimatedBuilder(
          animation: _appState,
          builder: (context, _) {
            if (_appState.isAuthenticated) {
              return const MainShellScreen();
            }
            return const LoginRegisterScreen();
          },
        ),
      ),
    );
  }
}
