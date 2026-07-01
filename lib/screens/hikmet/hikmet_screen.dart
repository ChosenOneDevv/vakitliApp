import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/hikmet.dart';
import 'package:vakitli/providers/hikmet_provider.dart';

class HikmetScreen extends StatefulWidget {
  const HikmetScreen({super.key});

  @override
  State<HikmetScreen> createState() => _HikmetScreenState();
}

class _HikmetScreenState extends State<HikmetScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFav = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HikmetProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hikmetname'),
        actions: [
          IconButton(
            icon: Icon(
              _showFav ? Icons.favorite : Icons.favorite_border,
              color: _showFav ? Colors.red : null,
            ),
            onPressed: () => setState(() => _showFav = !_showFav),
          ),
        ],
      ),
      body: Consumer<HikmetProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final items = _showFav ? provider.favorites : provider.filtered;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Hikmet ara…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              provider.search('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: provider.search,
                ),
              ),
              if (items.isEmpty)
                const Expanded(
                  child: Center(child: Text('Sonuç bulunamadı.')),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _HikmetCard(hikmet: items[i], provider: provider),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HikmetCard extends StatelessWidget {
  final Hikmet hikmet;
  final HikmetProvider provider;

  const _HikmetCard({required this.hikmet, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isFav = provider.isFavorite(hikmet.id);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hikmet.topic,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => provider.toggleFavorite(hikmet.id),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFav ? Colors.red : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${hikmet.text}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${hikmet.author}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
