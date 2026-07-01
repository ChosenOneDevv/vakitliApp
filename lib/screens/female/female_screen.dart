import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/flow_entry.dart';
import 'package:vakitli/models/hayd_record.dart';
import 'package:vakitli/models/madhhab.dart';
import 'package:vakitli/models/sunnah_lesson.dart';
import 'package:vakitli/providers/alarm_provider.dart';
import 'package:vakitli/providers/hayd_provider.dart';
import 'package:vakitli/providers/qada_provider.dart';
import 'package:vakitli/services/fiqh_engine.dart';
import 'package:vakitli/services/female_content_service.dart';

class FemaleScreen extends StatefulWidget {
  const FemaleScreen({super.key});

  @override
  State<FemaleScreen> createState() => _FemaleScreenState();
}

class _FemaleScreenState extends State<FemaleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('Kadın Köşesi'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Hükümler'),
            Tab(text: 'Hayız Takip'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FemaleContentTab(),
          _HaydTrackerTab(),
        ],
      ),
    );
  }
}

// ─── Tab 1: Fıkhi hükümler ───────────────────────────────────────────────────

class _FemaleContentTab extends StatefulWidget {
  const _FemaleContentTab();

  @override
  State<_FemaleContentTab> createState() => _FemaleContentTabState();
}

class _FemaleContentTabState extends State<_FemaleContentTab> {
  final FemaleContentService _service = FemaleContentService();
  List<String> _categories = [];
  List<SunnahLesson> _lessons = [];
  String? _selectedCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await _service.loadCategories();
    final lessons =
        cats.isNotEmpty ? await _service.loadByCategory(cats.first) : <SunnahLesson>[];
    if (mounted) {
      setState(() {
        _categories = cats;
        _lessons = lessons;
        _selectedCategory = cats.isNotEmpty ? cats.first : null;
        _loading = false;
      });
    }
  }

  Future<void> _selectCategory(String cat) async {
    setState(() => _loading = true);
    final lessons = await _service.loadByCategory(cat);
    if (mounted) {
      setState(() {
        _selectedCategory = cat;
        _lessons = lessons;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _categories.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }
    return Column(
      children: [
        _CategoryBar(
          categories: _categories,
          selected: _selectedCategory,
          onSelect: _selectCategory,
        ),
        Expanded(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _lessons.length,
                  itemBuilder: (_, i) =>
                      _ContentCard(lesson: _lessons[i]),
                ),
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final void Function(String) onSelect;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => onSelect(cat),
                selectedColor: Theme.of(context).colorScheme.primary,
                checkmarkColor: AppColors.white,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : null,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final SunnahLesson lesson;

  const _ContentCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.lightText),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lesson.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightText,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ContentDetail(lesson: lesson),
    );
  }
}

class _ContentDetail extends StatelessWidget {
  final SunnahLesson lesson;

  const _ContentDetail({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightText.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              lesson.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lesson.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            lesson.content,
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
          if (lesson.source != null) ...[
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lesson.source!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab 2: Hayız takip ──────────────────────────────────────────────────────

class _HaydTrackerTab extends StatelessWidget {
  const _HaydTrackerTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<HaydProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          );
        }
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                _FiqhSection(provider: provider),
                const SizedBox(height: 16),
                if (provider.records.isEmpty)
                  _EmptyState()
                else ...[
                  _SummaryCard(provider: provider),
                  const SizedBox(height: 12),
                  ...provider.records.map(
                    (r) => _HaydRecordCard(
                      record: r,
                      onDelete: () => provider.removeRecord(r.id),
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _addRecord(context, provider),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: AppColors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Kayıt Ekle'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addRecord(BuildContext context, HaydProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddHaydSheet(provider: provider),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 64, color: AppColors.lightText),
          const SizedBox(height: 16),
          Text(
            'Henüz kayıt yok.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.lightText),
          ),
          const SizedBox(height: 8),
          Text(
            '"Kayıt Ekle" ile hayız dönemlerinizi takip edin.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final HaydProvider provider;

  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.records.length} kayıt',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Toplam ${provider.totalHaydDays} gün',
                  style: const TextStyle(color: AppColors.lightGold),
                ),
              ],
            ),
          ),
          const Icon(Icons.calendar_today_rounded,
              color: AppColors.white, size: 32),
        ],
      ),
    );
  }
}

