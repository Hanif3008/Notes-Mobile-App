import 'package:material_ui/material_ui.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showPassword = false;

  Future<void> _editProfileDialog() async {
    final state = AppStateScope.of(context);
    final user = state.user!;
    final nameCtrl = TextEditingController(text: user.name);
    final avatarCtrl = TextEditingController(text: user.avatar);
    final passCtrl = TextEditingController(text: user.password);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: avatarCtrl,
              decoration: const InputDecoration(
                labelText: 'URL Foto Avatar',
                hintText: 'https://contoh.com/foto.jpg',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Kata Sandi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(minimumSize: const Size(96, 40)),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      await state.updateUser(
        name: nameCtrl.text,
        avatar: avatarCtrl.text,
        password: passCtrl.text,
      );
    }

    nameCtrl.dispose();
    avatarCtrl.dispose();
    passCtrl.dispose();
  }

  Future<void> _confirmDeleteUser() async {
    final state = AppStateScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text(
          'Akun Anda akan dihapus secara permanen dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.critical,
              minimumSize: const Size(96, 40),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await state.deleteCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.user!;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: Column(
        children: [
          AppTopBar(
            pageTitle: 'Profil Saya',
            userInitial: initial,
            avatarUrl: user.avatar,
            onRefreshTap: () => state.refreshUserById(),
          ),
          if (state.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppTheme.primary,
              backgroundColor: AppTheme.tertiaryTint,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: state.refreshUserById,
              color: AppTheme.primary,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.atmosphericGradient,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'ID #${user.userId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_outlined,
                                    size: 14,
                                    color: AppTheme.primaryDark,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Akun Aktif',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: AppTheme.floatingShadow,
                          ),
                          child: UserAvatarWidget(
                            avatarUrl: user.avatar,
                            userName: user.name,
                            size: 82,
                            fontSize: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Terdaftar: ${formatFriendlyDate(user.createdAt)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Row(
                      children: [
                        _ProfileStatCard(
                          icon: Icons.description_outlined,
                          value: '${state.totalCount}',
                          label: 'Total Catatan',
                        ),
                        const SizedBox(width: 10),
                        _ProfileStatCard(
                          icon: Icons.donut_large_rounded,
                          value: '${state.averageStatus}%',
                          label: 'Rata-rata Progres',
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AuraCard(
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Data Akun',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'PROFIL PRIBADI',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _AccountDataRow(
                            icon: Icons.badge_outlined,
                            label: 'Nama Lengkap',
                            value: user.name,
                            trailing: IconButton(
                              onPressed: _editProfileDialog,
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AccountDataRow(
                            icon: Icons.link_rounded,
                            label: 'URL Foto Avatar',
                            value: user.avatar,
                            trailing: const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 10),
                          _AccountDataRow(
                            icon: Icons.fingerprint_rounded,
                            label: 'ID Pengguna',
                            value: user.userId,
                            trailing: const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 10),
                          _AccountDataRow(
                            icon: Icons.lock_outline_rounded,
                            label: 'Kata Sandi',
                            value: _showPassword ? user.password : '••••••••',
                            trailing: IconButton(
                              onPressed: () {
                                setState(() => _showPassword = !_showPassword);
                              },
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _editProfileDialog,
                          icon: const Icon(Icons.edit_outlined, size: 19),
                          label: const Text('Ubah Profil'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _confirmDeleteUser,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.critical,
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                          ),
                          label: const Text('Hapus Akun'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: state.logout,
                          icon: const Icon(Icons.logout_rounded, size: 19),
                          label: const Text('Keluar Akun'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProfileStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AuraCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        borderRadius: 18,
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.tertiaryTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: AppTheme.primaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget trailing;

  const _AccountDataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBase,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
