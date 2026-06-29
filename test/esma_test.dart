import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/services/esma_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads 99 names from asset', () async {
    final names = await EsmaService().load();
    expect(names.length, 99);
    expect(names.first.transliteration, 'Er-Rahmân');
    expect(names.last.transliteration, 'Es-Sabûr');
  });

  test('every name has arabic + meaning', () async {
    final names = await EsmaService().load();
    expect(names.every((n) => n.arabic.isNotEmpty && n.meaning.isNotEmpty),
        true);
  });
}
