import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android "Rahatsız Etmeyin" (DND) kontrolü — native MethodChannel.
class DndService {
  static const MethodChannel _channel = MethodChannel('vakitli/dnd');

  Future<bool> hasAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasAccess') ?? false;
    } catch (e) {
      debugPrint('DndService.hasAccess hata: $e');
      return false;
    }
  }

  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openSettings');
    } catch (e) {
      debugPrint('DndService.openSettings hata: $e');
    }
  }

  /// DND'yi açar (silent=true → sadece sessiz) veya kapatır.
  Future<bool> setSilent(bool silent) async {
    try {
      return await _channel
              .invokeMethod<bool>('setSilent', {'silent': silent}) ??
          false;
    } catch (e) {
      debugPrint('DndService.setSilent hata: $e');
      return false;
    }
  }
}
