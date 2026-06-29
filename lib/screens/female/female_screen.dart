import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/hayd_record.dart';
import 'package:vakitli/models/sunnah_lesson.dart';
import 'package:vakitli/providers/hayd_provider.dart';
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
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
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryGreen))
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
                selectedColor: AppColors.primaryGreen,
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
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primaryGreen, size: 20),
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
                  color: AppColors.primaryGreen,
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
                const Icon(Icons.menu_book_rounded,
                    size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lesson.source!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryGreen,
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }
        return Stack(
          children: [
            provider.records.isEmpty
                ? _EmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    children: [
                      _SummaryCard(provider: provider),
                      const SizedBox(height: 12),
                      ...provider.records.map(
                        (r) => _HaydRecordCard(
                          record: r,
                          onDelete: () => provider.removeRecord(r.id),
                        ),
                      ),
                    ],
                  ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _addRecord(context, provider),
                backgroundColor: AppColors.primaryGreen,
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
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
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
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.water_drop_rounded,
                  color: AppColors.primaryGreen, size: 20),
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
                          color: AppColors.primaryGreen,
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
                  color: AppColors.primaryGreen,
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
                backgroundColor: AppColors.primaryGreen,
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
              .copyWith(primary: AppColors.primaryGreen),
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
