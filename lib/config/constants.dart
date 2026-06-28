/// Uygulama geneli sabitler (tek kaynak).
class AppConstants {
  AppConstants._();

  // Varsayılan konum — İstanbul (konum seçilmeden önce).
  static const double defaultLatitude = 41.0082;
  static const double defaultLongitude = 28.9784;
  static const String defaultCity = 'İstanbul';

  // Bildirim kanalı.
  static const String prayerChannelId = 'prayer_times_channel';
  static const String prayerChannelName = 'Namaz Vakitleri';
  static const String prayerChannelDesc = 'Namaz vakti bildirimleri';

  // Ağ.
  static const Duration httpTimeout = Duration(seconds: 10);
}
