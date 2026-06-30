import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/config/theme.dart';
import 'package:vakitli/l10n/app_localizations.dart';
import 'package:vakitli/providers/auth_provider.dart' as ap;
import 'package:vakitli/providers/locale_provider.dart';
import 'package:vakitli/providers/location_provider.dart';
import 'package:vakitli/providers/alarm_provider.dart';
import 'package:vakitli/providers/hadith_provider.dart';
import 'package:vakitli/providers/prayer_provider.dart';
import 'package:vakitli/providers/tracker_provider.dart';
import 'package:vakitli/providers/tasbih_provider.dart';
import 'package:vakitli/providers/dua_provider.dart';
import 'package:vakitli/providers/qada_provider.dart';
import 'package:vakitli/providers/fasting_provider.dart';
import 'package:vakitli/providers/nafile_provider.dart';
import 'package:vakitli/providers/dnd_provider.dart';
import 'package:vakitli/providers/hayd_provider.dart';
import 'package:vakitli/providers/profile_provider.dart';
import 'package:vakitli/providers/theme_provider.dart';
import 'package:vakitli/providers/hikmet_provider.dart';
import 'package:vakitli/providers/amel_provider.dart';
import 'package:vakitli/providers/hutbe_provider.dart';
import 'package:vakitli/providers/dua_kardesligi_provider.dart';
import 'package:vakitli/providers/mosque_geofence_provider.dart';
import 'package:vakitli/providers/quran_provider.dart';
import 'package:vakitli/providers/hatim_provider.dart';
import 'package:vakitli/providers/library_provider.dart';
import 'package:vakitli/providers/tebrik_provider.dart';
import 'package:vakitli/screens/auth/auth_screen.dart';
import 'package:vakitli/screens/main_shell.dart';
import 'package:vakitli/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('tr_TR', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const VakitliApp());
}

class VakitliApp extends StatelessWidget {
  const VakitliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()..initialize()),
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
        ChangeNotifierProvider(create: (_) => QadaProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => FastingProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => NafileProvider()..initialize()),
        ChangeNotifierProxyProvider<PrayerProvider, DndProvider>(
          create: (_) => DndProvider()..initialize(),
          update: (_, prayerProvider, dndProvider) {
            prayerProvider.onPrayerEntered =
                (_) => dndProvider!.handlePrayerEntered();
            return dndProvider!;
          },
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => HaydProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => HikmetProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AmelProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => HutbeProvider()),
        ChangeNotifierProvider(create: (_) => DuaKardesligiProvider()),
        ChangeNotifierProvider(
            create: (_) => MosqueGeofenceProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => HatimProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TebrikProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final useDynamic = themeProvider.useDynamicColor &&
                  lightDynamic != null &&
                  darkDynamic != null;
              return MaterialApp(
                title: 'Vakitli',
                debugShowCheckedModeBanner: false,
                theme: useDynamic
                    ? AppTheme.dynamicTheme(lightDynamic.harmonized())
                    : themeProvider.currentLightTheme,
                darkTheme: useDynamic
                    ? AppTheme.dynamicTheme(darkDynamic.harmonized())
                    : themeProvider.currentDarkTheme,
                themeMode: themeProvider.themeMode,
                locale: localeProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                routes: {
                  '/home': (_) => const MainShell(),
                },
                home: const _AuthGate(),
              );
            },
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();

    return switch (auth.status) {
      ap.AuthStatus.unknown => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ap.AuthStatus.unauthenticated => const AuthScreen(),
      ap.AuthStatus.authenticated => const _OnboardingGate(),
    };
  }
}

class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate();

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getBool('onboarding_complete') ?? false;
    if (mounted) setState(() => _onboardingComplete = local);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingComplete == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_onboardingComplete!) return const MainShell();
    return const OnboardingScreen();
  }
}
