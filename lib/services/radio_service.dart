import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class RadioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<void> play(String url) async {
    await _player
        .setUrl(url)
        .timeout(const Duration(seconds: 15));
    await _player.play();
  }

  Future<void> resume() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
