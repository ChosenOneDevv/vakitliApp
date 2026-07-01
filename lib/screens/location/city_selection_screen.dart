import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/location_provider.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LocationProvider>().resetFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Seçimi'),
      ),
      body: Column(
        children: [
          // GPS ile konum tespiti butonu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Consumer<LocationProvider>(
              builder: (context, provider, _) {
                return ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final success = await provider.detectCurrentLocation();
                          if (success && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.my_location_rounded),
                  label: Text(provider.isLoading ? 'Konum Tespit Ediliyor...' : 'GPS ile Konumumu Bul'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.navy,
                  ),
                );
              },
            ),
          ),

          // Hata mesajı
          Consumer<LocationProvider>(
            builder: (context, provider, _) {
              if (provider.error != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Ayırıcı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'veya şehir seçin',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),

          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<LocationProvider>().filterCities(value);
              },
              decoration: InputDecoration(
                hintText: 'Şehir ara...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.lightText),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context.read<LocationProvider>().filterCities('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.darkCream),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.darkCream),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Şehir listesi
          Expanded(
            child: Consumer<LocationProvider>(
              builder: (context, provider, _) {
                final cities = provider.filteredCities;

                if (cities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: AppColors.lightText),
                        const SizedBox(height: 12),
                        Text(
                          'Şehir bulunamadı',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.lightText,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cities.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = provider.currentLocation?.cityName == city.name;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                              : AppColors.gold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.location_city_rounded,
                          color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.gold,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        city.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                          : const Icon(Icons.chevron_right_rounded, color: AppColors.lightText),
                      onTap: () async {
                        await provider.selectCity(city);
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
