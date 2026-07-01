import 'package:flutter/material.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/data/turkey_cities.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/services/api_service.dart';
import 'package:vakitli/services/saved_cities_service.dart';

/// Çoklu şehir takibi — kaydedilen şehirlerin bugünkü vakitlerini listeler.
class SavedCitiesScreen extends StatefulWidget {
  const SavedCitiesScreen({super.key});

  @override
  State<SavedCitiesScreen> createState() => _SavedCitiesScreenState();
}

class _SavedCitiesScreenState extends State<SavedCitiesScreen> {
  final SavedCitiesService _service = SavedCitiesService();
  final ApiService _api = ApiService();

  List<SavedCity> _cities = [];
  final Map<String, PrayerTime?> _times = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cities = await _service.loadAll();
    final times = <String, PrayerTime?>{};
    await Future.wait(cities.map((c) async {
      times[c.name] = await _api.getDailyPrayerTimes(
        latitude: c.latitude,
        longitude: c.longitude,
      );
    }));
    if (!mounted) return;
    setState(() {
      _cities = cities;
      _times
        ..clear()
        ..addAll(times);
      _loading = false;
    });
  }

  Future<void> _addCity() async {
    final picked = await showModalBottomSheet<CityData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CityPickerSheet(
        excluded: _cities.map((c) => c.name).toSet(),
      ),
    );
    if (picked == null) return;
    await _service.add(SavedCity(
      name: picked.name,
      latitude: picked.latitude,
      longitude: picked.longitude,
    ));
    await _load();
  }

  Future<void> _removeCity(String name) async {
    await _service.remove(name);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çoklu Şehir')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCity,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Şehir Ekle'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
      );
    }
    if (_cities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_city_rounded,
                  size: 56, color: AppColors.lightText),
              const SizedBox(height: 12),
              Text(
                'Henüz şehir eklenmedi.\nFarklı şehirlerin vakitlerini takip etmek için ekleyin.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          return _CityCard(
            city: city,
            prayer: _times[city.name],
            onRemove: () => _removeCity(city.name),
          );
        },
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  final SavedCity city;
  final PrayerTime? prayer;
  final VoidCallback onRemove;

  const _CityCard({
    required this.city,
    required this.prayer,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_city_rounded,
                    color: AppColors.gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    city.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.lightText),
                  tooltip: 'Kaldır',
                  onPressed: onRemove,
                ),
              ],
            ),
            const Divider(height: 16),
            if (prayer == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Vakitler alınamadı (bağlantı yok).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: prayer!.entries
                    .map((e) => _VakitCell(name: e.name, time: e.time))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _VakitCell extends StatelessWidget {
  final String name;
  final String time;

  const _VakitCell({required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.lightText,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

/// Aranabilir 81 il listesi (çevrimdışı — `turkeyCities`).
class _CityPickerSheet extends StatefulWidget {
  final Set<String> excluded;

  const _CityPickerSheet({required this.excluded});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase().trim();
    final cities = turkeyCities
        .where((c) =>
            !widget.excluded.contains(c.name) &&
            (q.isEmpty || c.name.toLowerCase().contains(q)))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Şehir ara...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.lightText),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.darkCream),
                  ),
                ),
              ),
            ),
            Expanded(
              child: cities.isEmpty
                  ? Center(
                      child: Text(
                        'Şehir bulunamadı',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: cities.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return ListTile(
                          leading: const Icon(Icons.location_city_rounded,
                              color: AppColors.gold),
                          title: Text(city.name),
                          onTap: () => Navigator.of(context).pop(city),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
