import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/radio_provider.dart';
import 'package:vakitli/screens/radio/radio_screen.dart';

class RadioMiniPlayer extends StatelessWidget {
  const RadioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radio, _) {
        if (!radio.hasStation) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RadioScreen()),
          ),
          child: Container(
            height: 56,
            color: AppColors.darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.radio_rounded,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        radio.currentStation!.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        radio.isBuffering
                            ? 'Bağlanıyor...'
                            : radio.isPlaying
                                ? 'Canlı yayın'
                                : 'Duraklatıldı',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (radio.isBuffering)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                else
                  IconButton(
                    onPressed: radio.togglePlayPause,
                    icon: Icon(
                      radio.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.white,
                    ),
                  ),
                IconButton(
                  onPressed: radio.stop,
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.white, size: 20),
                  tooltip: 'Kapat',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
