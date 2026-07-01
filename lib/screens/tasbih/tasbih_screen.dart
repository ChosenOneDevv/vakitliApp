import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/tasbih_profile.dart';
import 'package:vakitli/providers/tasbih_provider.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tesbih Sayacı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Yeni profil',
            onPressed: () => _showAddProfileDialog(context),
          ),
        ],
      ),
      body: Consumer<TasbihProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.active == null) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          final active = provider.active!;
          return Column(
            children: [
              const SizedBox(height: 12),
              _ProfileSelector(provider: provider),
              const SizedBox(height: 8),
              Expanded(child: _CounterArea(profile: active, provider: provider)),
              _BottomBar(profile: active, provider: provider),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController(text: '33');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Yeni Profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'İsim'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(labelText: 'Hedef'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final target = int.tryParse(targetController.text.trim()) ?? 33;
                if (name.isNotEmpty) {
                  dialogContext.read<TasbihProvider>().addProfile(name, target);
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  final TasbihProvider provider;

  const _ProfileSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.profiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final profile = provider.profiles[index];
          final selected = profile.id == provider.active?.id;
          return GestureDetector(
            onLongPress: () => _confirmDelete(context, profile),
            child: ChoiceChip(
              label: Text(profile.name),
              selected: selected,
              onSelected: (_) => provider.selectProfile(profile.id),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selected
                  ? AppColors.white
                  : Theme.of(context).colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, TasbihProfile profile) {
    if (provider.profiles.length <= 1) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('"${profile.name}" silinsin mi?'),
        content: const Text('Bu profil ve sayacı kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteProfile(profile.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CounterArea extends StatelessWidget {
  final TasbihProfile profile;
  final TasbihProvider provider;

  const _CounterArea({required this.profile, required this.provider});

  @override
  Widget build(BuildContext context) {
    final cycles = profile.target == 0 ? 0 : profile.count ~/ profile.target;
    return GestureDetector(
      onTap: provider.increment,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: profile.progress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.darkCream,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${profile.count % profile.target}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontSize: 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'Hedef: ${profile.target}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tamamlanan tur: $cycles',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: 8),
            Text(
              'Dokunarak say',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final TasbihProfile profile;
  final TasbihProvider provider;

  const _BottomBar({required this.profile, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _targetChip(context, 33),
            const SizedBox(width: 8),
            _targetChip(context, 99),
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('Özel'),
              onPressed: () => _showCustomTargetDialog(context),
            ),
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Sıfırla'),
              onPressed: provider.resetCurrent,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Toplam zikir: ${provider.grandTotal}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _targetChip(BuildContext context, int target) {
    final selected = profile.target == target;
    return ChoiceChip(
      label: Text('$target'),
      selected: selected,
      onSelected: (_) => provider.setTarget(target),
      selectedColor: AppColors.gold,
    );
  }

  void _showCustomTargetDialog(BuildContext context) {
    final controller = TextEditingController(text: '${profile.target}');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Özel Hedef'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Hedef sayı'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(controller.text.trim());
              if (target != null && target > 0) {
                provider.setTarget(target);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }
}
