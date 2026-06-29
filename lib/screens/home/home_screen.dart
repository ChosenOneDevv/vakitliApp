import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/hadith.dart';
import 'package:vakitli/models/prayer_log.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/providers/alarm_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/providers/tracker_provider.dart';
import 'package:vakitli/services/hadith_service.dart';
import 'package:vakitli/widgets/countdown_timer.dart';
import 'package:vakitli/widgets/prayer_card.dart';
import 'package:vakitli/screens/alarm/alarm_settings_screen.dart';
import 'package:vakitli/screens/hadith/hadith_screen.dart';
import 'package:vakitli/screens/location/city_selection_screen.dart';
import 'package:vakitli/screens/duas/duas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HadithService _hadithService = HadithService();
  String? _lastPrayerKey;
  Future<Hadith?>? _hadithFuture;

  PrayerEntry? _currentPrayer(PrayerProvider provider) {
    final today = provider.todayPrayer;
    final next = provider.nextPrayer;
    if (today == null || next == null) return null;
    final entries = today.entries;
    final idx = entries.indexWhere((e) => e.name == next.name);
    if (idx <= 0) return null;
    return entries[idx - 1];
  }

  void _updateHadith(String prayerKey) {
    if (prayerKey != _lastPrayerKey) {
      _lastPrayerKey = prayerKey;
      setState(() {
        _hadithFuture = _hadithService.getHadithForPrayer(prayerKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vakitli'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_stories_outlined),
            tooltip: 'Dualar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DuasScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AlarmSettingsScreen()),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () =>
                  context.read<PrayerProvider>().fetchTodayPrayerTimes(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) => _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrayerProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.lightText),
            const SizedBox(height: 16),
            Text(provider.error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
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

    if (provider.todayPrayer == null) return const SizedBox.shrink();

    final prayer = provider.todayPrayer!;
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(now);
    final currentPrayer = _currentPrayer(provider);
    final prayerKey = currentPrayer?.icon ?? 'fajr';

    _updateHadith(prayerKey);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (provider.isOffline) ...[
          _offlineBanner(context),
          const SizedBox(height: 14),
        ],
        _dateLocationRow(context, provider, formattedDate, prayer.hijriFormatted),
        const SizedBox(height: 16),
        if (currentPrayer != null &&
            PrayerLog.prayerKeys.contains(currentPrayer.icon))
          _VaktindeKilBanner(prayerEntry: currentPrayer),
        if (provider.nextPrayer != null && provider.nextPrayerTime != null)
          RepaintBoundary(
            child: CountdownTimer(
              prayerName: provider.nextPrayer!.name,
              targetTime: provider.nextPrayerTime!,
              progress: _progress(provider),
            ),
          ),
        const SizedBox(height: 16),
        if (_hadithFuture != null)
          _VaktinHadisiCard(hadithFuture: _hadithFuture!),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Bugünün Vakitleri',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        _prayerList(context, provider, prayer),
      ],
    );
  }

  double _progress(PrayerProvider provider) {
    final next = provider.nextPrayer;
    final nextTime = provider.nextPrayerTime;
    final today = provider.todayPrayer;
    if (next == null || nextTime == null || today == null) return 0;

    final now = DateTime.now();
    final entries = today.entries;
    final idx = entries.indexWhere((e) => e.name == next.name);
    DateTime prevTime = (idx > 0 ? entries[idx - 1] : entries.last).timeOn(now);
    if (prevTime.isAfter(nextTime)) {
      prevTime = prevTime.subtract(const Duration(days: 1));
    }
    final span = nextTime.difference(prevTime).inSeconds;
    if (span <= 0) return 0;
    return now.difference(prevTime).inSeconds / span;
  }

  Widget _prayerList(
      BuildContext context, PrayerProvider provider, prayer) {
    final entries = prayer.entries;
    final alarmProvider = context.watch<AlarmProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          children: [
            for (int i = 0; i < entries.length; i++) ...[
              PrayerCard(
                entry: entries[i],
                isNext: provider.nextPrayer?.name == entries[i].name,
                alarmSetting: alarmProvider.getSetting(entries[i].icon),
              ),
              if (i != entries.length - 1)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 46,
                  endIndent: 14,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dateLocationRow(BuildContext context, PrayerProvider provider,
      String gregorian, String hijri) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gregorian,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(hijri,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      )),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 15, color: AppColors.primaryGreen),
                const SizedBox(width: 5),
                Text(
                  provider.locationName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _offlineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Çevrimdışısınız — kayıtlı vakitler gösteriliyor.',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _VaktindeKilBanner extends StatelessWidget {
  final PrayerEntry prayerEntry;

  const _VaktindeKilBanner({required this.prayerEntry});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackerProvider>(
      builder: (context, tracker, _) {
        final isDone = tracker.todayLog.isDone(prayerEntry.icon);
        if (isDone) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () async {
            await context.read<TrackerProvider>().togglePrayer(prayerEntry.icon);
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${prayerEntry.name} vaktindesin — kılmak için dokun',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white70, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VaktinHadisiCard extends StatelessWidget {
  final Future<Hadith?> hadithFuture;

  const _VaktinHadisiCard({required this.hadithFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Hadith?>(
      future: hadithFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final hadith = snapshot.data!;
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HadithScreen()),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        size: 15, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      'Vaktin Hadisi',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.gold),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hadith.text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hadith.source.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    hadith.source,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
