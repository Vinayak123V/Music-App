import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio/audio_player_service.dart';
import '../services/audio/playback_state.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final playbackStateProvider = StreamProvider<DevotionalPlaybackState>((ref) {
  final playerService = ref.watch(audioPlayerServiceProvider);
  return playerService.stateStream;
});

final currentPlaybackStateProvider = Provider<DevotionalPlaybackState>((ref) {
  final asyncState = ref.watch(playbackStateProvider);
  return asyncState.value ?? ref.watch(audioPlayerServiceProvider).currentState;
});
