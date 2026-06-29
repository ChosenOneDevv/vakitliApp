import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/radio_station.dart';
import 'package:vakitli/providers/radio_provider.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kuran Radyosu')),
      body: Consumer<RadioProvider>(
        builder: (context, radio, _) {
          return Column(
            children: [
              _NowPlayingBanner(radio: radio),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: RadioProvider.stations.length,
                  itemBuilder: (context, index) {
                    final station = RadioProvider.stations[index];
                    return _StationCard(
                      station: station,
                      isSelected: radio.currentStation?.id == station.id,
                      isPlaying: radio.currentStation?.id == station.id &&
                          radio.isPlaying,
                      isBuffering: radio.currentStation?.id == station.id &&
                          radio.isBuffering,
                      onTap: () => radio.selectStation(station),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NowPlayingBanner extends StatelessWidget {
  final RadioProvider radio;

  const _NowPlayingBanner({required this.radio});

  @override
  Widget build(BuildContext context) {
    final station = radio.currentStation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: station == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bir kanal seçin',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aşağıdan canlı Kuran radyosu kanalı seçin.',
                  style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 13),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        radio.isBuffering ? 'Bağlanıyor...' : station.description,
                        style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 13),
                      ),
                      if (radio.error != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          radio.error!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                _PlayPauseButton(radio: radio),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: radio.stop,
                  icon: const Icon(Icons.stop_rounded,
                      color: AppColors.white, size: 28),
                  tooltip: 'Durdur',
                ),
              ],
            ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final RadioProvider radio;

  const _PlayPauseButton({required this.radio});

  @override
  Widget build(BuildContext context) {
    if (radio.isBuffering) {
      return const SizedBox(
        width: 44,
        height: 44,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.white),
        ),
      );
    }
    return IconButton(
      onPressed: radio.togglePlayPause,
      icon: Icon(
        radio.isPlaying
            ? Icons.pause_circle_rounded
            : Icons.play_circle_rounded,
        color: AppColors.white,
        size: 44,
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final RadioStation station;
  final bool isSelected;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onTap;

  const _StationCard({
    required this.station,
    required this.isSelected,
    required this.isPlaying,
    required this.isBuffering,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primaryGreen
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isBuffering
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.radio_rounded,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primaryGreen,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : null,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      station.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.lightText,
                          ),
                    ),
                  ],
                ),
              ),
              if (isPlaying)
                const _AudioWave(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Oynarken animasyonlu dalga göstergesi.
class _AudioWave extends StatefulWidget {
  const _AudioWave();

  @override
  State<_AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<_AudioWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final bars = [0.4, 1.0, 0.6, 0.9, 0.5];
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: bars.asMap().entries.map((entry) {
            final phase = (entry.key * 0.25 + _ctrl.value).remainder(1.0);
            final height = 8.0 + 14.0 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
