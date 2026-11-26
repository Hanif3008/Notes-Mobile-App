import 'package:material_ui/material_ui.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';

/// Shows the animated delete confirmation modal matching
/// `konfirmasi_hapus_catatan` & `konfirmasi_hapus_catatan_animasi_transisi`.
Future<bool> showDeleteNoteDialog(
  BuildContext context, {
  required NoteModel note,
  required String ownerName,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Hapus Catatan',
    barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _DeleteConfirmDialogContent(
        note: note,
        ownerName: ownerName,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
  return result ?? false;
}

class _DeleteConfirmDialogContent extends StatelessWidget {
  final NoteModel note;
  final String ownerName;

  const _DeleteConfirmDialogContent({
    required this.note,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
          elevation: 16,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppTheme.criticalBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: AppTheme.critical,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Hapus Catatan Ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Apakah Anda yakin ingin menghapus "${note.title}"? Tindakan ini tidak dapat dibatalkan dan data akan dihapus secara permanen.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBase,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppTheme.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MILIK ${ownerName.toUpperCase()}  •  #NOTE-${note.noteId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                  label: const Text('Ya, Hapus Catatan'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceBase,
                    foregroundColor: AppTheme.textPrimary,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Batal / Kembali'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
