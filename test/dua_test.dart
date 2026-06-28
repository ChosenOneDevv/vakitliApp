import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/providers/dua_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DuaProvider> loadedProvider() async {
    final provider = DuaProvider();
    await provider.initialize();
    return provider;
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('loads duas from asset bundle', () async {
    final provider = await loadedProvider();
    expect(provider.error, isNull);
    expect(provider.filteredDuas, isNotEmpty);
  });

  test('categories include Tümü + Favoriler first', () async {
    final provider = await loadedProvider();
    expect(provider.categories[0], DuaProvider.allCategory);
    expect(provider.categories[1], DuaProvider.favCategory);
  });

  test('category filter narrows results', () async {
    final provider = await loadedProvider();
    final all = provider.filteredDuas.length;
    provider.selectCategory('Yemek');
    final yemek = provider.filteredDuas;
    expect(yemek.length, lessThan(all));
    expect(yemek.every((d) => d.category == 'Yemek'), true);
  });

  test('search matches title/meaning/transliteration', () async {
    final provider = await loadedProvider();
    provider.search('besmele');
    expect(provider.filteredDuas.any((d) => d.title == 'Besmele'), true);
  });

  test('toggleFavorite + Favoriler kategorisi', () async {
    final provider = await loadedProvider();
    final id = provider.filteredDuas.first.id;
    await provider.toggleFavorite(id);
    expect(provider.isFavorite(id), true);
    provider.selectCategory(DuaProvider.favCategory);
    expect(provider.filteredDuas.map((d) => d.id), contains(id));
  });

  test('favorites persist across provider instances', () async {
    final p1 = await loadedProvider();
    final id = p1.filteredDuas.first.id;
    await p1.toggleFavorite(id);

    final p2 = await loadedProvider();
    expect(p2.isFavorite(id), true);
  });
}
