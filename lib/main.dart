import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/providers/location_provider.dart';
import 'package:vakitli/providers/alarm_provider.dart';
import 'package:vakitli/providers/hadith_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/providers/tracker_provider.dart';
import 'package:vakitli/providers/tasbih_provider.dart';
import 'package:vakitli/providers/dua_provider.dart';
import 'package:vakitli/providers/theme_provider.dart';
import 'package:vakitli/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Fontlar bundle edildi (assets/fonts) — runtime network fetch yok.
  runApp(const VakitliApp());
}

class VakitliApp extends StatelessWidget {
  const VakitliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()..loadSavedLocation()),
        ChangeNotifierProxyProvider<LocationProvider, PrayerProvider>(
          create: (_) => PrayerProvider()..initialize(),
          update: (_, locationProvider, prayerProvider) {
            if (locationProvider.currentLocation != null) {
              prayerProvider!.setLocation(
                locationProvider.currentLocation!.latitude,
                locationProvider.currentLocation!.longitude,
                locationProvider.currentLocation!.cityName,
              );
            }
            return prayerProvider!;
          },
        ),
        ChangeNotifierProxyProvider<PrayerProvider, AlarmProvider>(
          create: (_) => AlarmProvider()..initialize(),
          update: (_, prayerProvider, alarmProvider) {
            // Vakitler güncellenince bildirimleri yeniden kur (bugün + yarın).
            alarmProvider!.scheduleNotifications(
              prayerProvider.todayPrayer,
              tomorrowPrayer: prayerProvider.tomorrowPrayer,
            );
            return alarmProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => HadithProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TrackerProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TasbihProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => DuaProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Vakitli',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
