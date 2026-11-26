import 'dart:async';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SensorScreen extends StatefulWidget {
  final VoidCallback onOpenProfile;

  const SensorScreen({
    super.key,
    required this.onOpenProfile,
  });

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  static const double _gravity = 9.80665;
  static const double _shakeThresholdG = 1.65;
  static const Duration _shakeCooldown = Duration(milliseconds: 650);

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  int _shakeCount = 0;
  double _accelerationG = 0.0;
  DateTime _lastShakeTime = DateTime.fromMillisecondsSinceEpoch(0);

  double _compassDegrees = 0.0;
  double _continuousCompassDegrees = 0.0;
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  double _gyroZ = 0.0;

  @override
  void initState() {
    super.initState();
    _startSensors();
  }

  void _startSensors() {
    _accelSub = accelerometerEventStream().listen(
      (event) {
        final totalMs2 = math.sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );
        final gForce = totalMs2 / _gravity;
        final now = DateTime.now();

        if (!mounted) return;
        setState(() {
          _accelerationG = gForce;
          if (gForce >= _shakeThresholdG &&
              now.difference(_lastShakeTime) >= _shakeCooldown) {
            _shakeCount++;
            _lastShakeTime = now;
          }
        });
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _magSub = magnetometerEventStream().listen(
      (event) {
        // Compute compass heading in degrees [0, 360)
        var angle = math.atan2(event.y, event.x) * (180 / math.pi);
        angle = (angle + 360) % 360;
        if (!mounted) return;
        setState(() {
          final delta = ((angle - _compassDegrees + 540) % 360) - 180;
          _compassDegrees = angle;
          _continuousCompassDegrees += delta;
        });
      },
      onError: (_) {},
      cancelOnError: false,
    );

    _gyroSub = gyroscopeEventStream().listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _gyroX = event.x;
          _gyroY = event.y;
          _gyroZ = event.z;
        });
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _magSub?.cancel();
    _gyroSub?.cancel();
    super.dispose();
  }

  String _cardinalDirection(double deg) {
    const dirs = ['U', 'TL', 'T', 'TG', 'S', 'BD', 'B', 'BL'];
    final index = ((deg + 22.5) / 45).floor() % 8;
    return dirs[index];
  }

  String _cardinalFullName(double deg) {
    const names = [
      'Utara',
      'Timur Laut',
      'Timur',
      'Tenggara',
      'Selatan',
      'Barat Daya',
      'Barat',
      'Barat Laut',
    ];
    final index = ((deg + 22.5) / 45).floor() % 8;
    return names[index];
  }

  void _resetCounter() {
    setState(() {
      _shakeCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.user!;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
    final headingRounded = _compassDegrees.round();
    final cardinal = _cardinalDirection(_compassDegrees);

    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: Column(
        children: [
          AppTopBar(
            pageTitle: 'Sensor',
            userInitial: initial,
            avatarUrl: user.avatar,
            onAvatarTap: widget.onOpenProfile,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Penghitung Guncangan Card
                AuraCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.tertiaryTint,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.vibration_rounded,
                              color: AppTheme.primaryDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Penghitung guncangan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          StatusPillBadge(
                            label: 'Aktif',
                            backgroundColor: AppTheme.successBg,
                            foregroundColor: AppTheme.successDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_shakeCount',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Guncang ponsel untuk menambah hitungan. Satu guncangan dihitung sekali.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceBase,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              size: 16,
                              color: AppTheme.primaryDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Besar percepatan: ${_accelerationG.toStringAsFixed(2)} g',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _resetCounter,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceBase,
                          minimumSize: const Size(160, 44),
                          side: const BorderSide(color: AppTheme.border),
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: AppTheme.primaryDark,
                        ),
                        label: const Text(
                          'Reset hitungan',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Kompas Card
                AuraCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.softBlueBg,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.explore_rounded,
                              color: AppTheme.primaryDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Kompas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          StatusPillBadge(
                            label: '$headingRounded° $cardinal',
                            backgroundColor: AppTheme.tertiaryTint,
                            foregroundColor: AppTheme.primaryDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: _AnimatedCompassDial(
                          continuousDegrees: _continuousCompassDegrees,
                          headingRounded: headingRounded,
                          cardinalName: _cardinalFullName(_compassDegrees),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          'Letakkan ponsel datar agar arah lebih akurat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Giroskop Card
                AuraCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.tertiaryTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.screen_rotation_rounded,
                          color: AppTheme.primaryDark,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giroskop (rad/s)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'X ${_gyroX.toStringAsFixed(2)}  Y ${_gyroY.toStringAsFixed(2)}  Z ${_gyroZ.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _AnimatedCompassDial extends StatelessWidget {
  final double continuousDegrees;
  final int headingRounded;
  final String cardinalName;

  const _AnimatedCompassDial({
    required this.continuousDegrees,
    required this.headingRounded,
    required this.cardinalName,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: continuousDegrees),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, animatedDeg, _) {
        final rad = -animatedDeg * (math.pi / 180);
        return SizedBox(
          width: 176,
          height: 176,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0F4F8),
                      Color(0xFFF3F8FB),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Transform.rotate(
                angle: rad,
                child: CustomPaint(
                  size: const Size(156, 156),
                  painter: _CompassDialPainter(),
                ),
              ),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$headingRounded°',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cardinalName,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int deg = 0; deg < 360; deg += 15) {
      final isMajor = deg % 45 == 0;
      final isCardinal = deg % 90 == 0;
      final angle = (deg - 90) * (math.pi / 180);
      final outer = radius - 4;
      final inner = radius - (isCardinal ? 14 : (isMajor ? 10 : 7));

      final paint = Paint()
        ..color = deg == 0
            ? const Color(0xFFDC2626)
            : isCardinal
                ? AppTheme.primaryDark
                : AppTheme.textMuted.withValues(alpha: 0.45)
        ..strokeWidth = isCardinal ? 2.2 : 1.3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx + outer * math.cos(angle),
          center.dy + outer * math.sin(angle),
        ),
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        paint,
      );
    }

    final northNeedle = Path()
      ..moveTo(center.dx, center.dy - radius + 16)
      ..lineTo(center.dx - 6, center.dy - 36)
      ..lineTo(center.dx + 6, center.dy - 36)
      ..close();
    canvas.drawPath(
      northNeedle,
      Paint()..color = const Color(0xFFDC2626),
    );

    final southNeedle = Path()
      ..moveTo(center.dx, center.dy + radius - 16)
      ..lineTo(center.dx - 5, center.dy + 36)
      ..lineTo(center.dx + 5, center.dy + 36)
      ..close();
    canvas.drawPath(
      southNeedle,
      Paint()..color = AppTheme.primary.withValues(alpha: 0.45),
    );

    const labels = [
      (0, 'U', Color(0xFFDC2626)),
      (90, 'T', AppTheme.primaryDark),
      (180, 'S', AppTheme.primaryDark),
      (270, 'B', AppTheme.primaryDark),
    ];

    for (final (deg, text, color) in labels) {
      final angle = (deg - 90) * (math.pi / 180);
      final labelRadius = radius - 25;
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pos = Offset(
        center.dx + labelRadius * math.cos(angle) - tp.width / 2,
        center.dy + labelRadius * math.sin(angle) - tp.height / 2,
      );
      tp.paint(canvas, pos);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
