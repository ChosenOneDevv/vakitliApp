import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/providers/fasting_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/services/api_service.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramazan'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          indicatorColor: AppColors.gold,
          tabs: const [
            Tab(text: 'Bugün'),
            Tab(text: 'İmsakiye'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BugunTab(),
          _ImsakiyeTab(),
        ],
      ),
    );
  }
}

class _BugunTab extends StatelessWidget {
  const _BugunTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, prayer, child) {
        final today = prayer.todayPrayer;
        if (today == null) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          );
        }

        final now = DateTime.now();
        final imsak = today.entries.firstWhere((e) => e.icon == 'fajr');
        final iftar = today.entries.firstWhere((e) => e.icon == 'maghrib');
        final imsakDt = imsak.timeOn(now);
        final iftarDt = iftar.timeOn(now);

        String label;
        DateTime target;
        if (now.isBefore(imsakDt)) {
          label = 'Sahura (İmsak) Kalan';
          target = imsakDt;
        } else if (now.isBefore(iftarDt)) {
          label = 'İftara Kalan';
          target = iftarDt;
        } else {
          label = 'Sahura (İmsak) Kalan';
          final tImsak = prayer.tomorrowPrayer?.entries
              .firstWhere((e) => e.icon == 'fajr');
          target = tImsak?.timeOn(now.add(const Duration(days: 1))) ??
              imsakDt.add(const Duration(days: 1));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CountdownCard(label: label, target: target),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TimeCard(
                    title: 'Sahur (İmsak)',
                    time: imsak.time,
                    icon: Icons.bedtime_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeCard(
                    title: 'İftar (Akşam)',
                    time: iftar.time,
                    icon: Icons.restaurant_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _FastingCard(),
          ],
        );
      },
    );
  }
}

class _ImsakiyeTab extends StatefulWidget {
  const _ImsakiyeTab();

  @override
  State<_ImsakiyeTab> createState() => _ImsakiyeTabState();
}

