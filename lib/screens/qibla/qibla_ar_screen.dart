import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/providers/qibla_provider.dart';

class QiblaArScreen extends StatefulWidget {
  const QiblaArScreen({super.key});

  @override
  State<QiblaArScreen> createState() => _QiblaArScreenState();
}

class _QiblaArScreenState extends State<QiblaArScreen> {
  CameraController? _camera;
  QiblaProvider? _qibla;
  String? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _qibla = QiblaProvider();
    final prayer = context.read<PrayerProvider>();
    _qibla!.initialize(prayer.latitude, prayer.longitude);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Kamera bulunamadı.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _camera = controller;
        _ready = true;
      });
    } catch (e) {
      setState(() => _error = 'Kamera açılamadı. İzin verildiğinden emin olun.');
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    _qibla?.dispose();
    super.dispose();
  }

  /// -180..180 normalize edilmiş kıble açısı.
  double _normalized(double angle) {
    var a = angle % 360;
    if (a > 180) a -= 360;
    if (a < -180) a += 360;
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kıble (AR)'),
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        foregroundColor: AppColors.white,
      ),
      extendBodyBehindAppBar: true,
      body: _error != null
          ? _errorView(_error!)
          : !_ready
              ? Center(
                  child:
                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
              : ChangeNotifierProvider.value(
                  value: _qibla!,
                  child: Consumer<QiblaProvider>(
                    builder: (context, qibla, child) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(_camera!),
                          _overlay(qibla),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _overlay(QiblaProvider qibla) {
    final angle = _normalized(qibla.qiblaAngle);
    final aligned = angle.abs() < 10;
    final color = aligned ? Theme.of(context).colorScheme.primaryContainer : AppColors.gold;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Yön oku — telefon kıbleye dönünce yukarı bakar.
        Transform.rotate(
          angle: angle * math.pi / 180,
          child: Icon(Icons.navigation_rounded, size: 140, color: color),
        ),
        Positioned(
          bottom: 60,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  aligned ? 'Kıbleye dönüksünüz ✓' : 'Telefonu oku takip ederek çevirin',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: aligned ? Theme.of(context).colorScheme.primaryContainer : AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  qibla.compassHeading == null
                      ? 'Pusula verisi bekleniyor...'
                      : 'Kıble: ${qibla.formattedQiblaDirection} • Sapma: ${angle.abs().toStringAsFixed(0)}°',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.lightGold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_rounded,
                size: 56, color: AppColors.lightText),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}
