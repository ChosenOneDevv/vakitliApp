import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/alarm_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/widgets/countdown_timer.dart';
import 'package:vakitli/widgets/islamic_pattern.dart';
import 'package:vakitli/widgets/prayer_card.dart';
import 'package:vakitli/screens/alarm/alarm_settings_screen.dart';
import 'package:vakitli/screens/location/city_selection_screen.dart';
import 'package:vakitli/screens/duas/duas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Vakitli',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.darkGreen,
                          AppColors.primaryGreen,
                        ],
                      ),
                    ),
                    child: const IslamicPatternDecoration(
                      color: AppColors.gold,
                      opacity: 0.12,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.auto_stories_outlined),
                    tooltip: 'Dualar',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DuasScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AlarmSettingsScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => provider.fetchTodayPrayerTimes(),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _buildBody(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrayerProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.lightText),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => provider.fetchTodayPrayerTimes(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (provider.todayPrayer == null) {
      return const SizedBox.shrink();
    }

    final prayer = provider.todayPrayer!;
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(now);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çevrimdışı uyarısı (kayıtlı vakitler gösteriliyor)
          if (provider.isOffline) ...[
            _buildOfflineBanner(context),
            const SizedBox(height: 12),
          ],

          // Tarih bilgisi
          _buildDateHeader(context, formattedDate, prayer.hijriFormatted),
          const SizedBox(height: 12),

          // Konum bilgisi
          _buildLocationChip(context, provider.locationName),
          const SizedBox(height: 16),

          // Geri sayım — saniyede bir rebuild olduğu için RepaintBoundary ile
          // izole edilir; aksi halde tüm vakit kartları/gradient her saniye
          // yeniden boyanır.
          if (provider.nextPrayer != null && provider.nextPrayerTime != null)
            RepaintBoundary(
              child: CountdownTimer(
                prayerName: provider.nextPrayer!.name,
                targetTime: provider.nextPrayerTime!,
              ),
            ),
          const SizedBox(height: 20),

          // Vakit listesi başlığı
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 20, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                'Günlük Vakitler',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Namaz vakitleri kartları
          ...() {
            final alarmProvider = context.watch<AlarmProvider>();
            return prayer.entries.map((entry) {
              final isNext = provider.nextPrayer?.name == entry.name;
              final alarmSetting = alarmProvider.getSetting(entry.icon);
              return PrayerCard(
                entry: entry,
                isNext: isNext,
                alarmSetting: alarmSetting,
              );
            });
          }(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Çevrimdışısınız — kayıtlı vakitler gösteriliyor.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String gregorian, String hijri) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gregorian,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hijri,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
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

  Widget _buildLocationChip(BuildContext context, String locationName) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.navy),
                const SizedBox(width: 4),
                Text(
                  locationName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit_rounded, size: 12, color: AppColors.navy),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
