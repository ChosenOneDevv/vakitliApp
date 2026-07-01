import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/hatim_provider.dart';

class HatimScreen extends StatelessWidget {
  const HatimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hatim Takibi')),
      body: Consumer<HatimProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProgressHeader(provider: provider),
              const SizedBox(height: 20),
              _StatsRow(provider: provider),
              const SizedBox(height: 20),
              Text(
                'Okunan Sayfa Ekle',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _AddPagesGrid(provider: provider),
              const SizedBox(height: 24),
              _GoalCard(provider: provider),
              const SizedBox(height: 16),
              _PageCard(provider: provider),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () => _confirmReset(context, provider),
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.lightText),
                  label: const Text(
                    'Hatmi Sıfırla',
                    style: TextStyle(color: AppColors.lightText),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmReset(
      BuildContext context, HatimProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hatmi Sıfırla'),
        content: const Text(
          'Mevcut hatim ilerlemen sıfırlanacak. Tamamlanan hatim sayın korunur. Onaylıyor musun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.resetProgress();
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  final HatimProvider provider;

  const _ProgressHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final percent = (provider.progress * 100).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${provider.currentPage} / ${provider.totalPages}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'sayfa · %$percent',
            style: const TextStyle(color: AppColors.lightGold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 10,
              backgroundColor: AppColors.white.withValues(alpha: 0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final HatimProvider provider;

  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.menu_book_rounded,
            value: '${provider.completedCount}',
            label: 'Tamamlanan Hatim',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.event_rounded,
            value: '${provider.estimatedDays}',
            label: 'Tahmini Gün',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPagesGrid extends StatelessWidget {
  final HatimProvider provider;

  const _AddPagesGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    const amounts = [1, 5, 10, 20];
    return Row(
      children: [
        for (final amount in amounts) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => provider.addPages(amount),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('+$amount'),
            ),
          ),
          if (amount != amounts.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final HatimProvider provider;

  const _GoalCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag_rounded, color: AppColors.gold),
        title: const Text('Günlük Hedef'),
        subtitle: Text('${provider.dailyGoal} sayfa / gün'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              onPressed: provider.dailyGoal > 1
                  ? () => provider.setDailyGoal(provider.dailyGoal - 1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => provider.setDailyGoal(provider.dailyGoal + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final HatimProvider provider;

  const _PageCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bookmark_rounded, color: AppColors.navy),
        title: const Text('Bulunduğun Sayfa'),
        subtitle: Text('${provider.currentPage}. sayfa'),
        trailing: TextButton(
          onPressed: () => _editPage(context, provider),
          child: const Text('Düzenle'),
        ),
      ),
    );
  }

  Future<void> _editPage(
      BuildContext context, HatimProvider provider) async {
    final controller =
        TextEditingController(text: '${provider.currentPage}');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sayfayı Ayarla'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Sayfa (0 - ${provider.totalPages})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(int.tryParse(controller.text)),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (result != null) {
      await provider.setCurrentPage(result);
    }
  }
}
