import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Vakitli'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navQibla.
  ///
  /// In tr, this message translates to:
  /// **'Kıble'**
  String get navQibla;

  /// No description provided for @navApps.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamalar'**
  String get navApps;

  /// No description provided for @nextPrayer.
  ///
  /// In tr, this message translates to:
  /// **'SONRAKİ VAKİT'**
  String get nextPrayer;

  /// No description provided for @todaysPrayers.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Vakitleri'**
  String get todaysPrayers;

  /// No description provided for @offlineMessage.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışısınız — kayıtlı vakitler gösteriliyor.'**
  String get offlineMessage;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @appsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamalar'**
  String get appsTitle;

  /// No description provided for @appTracker.
  ///
  /// In tr, this message translates to:
  /// **'Namaz Takip'**
  String get appTracker;

  /// No description provided for @appTrackerSub.
  ///
  /// In tr, this message translates to:
  /// **'Günlük takip + istatistik'**
  String get appTrackerSub;

  /// No description provided for @appQada.
  ///
  /// In tr, this message translates to:
  /// **'Kaza Namazı'**
  String get appQada;

  /// No description provided for @appQadaSub.
  ///
  /// In tr, this message translates to:
  /// **'Kaza borç takibi'**
  String get appQadaSub;

  /// No description provided for @appNafile.
  ///
  /// In tr, this message translates to:
  /// **'Nafile Takip'**
  String get appNafile;

  /// No description provided for @appNafileSub.
  ///
  /// In tr, this message translates to:
  /// **'Sünnet/nafile namaz'**
  String get appNafileSub;

  /// No description provided for @appTasbih.
  ///
  /// In tr, this message translates to:
  /// **'Tesbih'**
  String get appTasbih;

  /// No description provided for @appTasbihSub.
  ///
  /// In tr, this message translates to:
  /// **'Zikir sayacı'**
  String get appTasbihSub;

  /// No description provided for @appRamadan.
  ///
  /// In tr, this message translates to:
  /// **'Ramazan'**
  String get appRamadan;

  /// No description provided for @appRamadanSub.
  ///
  /// In tr, this message translates to:
  /// **'İmsak/iftar + oruç'**
  String get appRamadanSub;

  /// No description provided for @appMosque.
  ///
  /// In tr, this message translates to:
  /// **'Cami Bulucu'**
  String get appMosque;

  /// No description provided for @appMosqueSub.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki camiler'**
  String get appMosqueSub;

  /// No description provided for @appEsma.
  ///
  /// In tr, this message translates to:
  /// **'Esma-ül Hüsna'**
  String get appEsma;

  /// No description provided for @appEsmaSub.
  ///
  /// In tr, this message translates to:
  /// **'Allah\'ın 99 ismi'**
  String get appEsmaSub;

  /// No description provided for @appZakat.
  ///
  /// In tr, this message translates to:
  /// **'Zekat'**
  String get appZakat;

  /// No description provided for @appZakatSub.
  ///
  /// In tr, this message translates to:
  /// **'Zekat hesaplayıcı'**
  String get appZakatSub;

  /// No description provided for @appHijri.
  ///
  /// In tr, this message translates to:
  /// **'Hicri Takvim'**
  String get appHijri;

  /// No description provided for @appHijriSub.
  ///
  /// In tr, this message translates to:
  /// **'Takvim + dini günler'**
  String get appHijriSub;

  /// No description provided for @appHadith.
  ///
  /// In tr, this message translates to:
  /// **'Hadis'**
  String get appHadith;

  /// No description provided for @appHadithSub.
  ///
  /// In tr, this message translates to:
  /// **'Günün hadisi'**
  String get appHadithSub;

  /// No description provided for @appDua.
  ///
  /// In tr, this message translates to:
  /// **'Dua & Zikir'**
  String get appDua;

  /// No description provided for @appDuaSub.
  ///
  /// In tr, this message translates to:
  /// **'Dua koleksiyonu'**
  String get appDuaSub;

  /// No description provided for @appSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get appSettings;

  /// No description provided for @appSettingsSub.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama ayarları'**
  String get appSettingsSub;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @sectionLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get sectionLocation;

  /// No description provided for @sectionPrayerTimes.
  ///
  /// In tr, this message translates to:
  /// **'Namaz Vakitleri'**
  String get sectionPrayerTimes;

  /// No description provided for @sectionNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get sectionNotifications;

  /// No description provided for @sectionGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get sectionGeneral;

  /// No description provided for @sectionData.
  ///
  /// In tr, this message translates to:
  /// **'Veri'**
  String get sectionData;

  /// No description provided for @settingLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingLanguage;

  /// No description provided for @settingTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingTheme;

  /// No description provided for @languageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get languageSystem;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get languageEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
