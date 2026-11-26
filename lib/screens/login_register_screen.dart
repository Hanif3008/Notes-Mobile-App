import 'package:material_ui/material_ui.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isRegister = false;
  bool _obscurePassword = true;

  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || password.isEmpty) {
      await showStatusPopupDialog(
        context,
        isSuccess: false,
        title: 'Data Belum Lengkap',
        message: 'Nama pengguna dan kata sandi wajib diisi sebelum melanjutkan.',
        buttonText: 'Mengerti',
      );
      return;
    }

    final state = AppStateScope.of(context);

    if (_isRegister) {
      final created = await state.authenticateRegister(
        name: name,
        avatar: _avatarController.text.trim(),
        password: password,
      );
      if (!mounted) return;
      if (created == null) {
        await showStatusPopupDialog(
          context,
          isSuccess: false,
          title: 'Pendaftaran Gagal',
          message: state.errorMessage ?? 'Gagal membuat akun baru.',
          buttonText: 'Coba Lagi',
        );
        return;
      }
      await showStatusPopupDialog(
        context,
        isSuccess: true,
        title: 'Pendaftaran Berhasil!',
        message: 'Selamat datang, ${created.name}! Akun Anda siap digunakan.',
        buttonText: 'Masuk Sekarang',
      );
      if (mounted) {
        await state.completeAuthentication(created);
      }
    } else {
      final user = await state.authenticateLogin(
        name: name,
        password: password,
      );
      if (!mounted) return;
      if (user == null) {
        await showStatusPopupDialog(
          context,
          isSuccess: false,
          title: 'Login Gagal',
          message:
              state.errorMessage ?? 'Nama pengguna atau kata sandi tidak cocok.',
          buttonText: 'Coba Lagi',
        );
        return;
      }
      await showStatusPopupDialog(
        context,
        isSuccess: true,
        title: 'Login Berhasil!',
        message: 'Selamat datang kembali, ${user.name}.',
        buttonText: 'Lanjutkan',
      );
      if (mounted) {
        await state.completeAuthentication(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(22, topPad + 18, 22, 64),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF006879),
                        Color(0xFF29A0B8),
                        Color(0xFF6ED4E3),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppLogo(size: 46, showGlow: false),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CATATANKU',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFAAEDFF),
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                Text(
                                  'Catatan Harian & Lokasi',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                setState(() => _isRegister = !_isRegister);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isRegister ? 'Masuk' : 'Daftar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text(
                        _isRegister
                            ? 'Buat Akun Baru'
                            : 'Selamat Datang\nKembali',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.16,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRegister
                            ? 'Daftarkan akun untuk mulai menyimpan catatan Anda.'
                            : 'Masuk untuk mengelola catatan dan profil Anda.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -30,
                  right: -30,
                  child: IgnorePointer(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -34),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: AuraCard(
                  borderRadius: 26,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceBase,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            _SegmentTab(
                              label: 'Masuk',
                              selected: !_isRegister,
                              onTap: () => setState(() => _isRegister = false),
                            ),
                            _SegmentTab(
                              label: 'Daftar',
                              selected: _isRegister,
                              onTap: () => setState(() => _isRegister = true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('Nama Pengguna'),
                      const SizedBox(height: 6),
                      _AuthInputField(
                        controller: _nameController,
                        hintText: 'Masukkan nama pengguna',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),

                      if (_isRegister) ...[
                        const _FieldLabel('URL Foto Avatar'),
                        const SizedBox(height: 6),
                        _AuthInputField(
                          controller: _avatarController,
                          hintText: 'https://contoh.com/foto.jpg',
                          prefixIcon: Icons.link_rounded,
                        ),
                        const SizedBox(height: 14),
                      ],

                      const _FieldLabel('Kata Sandi'),
                      const SizedBox(height: 6),
                      _AuthInputField(
                        controller: _passwordController,
                        hintText: 'Masukkan kata sandi',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),

                      const SizedBox(height: 22),

                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF006879),
                              Color(0xFF29A0B8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: const StadiumBorder(),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isRegister ? 'Buat Akun' : 'Masuk',
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegister
                        ? 'Sudah punya akun? '
                        : 'Belum punya akun? ',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isRegister = !_isRegister);
                    },
                    child: Text(
                      _isRegister ? 'Masuk' : 'Daftar Sekarang',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.primaryDark : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  const _AuthInputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 14.5,
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppTheme.surfaceBase,
        prefixIcon: Icon(prefixIcon, color: AppTheme.primaryDark, size: 20),
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: onSuffixTap,
                icon: Icon(suffixIcon, color: AppTheme.textMuted, size: 20),
              )
            : null,
      ),
    );
  }
}
