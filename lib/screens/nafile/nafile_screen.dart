import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/nafile_provider.dart';
import 'package:vakitli/services/nafile_service.dart';

class NafileScreen extends StatelessWidget {
  const NafileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nafile / Sünnet Takibi')),
      body: Consumer<NafileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.darkGreen, AppColors.primaryGreen],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text('${provider.todayCount}/${NafileService.keys.length}',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                )),
                    Text('Bugün kılınan nafile',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.lightGold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...NafileService.keys.map((key) {
                final done = provider.isDoneToday(key);
                return Card(
                  child: ListTile(
                    leading: Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: done ? AppColors.primaryGreen : AppColors.lightText,
                    ),
                    title: Text(NafileService.names[key]!),
                    subtitle: Text('Toplam: ${provider.totalFor(key)}'),
                    trailing: const Icon(Icons.touch_app_rounded,
                        size: 18, color: AppColors.lightText),
                    onTap: () => provider.toggleToday(key),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
