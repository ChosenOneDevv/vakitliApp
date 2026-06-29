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

  void _showAddDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    AmelCategory selected = AmelCategory.diger;
    int count = 1;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Amel Ekle'),
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
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amel Defteri')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primaryGreen,
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
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.category.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryGreen,
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
                  Text('× ${entry.count}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gold,
                          )),
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
