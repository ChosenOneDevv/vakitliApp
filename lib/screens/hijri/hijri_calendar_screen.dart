import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/hijri_day.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/services/api_service.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  final ApiService _api = ApiService();
  late DateTime _month;
  List<HijriDay> _days = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final days = await _api.getHijriCalendar(_month.month, _month.year);
    if (mounted) {
      setState(() {
        _days = days;
        _loading = false;
      });
    }
  }

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'tr_TR').format(_month);
    final holidays = _days.where((d) => d.hasHoliday).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Hicri Takvim')),
      body: Column(
        children: [
          _header(monthLabel),
          if (_loading)
            Expanded(
              child: Center(
                child:
                    CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  if (holidays.isNotEmpty) ...[
                    _holidaysSection(holidays),
                    const SizedBox(height: 12),
                  ],
                  ..._days.map(_dayTile),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(String monthLabel) {
    final prayer = context.watch<PrayerProvider>();
    final hijri = prayer.todayPrayer?.hijriFormatted;
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: _loading ? null : () => _shift(-1),
          ),
          Expanded(
            child: Column(
              children: [
                Text(monthLabel,
                    style: Theme.of(context).textTheme.titleMedium),
                if (hijri != null)
                  Text('Bugün: $hijri',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: _loading ? null : () => _shift(1),
          ),
        ],
      ),
    );
  }

  Widget _holidaysSection(List<HijriDay> holidays) {
    return Card(
      color: AppColors.gold.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.celebration_rounded,
                    size: 20, color: AppColors.gold),
                const SizedBox(width: 8),
                Text('Bu Ayın Dini Günleri',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...holidays.map((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${DateFormat('d MMM', 'tr_TR').format(d.gregorian)} — ${d.holidays.join(", ")}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _dayTile(HijriDay d) {
    final weekday = DateFormat('EEEE', 'tr_TR').format(d.gregorian);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: d.isToday
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: d.hasHoliday
            ? Border.all(color: AppColors.gold.withValues(alpha: 0.5))
            : null,
      ),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${d.gregorian.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: d.isToday ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: FontWeight.bold,
                    )),
          ],
        ),
        title: Text('${d.hijriDay} ${d.hijriMonthTr} ${d.hijriYear}'),
        subtitle: Text(
          d.hasHoliday ? d.holidays.join(', ') : weekday,
          style: d.hasHoliday
              ? Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  )
              : Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