class _HaydRecordCard extends StatelessWidget {
  final HaydRecord record;
  final VoidCallback onDelete;

  static final _fmt = DateFormat('dd MMM yyyy', 'tr_TR');

  const _HaydRecordCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.water_drop_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_fmt.format(record.startDate)} – ${_fmt.format(record.endDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '${record.durationDays} gün',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.lightText),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kaydı sil?'),
        content: const Text('Bu hayız kaydı kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            child: const Text('Sil',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AddHaydSheet extends StatefulWidget {
  final HaydProvider provider;

  const _AddHaydSheet({required this.provider});

  @override
  State<_AddHaydSheet> createState() => _AddHaydSheetState();
}

class _AddHaydSheetState extends State<_AddHaydSheet> {
  DateTime? _start;
  DateTime? _end;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hayız Kaydı Ekle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _DateField(
            label: 'Başlangıç tarihi',
            value: _start,
            onTap: () => _pick(
              isStart: true,
              initial: _start ?? DateTime.now(),
              first: DateTime(2000),
              last: DateTime.now(),
            ),
          ),
          const SizedBox(height: 12),
          _DateField(
            label: 'Bitiş tarihi',
            value: _end,
            onTap: () => _pick(
              isStart: false,
              initial: _end ?? (_start ?? DateTime.now()),
              first: _start ?? DateTime(2000),
              last: DateTime.now(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave && !_saving ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canSave => _start != null && _end != null;

  Future<void> _pick({
    required bool isStart,
    required DateTime initial,
    required DateTime first,
    required DateTime last,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(last) ? last : initial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('tr', 'TR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end != null && _end!.isBefore(picked)) _end = null;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    await widget.provider.addRecord(_start!, _end!);
    if (mounted) Navigator.of(context).pop();
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  static final _fmt = DateFormat('dd.MM.yyyy', 'tr_TR');

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          value != null ? _fmt.format(value!) : 'Seç',
          style: value == null
              ? Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.lightText)
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Faz 24: Fıkhi durum motoru UI (mezhep, günlük akıntı, muafiyet, kaza)
// ---------------------------------------------------------------------------

Color _statusColor(FiqhStatus? s, Color primary) {
  switch (s) {
    case FiqhStatus.hayd:
      return Colors.redAccent;
    case FiqhStatus.nifas:
      return AppColors.navy;
    case FiqhStatus.istihaze:
      return AppColors.gold;
    case FiqhStatus.temiz:
      return primary;
    case null:
      return AppColors.lightText;
  }
}

String _statusLabel(FiqhStatus? s) {
  switch (s) {
    case FiqhStatus.hayd:
      return 'Hayız (namaz/oruç muaf)';
    case FiqhStatus.nifas:
      return 'Nifas (namaz/oruç muaf)';
    case FiqhStatus.istihaze:
      return 'İstihaze (namaza devam)';
    case FiqhStatus.temiz:
      return 'Temiz';
    case null:
      return 'Bugün için kayıt yok';
  }
}

Color _flowColor(FlowType? t, Color primary) {
  switch (t) {
    case FlowType.bleeding:
      return Colors.redAccent;
    case FlowType.spotting:
      return AppColors.gold;
    case FlowType.clean:
      return primary;
    case null:
      return AppColors.darkCream;
  }
}

class _FiqhSection extends StatelessWidget {
  final HaydProvider provider;

  const _FiqhSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final status = provider.currentStatus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _statusColor(status, Theme.of(context).colorScheme.primary).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _statusColor(status, Theme.of(context).colorScheme.primary), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop_rounded,
                      color: _statusColor(status, Theme.of(context).colorScheme.primary), size: 22),
                  const SizedBox(width: 8),
                  Text('Fıkhi Durum',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _statusLabel(status),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _statusColor(status, Theme.of(context).colorScheme.primary),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        if (status == FiqhStatus.istihaze)
          const _InfoBanner(
            color: AppColors.gold,
            icon: Icons.info_rounded,
            text:
                'Bu kanama istihaze (özür) hükmünde. Namazlarına devam et; '
                'her vakit için abdest al.',
          ),
        if (provider.justEndedHayd)
          _InfoBanner(
            color: Theme.of(context).colorScheme.primary,
            icon: Icons.check_circle_rounded,
            text: 'Hayız bitti. Gusül alıp namaza başlayabilirsin.',
          ),
        const SizedBox(height: 16),
        Text('Bugünkü Akıntı',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final type in FlowType.values) ...[
              Expanded(
                child: _FlowButton(
                  type: type,
                  selected: provider.todayFlow == type,
                  onTap: () => provider.setFlow(DateTime.now(), type),
                ),
              ),
              if (type != FlowType.values.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text('Son 14 Gün (dokun → işaretle)',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _FlowStrip(provider: provider),
        const SizedBox(height: 16),
        _MadhhabRow(provider: provider),
        const SizedBox(height: 8),
        _ExemptionToggle(provider: provider),
        const SizedBox(height: 8),
        _QadaIntegration(provider: provider),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _InfoBanner(
      {required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _FlowButton extends StatelessWidget {
  final FlowType type;
  final bool selected;
  final VoidCallback onTap;

  const _FlowButton(
      {required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _flowColor(type, Theme.of(context).colorScheme.primary);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? color : AppColors.darkCream,
              width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(Icons.circle, color: color, size: 14),
            const SizedBox(height: 4),
            Text(type.displayName,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _FlowStrip extends StatelessWidget {
  final HaydProvider provider;

  const _FlowStrip({required this.provider});

  /// Tıklamada tip döngüsü: yok → kanama → lekelenme → temiz → yok.
  FlowType? _next(FlowType? current) {
    switch (current) {
      case null:
        return FlowType.bleeding;
      case FlowType.bleeding:
        return FlowType.spotting;
      case FlowType.spotting:
        return FlowType.clean;
      case FlowType.clean:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final date = DateTime(today.year, today.month, today.day)
              .subtract(Duration(days: 13 - i));
          final type = provider.flowOn(date);
          return GestureDetector(
            onTap: () {
              final next = _next(type);
              if (next == null) {
                provider.clearFlow(date);
              } else {
                provider.setFlow(date, next);
              }
            },
            child: Container(
              width: 36,
              decoration: BoxDecoration(
                color: _flowColor(type, Theme.of(context).colorScheme.primary)
                    .withValues(alpha: type == null ? 0.4 : 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: type == null ? AppColors.lightText : AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MadhhabRow extends StatelessWidget {
  final HaydProvider provider;

  const _MadhhabRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.balance_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Mezhep'),
            const Spacer(),
            DropdownButton<Madhhab>(
              value: provider.madhhab,
              underline: const SizedBox.shrink(),
              onChanged: (m) {
                if (m != null) provider.setMadhhab(m);
              },
              items: Madhhab.values
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.displayName),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExemptionToggle extends StatelessWidget {
  final HaydProvider provider;

  const _ExemptionToggle({required this.provider});

  @override
  Widget build(BuildContext context) {
    final alarm = context.watch<AlarmProvider>();
    return Card(
      child: SwitchListTile(
        secondary: Icon(Icons.notifications_off_rounded,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('Hayız Muafiyeti'),
        subtitle: Text(provider.isExemptToday
            ? 'Bugün hayız — namaz alarmlarını kapatabilirsin.'
            : 'Açıkken namaz alarmları kurulmaz.'),
        value: alarm.exemptionActive,
        activeTrackColor: Theme.of(context).colorScheme.primary,
        onChanged: (v) => alarm.setExemption(v),
      ),
    );
  }
}

class _QadaIntegration extends StatelessWidget {
  final HaydProvider provider;

  const _QadaIntegration({required this.provider});

  @override
  Widget build(BuildContext context) {
    final istihaze = provider.istihazeDaysCount();
    if (istihaze == 0) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_repeat_rounded, color: AppColors.gold),
        title: Text('$istihaze istihaze günü tespit edildi'),
        subtitle: const Text('İstihaze günleri kazaya sayılır.'),
        trailing: TextButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await context.read<QadaProvider>().addDays(istihaze);
            messenger.showSnackBar(
              SnackBar(content: Text('$istihaze gün kazaya eklendi.')),
            );
          },
          child: const Text('Kazaya Ekle'),
        ),
      ),
    );
  }
}
