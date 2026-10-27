import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

/// Transparent platform wrapper that catches and recovers from Flutter Web
/// "Platform player [ID] already exists" exceptions caused by browser JS
/// lifecycle persistence across debug hot-restarts.
class WebResilientAudioPlatform extends JustAudioPlatform {
  final JustAudioPlatform _underlying;

  WebResilientAudioPlatform(this._underlying);

  static void ensureInitialized() {
    if (kIsWeb) {
      if (JustAudioPlatform.instance is! WebResilientAudioPlatform) {
        JustAudioPlatform.instance = WebResilientAudioPlatform(JustAudioPlatform.instance);
        debugPrint('[WebResilientAudioPlatform] Registered web audio lifecycle guard.');
      }
    }
  }

  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    try {
      return await _underlying.init(request);
    } on PlatformException catch (e) {
      if (e.message?.contains('already exists') == true) {
        debugPrint('[WebResilientAudioPlatform] Detected existing player ID ${request.id}. Forcing cleanup before re-init...');
        try {
          await _underlying.disposePlayer(DisposePlayerRequest(id: request.id));
        } catch (_) {}
        return await _underlying.init(request);
      }
      rethrow;
    }
  }

  @override
  Future<DisposePlayerResponse> disposePlayer(DisposePlayerRequest request) {
    return _underlying.disposePlayer(request);
  }

  @override
  Future<DisposeAllPlayersResponse> disposeAllPlayers(DisposeAllPlayersRequest request) {
    return _underlying.disposeAllPlayers(request);
  }
}
