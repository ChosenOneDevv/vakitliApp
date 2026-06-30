import 'package:flutter/material.dart';
import 'package:vakitli/config/theme.dart';

/// Gece ibadeti vakitlerini gösteren kart: Gece Yarısı + Son Üçte Bir (Teheccüd).
class TeheccudCard extends StatelessWidget {
  final String midnight;
  final String lastThird;

  const TeheccudCard({
    super.key,
    required this.midnight,
    required this.lastThird,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.navy.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.nightlight_round,
                    size: 18, color: AppColors.navy),
                const SizedBox(width: 8),
                Text('Gece İbadeti',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _slot(context, 'Gece Yarısı', midnight),
                ),
                Expanded(
                  child: _slot(context, 'Son Üçte Bir', lastThird),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Teheccüd, gecenin son üçte birinde kılınan nafile namazdır.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.lightText,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(BuildContext context, String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.lightText,
                )),
        const SizedBox(height: 2),
        Text(time.isEmpty ? '--:--' : time,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                )),
      ],
    );
  }
}
