import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vakitli/models/radio_station.dart';
import 'package:vakitli/services/radio_service.dart';

class RadioProvider extends ChangeNotifier {
  final RadioService _service = RadioService();

  static const List<RadioStation> stations = [
    RadioStation(
      id: 'mecca',
      name: 'Mekke Canlı',
      description: 'Mescid-i Haram canlı yayını',
      streamUrl: 'https://n03.radiojar.com/8s5u5tpdtwzuv',
    ),
    RadioStation(
      id: 'medina',
      name: 'Medine Canlı',
      description: 'Mescid-i Nebevî canlı yayını',
      streamUrl: 'https://n03.radiojar.com/qs0mq8rkg1quv',
    ),
    RadioStation(
      id: 'husary',
      name: 'Mahmud Halil Husari',
      description: 'Mahmud Halil el-Husari tilâveti',
      streamUrl: 'https://live.mp3quran.net/husary/stream.mp3',
    ),
    RadioStation(
      id: 'quran_kareem',
      name: 'Kur\'an-ı Kerim',
      description: 'Sürekli Kur\'an-ı Kerim yayını',
      streamUrl: 'https://stream.radiojar.com/4xng22g9xyquv',
    ),
    RadioStation(
      id: 'murattal',
      name: 'Mürâttel',
      description: 'Mürâttel okuyuş yayını',
      streamUrl: 'https://stream.radiojar.com/0tpy1h0kxtzuv',
    ),
    RadioStation(
      id: 'minshawi',
      name: 'Muhammed Sıddık Minşâvî',
      description: 'Minşâvî mücevved tilâveti',
      streamUrl: 'https://live.mp3quran.net/minsh/stream.mp3',
    ),
  ];

  RadioStation? _currentStation;
  bool _isPlaying = false;
  bool _isBuffering = false;
  String? _error;

  RadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  String? get error => _error;
  bool get hasStation => _currentStation != null;

  Future<void> initialize() async {
    await _service.initialize();

    _service.player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      _error = null;
      notifyListeners();
    });

    _service.player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        _error = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
        _isPlaying = false;
        _isBuffering = false;
        notifyListeners();
      },
    );
  }

  Future<void> selectStation(RadioStation station) async {
    if (_currentStation?.id == station.id && _isPlaying) {
      await _service.pause();
      return;
    }
    _currentStation = station;
    _error = null;
    _isBuffering = true;
    notifyListeners();
    try {
      await _service.play(station.streamUrl);
    } on TimeoutException {
      _error = 'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.';
      _isPlaying = false;
      _isBuffering = false;
      notifyListeners();
    } catch (e) {
      _error = 'Kanal açılamadı. Bağlantınızı kontrol edin.';
      _isPlaying = false;
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentStation == null) return;
    if (_isPlaying) {
      await _service.pause();
    } else {
      await _service.resume();
    }
  }

  Future<void> stop() async {
    await _service.stop();
    _currentStation = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
