/// Uygulama geneli sabitler (tek kaynak).
class AppConstants {
  AppConstants._();

  // Varsayılan konum — İstanbul (konum seçilmeden önce).
  static const double defaultLatitude = 41.0082;
  static const double defaultLongitude = 28.9784;
  static const String defaultCity = 'İstanbul';

  // Bildirim kanalı — standart.
  static const String prayerChannelId = 'prayer_times_channel';
  static const String prayerChannelName = 'Namaz Vakitleri';
  static const String prayerChannelDesc = 'Namaz vakti bildirimleri';

  // Bildirim kanalı — ezan sesi.
  static const String ezanChannelId = 'ezan_prayer_channel';
  static const String ezanChannelName = 'Ezan Sesi';
  static const String ezanSoundFile = 'ezan_kisa'; // res/raw/ezan_kisa.mp3

  // Kalıcı bildirim (sonraki vakit göstergesi).
  static const String ongoingChannelId = 'ongoing_prayer_channel';
  static const String ongoingChannelName = 'Kalıcı Vakit Göstergesi';
  static const int ongoingNotifId = 1000;

  // Ağ.
  static const Duration httpTimeout = Duration(seconds: 10);
}
