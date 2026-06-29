import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakitli/config/constants.dart';
import 'package:vakitli/models/prayer_time.dart';
import 'package:vakitli/services/api_service.dart';
import 'package:vakitli/services/prayer_cache_service.dart';
import 'package:vakitli/services/widget_service.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerProvider({ApiService? apiService, PrayerCacheService? cache})
      : _apiService = apiService ?? ApiService(),
        _cache = cache ?? PrayerCacheService();

  final ApiService _apiService;
  final PrayerCacheService _cache;

  /// Vakitler güncellenince tetiklenir (AlarmProvider yeniden zamanlasın diye).
  VoidCallback? onPrayerTimesUpdated;

  /// Bir namaz vakti girdiğinde tetiklenir (DND sessiz mod için).
  void Function(String prayerName)? onPrayerEntered;

  static const String _methodKey = 'calculation_method';
  static const String _hijriAdjustKey = 'hijri_adjustment';
  static const String _schoolKey = 'asr_school';
  static const String _latAdjustKey = 'latitude_adjustment';

  /// Asr mezhebi (Aladhan `school`).
  static const Map<int, String> asrSchools = {
    0: 'Standart (Şâfiî, Mâlikî, Hanbelî)',
    1: 'Hanefî',
  };

  /// Yüksek enlem kuralı (Aladhan `latitudeAdjustmentMethod`).
  static const Map<int, String> latitudeRules = {
    0: 'Otomatik',
    1: 'Gece Ortası',
    2: 'Yedide Bir',
    3: 'Açı Temelli',
  };

  /// Aladhan hesaplama metotları (id -> ad).
  static const Map<int, String> calculationMethods = {
    13: 'Diyanet İşleri (Türkiye)',
    3: 'Müslüman Dünya Birliği (MWL)',
    2: 'ISNA (Kuzey Amerika)',
    4: 'Ümmü\'l-Kurâ (Mekke)',
    5: 'Mısır Genel Otoritesi',
    1: 'Karaçi (Pakistan)',
    8: 'Körfez Bölgesi',
    9: 'Kuveyt',
    10: 'Katar',
    12: 'Fransa (UOIF)',
  };

  PrayerTime? _todayPrayer;
  PrayerTime? _tomorrowPrayer;
  bool _isLoading = false;
  String? _error;
  Timer? _prayerCheckTimer;
  PrayerEntry? _nextPrayer;
  double _latitude = AppConstants.defaultLatitude;
  double _longitude = AppConstants.defaultLongitude;
  String _locationName = AppConstants.defaultCity;
  bool _hasFetched = false;
  int _method = ApiService.defaultMethod;
  int _hijriAdjustment = 0;
  int _school = 0;
  int _latitudeAdjustment = 0;
  bool _isOffline = false;

  int get calculationMethod => _method;
  String get calculationMethodName =>
      calculationMethods[_method] ?? 'Bilinmeyen';

  /// Hicri tarih gün ofseti (-2..+2). Aladhan `adjustment` parametresi.
  int get hijriAdjustment => _hijriAdjustment;

  int get asrSchool => _school;
  String get asrSchoolName => asrSchools[_school] ?? 'Standart';
  int get latitudeAdjustment => _latitudeAdjustment;
  String get latitudeRuleName => latitudeRules[_latitudeAdjustment] ?? 'Otomatik';

  /// Ağdan güncellenemeyip cache gösteriliyor mu.
  bool get isOffline => _isOffline;

  PrayerTime? get todayPrayer => _todayPrayer;
  PrayerTime? get tomorrowPrayer => _tomorrowPrayer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PrayerEntry? get nextPrayer => _nextPrayer;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get locationName => _locationName;

  /// Sonraki namaz vaktinin DateTime değeri (CountdownTimer widget'ı kullanır)
  DateTime? get nextPrayerTime {
    if (_todayPrayer == null || _nextPrayer == null) return null;
    final now = DateTime.now();
    final target = _nextPrayer!.timeAsDateTime;
    if (target.isAfter(now)) return target;
    return target.add(const Duration(days: 1));
  }

  /// Uygulama açılışında kayıtlı metodu yükle + varsayılan koordinatlarla fetch
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _method = prefs.getInt(_methodKey) ?? ApiService.defaultMethod;
    _hijriAdjustment = prefs.getInt(_hijriAdjustKey) ?? 0;
    _school = prefs.getInt(_schoolKey) ?? 0;
    _latitudeAdjustment = prefs.getInt(_latAdjustKey) ?? 0;
    await fetchTodayPrayerTimes();
  }

  /// MadhabProvider değişince ProxyProvider2 tarafından çağrılır.
  void updateAsrSchool(int school) {
    if (_school == school) return;
    _school = school;
    fetchTodayPrayerTimes();
  }

  /// Asr mezhebini değiştirir, kaydeder, yeniden çeker.
  Future<void> setAsrSchool(int school) async {
    if (_school == school) return;
    _school = school;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_schoolKey, school);
    await fetchTodayPrayerTimes();
  }

  /// Yüksek enlem kuralını değiştirir, kaydeder, yeniden çeker.
  Future<void> setLatitudeAdjustment(int value) async {
    if (_latitudeAdjustment == value) return;
    _latitudeAdjustment = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_latAdjustKey, value);
    await fetchTodayPrayerTimes();
  }

  /// Hesaplama metodunu değiştirir, kaydeder ve vakitleri yeniden çeker.
  Future<void> setCalculationMethod(int method) async {
    if (_method == method) return;
    _method = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_methodKey, method);
    await fetchTodayPrayerTimes();
  }

  /// Hicri gün ofsetini değiştirir (-2..+2), kaydeder ve yeniden çeker.
  Future<void> setHijriAdjustment(int adjustment) async {
    final clamped = adjustment.clamp(-2, 2);
    if (_hijriAdjustment == clamped) return;
    _hijriAdjustment = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hijriAdjustKey, clamped);
    await fetchTodayPrayerTimes();
  }

  void setLocation(double lat, double lng, String name) {
    if (_latitude == lat && _longitude == lng && _locationName == name) {
      if (!_hasFetched) {
        fetchTodayPrayerTimes();
      }
      return;
    }
    _latitude = lat;
    _longitude = lng;
    _locationName = name;
    fetchTodayPrayerTimes();
  }

  Future<void> fetchTodayPrayerTimes() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    _error = null;

    // 1) Stale-while-revalidate: önce cache'i göster (varsa anında).
    final cachedToday = await _cache.get(_latitude, _longitude, now);
    final cachedTomorrow = await _cache.get(_latitude, _longitude, tomorrow);
    if (cachedToday != null) {
      _todayPrayer = cachedToday;
      _tomorrowPrayer = cachedTomorrow;
      _hasFetched = true;
      _calculateNextPrayer();
      _startPrayerCheckTimer();
      _updateWidget();
      _isLoading = false;
      notifyListeners();
      onPrayerTimesUpdated?.call();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    // 2) Ağdan güncelle (bugün + yarın).
    try {
      final today = await _apiService.getDailyPrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        method: _method,
        hijriAdjustment: _hijriAdjustment,
        school: _school,
        latitudeAdjustment: _latitudeAdjustment,
        date: now,
      );
      final next = await _apiService.getDailyPrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        method: _method,
        hijriAdjustment: _hijriAdjustment,
        school: _school,
        latitudeAdjustment: _latitudeAdjustment,
        date: tomorrow,
      );

      if (today != null) {
        _todayPrayer = today;
        _tomorrowPrayer = next;
        _error = null;
        _isOffline = false;
        _hasFetched = true;
        await _cache.put(_latitude, _longitude, now, today);
        if (next != null) {
          await _cache.put(_latitude, _longitude, tomorrow, next);
        }
        _calculateNextPrayer();
        _startPrayerCheckTimer();
        _updateWidget();
        onPrayerTimesUpdated?.call();
        _prefetchMonth();
      } else if (_todayPrayer == null) {
        _error = 'Namaz vakitleri alınamadı. Lütfen tekrar deneyin.';
      } else {
        _isOffline = true; // cache gösteriliyor, ağ güncellenemedi
      }
    } catch (e) {
      // Cache varsa offline çalışmaya devam; yoksa hata göster.
      if (_todayPrayer == null) {
        _error = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
      } else {
        _isOffline = true;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ay verisini arka planda cache'ler (gelecek günler offline kullanılır).
  Future<void> _prefetchMonth() async {
    try {
      final monthly = await _apiService.getMonthlyPrayerTimes(
        latitude: _latitude,
        longitude: _longitude,
        method: _method,
        hijriAdjustment: _hijriAdjustment,
        school: _school,
        latitudeAdjustment: _latitudeAdjustment,
      );
      if (monthly.isNotEmpty) {
        await _cache.putMany(_latitude, _longitude, monthly);
      }
    } catch (_) {
      // Prefetch best-effort; hata yutulur.
    }
  }

  void _calculateNextPrayer() {
    if (_todayPrayer == null) return;

    final now = DateTime.now();
    final entries = _todayPrayer!.entries;

    for (final entry in entries) {
      if (entry.timeAsDateTime.isAfter(now)) {
        _nextPrayer = entry;
        return;
      }
    }

    // Tüm vakitler geçmişse, yarının ilk vakti (İmsak)
    _nextPrayer = entries.first;
  }

  /// Ana ekran widget'ını sonraki vakit bilgisiyle günceller.
  void _updateWidget() {
    final next = _nextPrayer;
    final target = nextPrayerTime;
    if (next == null || target == null) return;

    final diff = target.difference(DateTime.now());
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    final remaining =
        h > 0 ? '$h sa $m dk kaldı' : '$m dk kaldı';

    WidgetService.update(
      prayerName: next.name,
      time: next.time,
      remaining: remaining,
      city: _locationName,
    );
  }

  /// Her 30 saniyede vakit geçişini kontrol et (her saniye rebuild yerine)
  void _startPrayerCheckTimer() {
    _prayerCheckTimer?.cancel();
    _prayerCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final oldNext = _nextPrayer?.name;
      _calculateNextPrayer();
      if (_nextPrayer?.name != oldNext) {
        // oldNext vakti girdi (artık geçmişte) → DND tetikle.
        if (oldNext != null) onPrayerEntered?.call(oldNext);
        _updateWidget();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _prayerCheckTimer?.cancel();
    super.dispose();
  }
}
