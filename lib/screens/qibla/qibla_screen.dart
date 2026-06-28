import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/location_provider.dart';
import 'package:vakitli/providers/qibla_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  QiblaProvider? _qiblaProvider;

  @override
  void initState() {
    super.initState();
    _qiblaProvider = QiblaProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initQibla();
    });
  }

  void _initQibla() {
    final locProvider = context.read<LocationProvider>();
    final loc = locProvider.currentLocation;
    if (loc != null) {
      _qiblaProvider!.initialize(loc.latitude, loc.longitude);
    } else {
      // İstanbul varsayılan
      _qiblaProvider!.initialize(41.0082, 28.9784);
    }
  }

  @override
  void dispose() {
    _qiblaProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _qiblaProvider!,
      child: Scaffold(
        appBar: AppBar(title: const Text('Kıble Pusulası')),
        body: Consumer<QiblaProvider>(
          builder: (context, provider, _) {
            if (!provider.initialized) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (provider.error != null) {
              return _buildError(context, provider.error!);
            }

            return _buildCompass(context, provider);
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sensors_off_rounded, size: 64, color: AppColors.lightText),
            const SizedBox(height: 16),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Yine de Kıble açısını göster
            Consumer<QiblaProvider>(
              builder: (context, provider, _) => Text(
                'Kıble yönü: ${provider.formattedQiblaDirection}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryGreen,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(BuildContext context, QiblaProvider provider) {
    final size = MediaQuery.of(context).size;
    final compassSize = size.width * 0.75;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Bilgi kartı
            _buildInfoCard(context, provider),
            const SizedBox(height: 24),

            // Pusula
            SizedBox(
              width: compassSize,
              height: compassSize,
              child: _CompassWidget(
                compassHeading: provider.compassHeading ?? 0,
                qiblaDirection: provider.qiblaDirection,
              ),
            ),
            const SizedBox(height: 24),

            // Alt bilgi
            _buildBottomInfo(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, QiblaProvider provider) {
    final locProvider = context.watch<LocationProvider>();
    final cityName = locProvider.currentLocation?.cityName ?? 'Bilinmiyor';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.mosque_rounded, color: AppColors.primaryGreen, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kâbe Yönü',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$cityName → ${provider.formattedQiblaDirection}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                provider.formattedDistance,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'mesafe',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context, QiblaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pusulayı düz bir yüzeyde tutun ve manyetik alanlardan uzak durun. Yeşil ok Kıble yönünü gösterir.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassWidget extends StatelessWidget {
  final double compassHeading;
  final double qiblaDirection;

  const _CompassWidget({
    required this.compassHeading,
    required this.qiblaDirection,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CompassPainter(
        heading: compassHeading,
        qiblaAngle: qiblaDirection,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final double qiblaAngle;

  _CompassPainter({required this.heading, required this.qiblaAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Arka plan dairesi
    final bgPaint = Paint()
      ..color = AppColors.cream
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Dış çerçeve
    final borderPaint = Paint()
      ..color = AppColors.darkCream
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // İç dekoratif daireler
    final innerBorderPaint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.85, innerBorderPaint);
    canvas.drawCircle(center, radius * 0.45, innerBorderPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);

    // Yön çizgileri ve etiketleri
    _drawDirectionMarks(canvas, radius);
    _drawCardinalLabels(canvas, radius);

    // Kıble oku
    _drawQiblaArrow(canvas, radius);

    canvas.restore();

    // Ortadaki sabit nokta
    final centerDotPaint = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerDotPaint);

    // Kuzey göstergesi (üstte sabit kırmızı üçgen)
    _drawNorthIndicator(canvas, center, radius);
  }

  void _drawDirectionMarks(Canvas canvas, double radius) {
    for (int i = 0; i < 360; i += 5) {
      final angle = i * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      final isMinor = i % 15 == 0;

      double startR;
      double strokeWidth;
      Color color;

      if (isCardinal) {
        startR = radius * 0.7;
        strokeWidth = 2.5;
        color = AppColors.navy;
      } else if (isMajor) {
        startR = radius * 0.75;
        strokeWidth = 1.5;
        color = AppColors.darkText;
      } else if (isMinor) {
        startR = radius * 0.8;
        strokeWidth = 1;
        color = AppColors.lightText;
      } else {
        startR = radius * 0.85;
        strokeWidth = 0.5;
        color = AppColors.darkCream;
      }

      final endR = radius * 0.88;
      final start = Offset(startR * math.sin(angle), -startR * math.cos(angle));
      final end = Offset(endR * math.sin(angle), -endR * math.cos(angle));

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCardinalLabels(Canvas canvas, double radius) {
    final labels = {'K': 0.0, 'D': 90.0, 'G': 180.0, 'B': 270.0};
    final labelColors = {
      'K': const Color(0xFFC62828),
      'D': AppColors.navy,
      'G': AppColors.navy,
      'B': AppColors.navy,
    };

    for (final entry in labels.entries) {
      final angle = entry.value * math.pi / 180;
      final labelR = radius * 0.62;
      final offset = Offset(labelR * math.sin(angle), -labelR * math.cos(angle));

      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: labelColors[entry.key],
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(heading * math.pi / 180);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  void _drawQiblaArrow(Canvas canvas, double radius) {
    final angle = qiblaAngle * math.pi / 180;

    canvas.save();
    canvas.rotate(angle);

    // Ok gövdesi
    final arrowPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, -radius * 0.42),
      arrowPaint,
    );

    // Ok ucu
    final arrowHeadPath = Path()
      ..moveTo(0, -radius * 0.55)
      ..lineTo(-10, -radius * 0.38)
      ..lineTo(10, -radius * 0.38)
      ..close();
    canvas.drawPath(
      arrowHeadPath,
      Paint()
        ..color = AppColors.primaryGreen
        ..style = PaintingStyle.fill,
    );

    // Kabe ikonu (küçük kare)
    final kaabaRect = Rect.fromCenter(
      center: Offset(0, -radius * 0.55 - 14),
      width: 18,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaabaRect, const Radius.circular(3)),
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaabaRect, const Radius.circular(3)),
      Paint()
        ..color = AppColors.primaryGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  void _drawNorthIndicator(Canvas canvas, Offset center, double radius) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius - 6)
      ..lineTo(center.dx - 8, center.dy - radius + 8)
      ..lineTo(center.dx + 8, center.dy - radius + 8)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC62828)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.qiblaAngle != qiblaAngle;
  }
}
