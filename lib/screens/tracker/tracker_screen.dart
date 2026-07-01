import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/prayer_log.dart';
import 'package:vakitli/providers/tracker_provider.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Namaz Takip')),
      body: Consumer<TrackerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StreakCard(streak: provider.streak),
              const SizedBox(height: 16),
              _TodayCard(log: provider.todayLog, provider: provider),
              const SizedBox(height: 16),
              _WeeklyCard(summary: provider.weeklySummary),
              const SizedBox(height: 16),
              _StatsRow(
                monthly: provider.monthlyCompleted,
                total: provider.totalCompleted,
              ),
              const SizedBox(height: 16),
              _HeatmapCard(days: provider.lastDays(35)),
              const SizedBox(height: 16),
              _AchievementsCard(provider: provider),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: AppColors.lightGold, size: 40),
          const SizedBox(height: 8),
          Text(
            '$streak gün',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ardışık tam gün serisi',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.lightGold),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final PrayerLog log;
  final TrackerProvider provider;

  const _TodayCard({required this.log, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.today_rounded,
                      size: 20, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text('Bugün', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '${log.completedCount}/${PrayerLog.prayerKeys.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...PrayerLog.prayerKeys.map((key) {
              final done = log.isDone(key);
              final jamaah = log.isJamaah(key);
              return InkWell(
                onTap: () => provider.togglePrayer(key),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color:
                            done ? Theme.of(context).colorScheme.primary : AppColors.lightText,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          PrayerLog.prayerNames[key]!,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: done
                                        ? Theme.of(context).colorScheme.onSurface
                                        : AppColors.lightText,
                                    fontWeight: done
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                      // Cemaat işareti — sadece kılındıysa aktif.
                      IconButton(
                        tooltip: 'Cemaatle',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          jamaah ? Icons.mosque_rounded : Icons.mosque_outlined,
                          size: 20,
                          color: jamaah
                              ? AppColors.gold
                              : (done
                                  ? AppColors.lightText
                                  : AppColors.lightText.withValues(alpha: 0.3)),
                        ),
                        onPressed:
                            done ? () => provider.toggleJamaah(key) : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final List<DaySummary> summary;

  const _WeeklyCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('E', 'tr_TR');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    size: 20, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('Son 7 Gün',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: summary.map((day) {
                  final ratio = day.total == 0 ? 0.0 : day.completed / day.total;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${day.completed}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 80 * ratio + 4,
                          decoration: BoxDecoration(
                            color: ratio == 1.0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primaryContainer
                                    .withValues(alpha: 0.4 + ratio * 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayFormat.format(day.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int monthly;
  final int total;

  const _StatsRow({required this.monthly, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Bu Ay',
            value: '$monthly',
            icon: Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            label: 'Toplam',
            value: '$total',
            icon: Icons.mosque_rounded,
          ),
        ),
      ],
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  final List<DaySummary> days;

  const _HeatmapCard({required this.days});

  Color _cellColor(BuildContext context, int completed) {
    if (completed == 0) return AppColors.lightText.withValues(alpha: 0.15);
    final ratio = completed / 5;
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.25 + ratio * 0.6);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view_rounded,
                    size: 20, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('Son 5 Hafta',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: days
                  .map((d) => Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _cellColor(context, d.completed),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final TrackerProvider provider;

  const _AchievementsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final badges = <_Badge>[
      _Badge(Icons.flag_rounded, 'İlk Adım', provider.totalCompleted >= 1),
      _Badge(Icons.local_fire_department_rounded, '7 Gün Seri',
          provider.streak >= 7),
      _Badge(
          Icons.calendar_month_rounded, '30 Gün Seri', provider.streak >= 30),
      _Badge(Icons.workspace_premium_rounded, '100 Namaz',
          provider.totalCompleted >= 100),
      _Badge(Icons.mosque_rounded, 'Cemaat (10)', provider.totalJamaah >= 10),
      _Badge(Icons.verified_rounded, 'Tam Gün', provider.fullDaysCount >= 1),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 20, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('Başarımlar',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: badges.map((b) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: b.unlocked
                            ? AppColors.gold.withValues(alpha: 0.18)
                            : AppColors.lightText.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        b.icon,
                        color: b.unlocked ? AppColors.gold : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 64,
                      child: Text(
                        b.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: b.unlocked
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.lightText,
                            ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge {
  final IconData icon;
  final String label;
  final bool unlocked;
  const _Badge(this.icon, this.label, this.unlocked);
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
