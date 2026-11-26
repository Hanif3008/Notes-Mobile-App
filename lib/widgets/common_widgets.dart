import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';
import 'network_avatar_stub.dart'
    if (dart.library.js_interop) 'network_avatar_web.dart';

/// Formats raw ISO-8601 date strings into a readable Indonesian format.
String formatFriendlyDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final local = parsed.toLocal();
  final m = months[local.month - 1];
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.day} $m ${local.year}, $hh:$mm';
}

/// Modern layered app logo mark for CatatanKu.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const AppLogo({
    super.key,
    this.size = 44,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006879),
            Color(0xFF29A0B8),
            Color(0xFF6ED4E3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                  blurRadius: size * 0.4,
                  offset: Offset(0, size * 0.14),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.08,
            left: size * 0.08,
            right: size * 0.08,
            height: size * 0.38,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Icon(
            Icons.edit_note_rounded,
            color: Colors.white,
            size: size * 0.6,
          ),
          Positioned(
            right: size * 0.16,
            bottom: size * 0.16,
            child: Container(
              width: size * 0.18,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: const Color(0xFF7FE9FE),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated pop-up alert dialog for success and error feedback.
Future<void> showStatusPopupDialog(
  BuildContext context, {
  required bool isSuccess,
  required String title,
  required String message,
  String buttonText = 'OK',
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, anim, secAnim) {
      final accent = isSuccess ? AppTheme.success : AppTheme.critical;
      final bgTint = isSuccess ? AppTheme.successBg : AppTheme.criticalBg;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Material(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            elevation: 18,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: bgTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      color: accent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? AppTheme.primary : accent,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(buttonText),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, secAnim, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Displays the user's avatar from an HTTP/HTTPS URL with graceful fallback to initial.
class UserAvatarWidget extends StatelessWidget {
  final String avatarUrl;
  final String userName;
  final double size;
  final double fontSize;

  const UserAvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.userName,
    this.size = 34,
    this.fontSize = 14,
  });

  bool get _hasValidUrl {
    final trimmed = avatarUrl.trim().toLowerCase();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'U';

    Widget fallback() => Center(
          child: Text(
            initial,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
              fontSize: fontSize,
            ),
          ),
        );

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.tertiaryTint,
      ),
      child: ClipOval(
        child: _hasValidUrl
            ? buildPlatformNetworkImage(
                url: avatarUrl.trim(),
                size: size,
                fallback: fallback(),
              )
            : fallback(),
      ),
    );
  }
}

/// Top application header.
class AppTopBar extends StatelessWidget {
  final String pageTitle;
  final String userInitial;
  final String avatarUrl;
  final VoidCallback? onRefreshTap;
  final VoidCallback? onAvatarTap;

  const AppTopBar({
    super.key,
    required this.pageTitle,
    required this.userInitial,
    this.avatarUrl = '',
    this.onRefreshTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 10,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          const AppLogo(size: 36, showGlow: false),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'CATATANKU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                pageTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.15,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (onRefreshTap != null)
            IconButton(
              onPressed: onRefreshTap,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppTheme.textPrimary,
                size: 22,
              ),
              tooltip: 'Muat ulang',
            ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 1.5),
              ),
              child: UserAvatarWidget(
                avatarUrl: avatarUrl,
                userName: userInitial,
                size: 32,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Elevated white card with Aura Flow cyan-tinted ambient shadow.
class AuraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const AuraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      ),
    );
  }
}

/// Compact pill status badge used across cards and headers.
class StatusPillBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const StatusPillBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppTheme.tertiaryTint,
    this.foregroundColor = AppTheme.primaryDark,
  });

  factory StatusPillBadge.forStatus(int status) {
    if (status >= 80) {
      return StatusPillBadge(
        label: 'Selesai $status%',
        icon: Icons.check_circle_outline_rounded,
        backgroundColor: AppTheme.successBg,
        foregroundColor: AppTheme.successDark,
      );
    } else if (status >= 40) {
      return StatusPillBadge(
        label: 'Berjalan $status%',
        icon: Icons.hourglass_bottom_rounded,
        backgroundColor: AppTheme.tertiaryTint,
        foregroundColor: AppTheme.primaryDark,
      );
    }
    return StatusPillBadge(
      label: 'Aktif $status%',
      icon: Icons.bolt_rounded,
      backgroundColor: AppTheme.softBlueBg,
      foregroundColor: AppTheme.primaryDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular 40px floating icon button matching Aura Flow.
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppTheme.textPrimary,
    this.backgroundColor = AppTheme.surfaceElevated,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.borderSubtle),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
      ),
    );
  }
}