class _ImsakiyeTabState extends State<_ImsakiyeTab> {
  List<PrayerTime>? _monthData;
  bool _loading = false;
  String? _error;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = context.read<PrayerProvider>();
    final data = await ApiService().getMonthlyPrayerTimes(
      latitude: provider.latitude,
      longitude: provider.longitude,
      month: _month,
      year: _year,
      method: provider.calculationMethod,
      school: 0,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (data.isEmpty) {
        _error = 'Aylık vakit bilgisi alınamadı.';
      } else {
        _monthData = data;
      }
    });
  }

  void _changeMonth(int delta) {
    var m = _month + delta;
    var y = _year;
    if (m > 12) {
      m = 1;
      y++;
    } else if (m < 1) {
      m = 12;
      y--;
    }
    setState(() {
      _month = m;
      _year = y;
      _monthData = null;
    });
    _load();
  }

  DateTime _parseDate(String d) {
    final parts = d.split('-');
    if (parts.length < 3) return DateTime.now();
    return DateTime(
        int.tryParse(parts[2]) ?? 2025,
        int.tryParse(parts[1]) ?? 1,
        int.tryParse(parts[0]) ?? 1);
  }

  bool _parseDateForTable(String d, DateTime today) {
    final dt = _parseDate(d);
    return dt.day == today.day &&
        dt.month == today.month &&
        dt.year == today.year;
  }

  String _shareText(List<PrayerTime> data) {
    final buf = StringBuffer('$_year İmsakiye\n\n');
    buf.writeln('Gün     İmsak    İftar');
    buf.writeln('─' * 28);
    for (final pt in data) {
      final fajr = pt.entries.firstWhere((e) => e.icon == 'fajr');
      final magh = pt.entries.firstWhere((e) => e.icon == 'maghrib');
      final d = _parseDate(pt.date);
      final day = d.day.toString().padLeft(2);
      buf.writeln('$day       ${fajr.time.padRight(8)} ${magh.time}');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _loading ? null : () => _changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  '${monthNames[_month]} $_year',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _loading ? null : () => _changeMonth(1),
              ),
              if (_monthData != null)
                IconButton(
                  icon: Icon(Icons.share_rounded,
                      color: Theme.of(context).colorScheme.primary),
                  onPressed: () =>
                      Share.share(_shareText(_monthData!)),
                ),
            ],
          ),
        ),
        if (_loading)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary),
            ),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          )
        else if (_monthData != null)
          Expanded(
            child: SingleChildScrollView(
              child: _buildTable(context, _monthData!),
            ),
          ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, List<PrayerTime> data) {
    final today = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                      flex: 1,
                      child: Text('Gün',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13))),
                  Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(Icons.bedtime_rounded,
                              size: 14, color: Theme.of(context).colorScheme.primary),
                          SizedBox(width: 4),
                          Text('İmsak',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Row(
                        children: const [
                          Icon(Icons.restaurant_rounded,
                              size: 14, color: AppColors.gold),
                          SizedBox(width: 4),
                          Text('İftar',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      )),
                ],
              ),
            ),
            const Divider(height: 1),
            for (int i = 0; i < data.length; i++) ...[
              _ImsakiyeRow(
                prayer: data[i],
                isToday: _parseDateForTable(data[i].date, today),
              ),
              if (i != data.length - 1)
                Divider(
                    height: 1,
                    indent: 12,
                    endIndent: 12,
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImsakiyeRow extends StatelessWidget {
  final PrayerTime prayer;
  final bool isToday;

  const _ImsakiyeRow({required this.prayer, required this.isToday});

  DateTime _parseDate(String d) {
    final parts = d.split('-');
    if (parts.length < 3) return DateTime.now();
    return DateTime(
        int.tryParse(parts[2]) ?? 2025,
        int.tryParse(parts[1]) ?? 1,
        int.tryParse(parts[0]) ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    final fajr = prayer.entries.firstWhere((e) => e.icon == 'fajr');
    final magh = prayer.entries.firstWhere((e) => e.icon == 'maghrib');
    final date = _parseDate(prayer.date);
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final dayName = dayNames[date.weekday - 1];
    final isFriday = date.weekday == DateTime.friday;

    return Container(
      color: isToday
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : isFriday
                            ? AppColors.gold
                            : null,
                  ),
                ),
                Text(dayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isFriday ? AppColors.gold : null,
                        )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fajr.time,
              style: TextStyle(
                fontSize: 14,
                color: isToday ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isToday ? FontWeight.w600 : null,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              magh.time,
              style: TextStyle(
                fontSize: 14,
                color: isToday ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isToday ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatefulWidget {
  final String label;
  final DateTime target;

  const _CountdownCard({required this.label, required this.target});

  @override
  State<_CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<_CountdownCard> {
  Timer? _timer;
  final ValueNotifier<String> _text = ValueNotifier('00:00:00');

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = widget.target.difference(DateTime.now());
    final t = diff.isNegative ? Duration.zero : diff;
    _text.value =
        '${t.inHours.toString().padLeft(2, '0')}:${t.inMinutes.remainder(60).toString().padLeft(2, '0')}:${t.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            widget.label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.lightGold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          RepaintBoundary(
            child: ValueListenableBuilder<String>(
              valueListenable: _text,
              builder: (context, value, child) => Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _TimeCard(
      {required this.title, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 26),
            const SizedBox(height: 8),
            Text(time,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    )),
            const SizedBox(height: 2),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FastingCard extends StatelessWidget {
  const _FastingCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<FastingProvider>(
      builder: (context, fasting, child) {
        if (fasting.isLoading) {
          return const SizedBox.shrink();
        }
        final fasted = fasting.isFastedToday;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                          label: 'Bu Ay', value: '${fasting.thisMonthCount}'),
                    ),
                    Expanded(
                      child:
                          _Stat(label: 'Toplam', value: '${fasting.totalDays}'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: fasting.toggleToday,
                    icon: Icon(fasted
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined),
                    label: Text(
                        fasted ? 'Bugün oruç tutuldu ✓' : 'Bugün oruç tuttum'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          fasted ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
