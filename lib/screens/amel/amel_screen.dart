import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/amel_entry.dart';
import 'package:vakitli/providers/amel_provider.dart';

class AmelScreen extends StatefulWidget {
  const AmelScreen({super.key});

  @override
  State<AmelScreen> createState() => _AmelScreenState();
}

class _AmelScreenState extends State<AmelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AmelProvider>().initialize();
    });
  }

  // ─── Hızlı ekleme preset listesi ──────────────────────────────────────────

  static const List<_Preset> _presets = [
    _Preset('Sabah Namazı', AmelCategory.namaz),
    _Preset('Öğle Namazı', AmelCategory.namaz),
    _Preset('İkindi Namazı', AmelCategory.namaz),
    _Preset('Akşam Namazı', AmelCategory.namaz),
    _Preset('Yatsı Namazı', AmelCategory.namaz),
    _Preset('Teheccüd Namazı', AmelCategory.namaz),
    _Preset('Kuşluk (Duha) Namazı', AmelCategory.namaz),
    _Preset('Sübhanallah', AmelCategory.zikir, count: 33),
    _Preset('Elhamdülillah', AmelCategory.zikir, count: 33),
    _Preset('Allahu Ekber', AmelCategory.zikir, count: 34),
    _Preset('Estağfirullah', AmelCategory.zikir, count: 100),
    _Preset('Salavat-ı Şerife', AmelCategory.zikir, count: 100),
    _Preset('La ilahe illallah', AmelCategory.zikir, count: 100),
    _Preset('Kuran Okuma', AmelCategory.kuran),
    _Preset('Yasin Suresi', AmelCategory.kuran),
    _Preset('Mülk Suresi', AmelCategory.kuran),
    _Preset('Sure Ezberleme', AmelCategory.kuran),
    _Preset('Sadaka Verme', AmelCategory.sadaka),
    _Preset('İyilik Yapma', AmelCategory.sadaka),
    _Preset('Dua Etme', AmelCategory.sadaka),
  ];

  // ─── Bottom sheet: hızlı ekle + özel ekle ─────────────────────────────────

  void _showQuickAddSheet(BuildContext context) {
    final provider = context.read<AmelProvider>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, ctrl) => Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Hızlı Ekle',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Özel Ekle'),
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _showCustomDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    children: AmelCategory.values
                        .where((cat) =>
                            _presets.any((p) => p.category == cat))
                        .map((cat) {
                      final items = _presets
                          .where((p) => p.category == cat)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                            child: Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          ...items.map((preset) => ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                leading: Icon(Icons.add_circle_outline_rounded,
                                    color: Theme.of(context).colorScheme.primary, size: 20),
                                title: Text(preset.text),
                                trailing: preset.count > 1
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '×${preset.count}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  provider.addEntry(
                                    text: preset.text,
                                    category: preset.category,
                                    count: preset.count,
                                  );
                                  Navigator.pop(sheetCtx);
                                },
                              )),
                          const Divider(height: 4),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Özel amel diyalogu ────────────────────────────────────────────────────

  void _showCustomDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    AmelCategory selected = AmelCategory.diger;
    int count = 1;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Özel Amel Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textCtrl,
                autofocus: true,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Amel açıklaması',
                  hintText: 'Örn: Akşam namazını kıldım',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AmelCategory>(
                initialValue: selected,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: AmelCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (v) => setSt(() => selected = v ?? selected),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Tekrar:'),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.remove_rounded),
                    onPressed: () =>
                        setSt(() => count = (count - 1).clamp(1, 999)),
                  ),
                  Text('$count',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () =>
                        setSt(() => count = (count + 1).clamp(1, 999)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textCtrl.text.trim();
                if (text.isNotEmpty) {
                  context.read<AmelProvider>().addEntry(
                        text: text,
                        category: selected,
                        count: count,
                      );
                }
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amel Defteri')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Consumer<AmelProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = provider.today;
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined,
                      size: 64, color: AppColors.gold),
                  const SizedBox(height: 16),
                  Text('Bugün henüz amel kaydedilmedi.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('+ butonuna basarak ekleyebilirsiniz.',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _AmelTile(entry: entries[i], provider: provider),
          );
        },
      ),
    );
  }
}

// ─── Preset veri sınıfı ───────────────────────────────────────────────────────

class _Preset {
  final String text;
  final AmelCategory category;
  final int count;

  const _Preset(this.text, this.category, {this.count = 1});
}

// ─── Amel kartı ───────────────────────────────────────────────────────────────

class _AmelTile extends StatelessWidget {
  final AmelEntry entry;
  final AmelProvider provider;

  const _AmelTile({required this.entry, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.category.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.text,
                    style: Theme.of(context).textTheme.bodyMedium),
                if (entry.count > 1)
                  Text(
                    '× ${entry.count}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gold,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => provider.deleteEntry(entry.id),
          ),
        ],
      ),
    );
  }
}
