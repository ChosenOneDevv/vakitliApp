import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/sunnah_lesson.dart';
import 'package:vakitli/providers/sunnah_provider.dart';

class SunnahScreen extends StatelessWidget {
  const SunnahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SunnahProvider()..initialize(),
      child: const _SunnahView(),
    );
  }
}

class _SunnahView extends StatelessWidget {
  const _SunnahView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sünnet Dersleri')),
      body: Consumer<SunnahProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.categories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return Column(
            children: [
              _CategoryBar(
                categories: provider.categories,
                selected: provider.selectedCategory,
                onSelect: provider.selectCategory,
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.lessons.length,
                        itemBuilder: (context, index) => _LessonCard(
                          lesson: provider.lessons[index],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
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

class _LessonCard extends StatelessWidget {
  final SunnahLesson lesson;

  const _LessonCard({required this.lesson});

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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${lesson.id}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.lightText),
                ],
              ),
              const SizedBox(height: 10),
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
      builder: (_) => _LessonDetail(lesson: lesson),
    );
  }
}

class _LessonDetail extends StatelessWidget {
  final SunnahLesson lesson;

  const _LessonDetail({required this.lesson});

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
          // Tutamaç
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

          // Kategori etiketi
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // Başlık
          Text(
            lesson.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
          ),
          const SizedBox(height: 16),

          // İçerik
          Text(
            lesson.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                ),
          ),

          // Kaynak
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
