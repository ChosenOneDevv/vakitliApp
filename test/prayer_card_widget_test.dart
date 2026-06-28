import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/widgets/prayer_card.dart';

void main() {
  Widget wrap(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  final entry = PrayerEntry(name: 'Öğle', time: '13:10', icon: 'dhuhr');

  testWidgets('shows prayer name and time', (tester) async {
    await tester.pumpWidget(wrap(PrayerCard(entry: entry)));
    expect(find.text('Öğle'), findsOneWidget);
    expect(find.text('13:10'), findsOneWidget);
  });

  testWidgets('renders in dark theme without error', (tester) async {
    await tester.pumpWidget(
      wrap(PrayerCard(entry: entry, isNext: true), theme: AppTheme.darkTheme),
    );
    expect(find.text('Öğle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
