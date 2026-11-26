import 'package:material_ui/material_ui.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import 'edit_note_screen.dart';
import 'map_screen.dart';
import 'notes_dashboard_screen.dart';
import 'profile_screen.dart';
import 'sensor_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _openEditNote([NoteModel? note]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditNoteScreen(
          note: note,
          onOpenProfile: () {
            Navigator.of(context).pop();
            setState(() => _currentIndex = 3);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      NotesDashboardScreen(
        onAddNote: () => _openEditNote(),
        onEditNote: (note) => _openEditNote(note),
        onOpenProfile: () => setState(() => _currentIndex = 3),
      ),
      MapScreen(
        onEditNote: (note) => _openEditNote(note),
        onOpenProfile: () => setState(() => _currentIndex = 3),
      ),
      SensorScreen(
        onOpenProfile: () => setState(() => _currentIndex = 3),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceElevated,
          border: Border(
            top: BorderSide(color: AppTheme.borderSubtle, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: AppTheme.surfaceElevated,
          indicatorColor: AppTheme.tertiaryTint,
          height: 64,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(
                Icons.description_rounded,
                color: AppTheme.primaryDark,
              ),
              label: 'Catatan',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(
                Icons.location_on_rounded,
                color: AppTheme.primaryDark,
              ),
              label: 'Peta',
            ),
            NavigationDestination(
              icon: Icon(Icons.sensors_outlined),
              selectedIcon: Icon(
                Icons.sensors_rounded,
                color: AppTheme.primaryDark,
              ),
              label: 'Sensor',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppTheme.primaryDark,
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
