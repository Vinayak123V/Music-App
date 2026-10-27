import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../data/models/song_model.dart';
import 'playback_state.dart';

class AudioPlayerService {
  AudioPlayer _player;
  final StreamController<DevotionalPlaybackState> _stateController =
      StreamController<DevotionalPlaybackState>.broadcast();

  DevotionalPlaybackState _state = const DevotionalPlaybackState();
  List<SongModel> _originalQueue = [];
  bool _isDisposed = false;
  bool _isRecovering = false;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _initAudioSession();
    _listenToPlayerStreams();
  }

  Stream<DevotionalPlaybackState> get stateStream => _stateController.stream;
  DevotionalPlaybackState get currentState => _state;
  AudioPlayer get player => _player;

  Future<void> _initAudioSession() async {
    if (kIsWeb) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _player.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              _player.play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      session.becomingNoisyEventStream.listen((_) {
        _player.pause();
      });
    } catch (e) {
      debugPrint('AudioSession init error: $e');
    }
  }

  void _listenToPlayerStreams() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();

    _playerStateSub = _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      final isBuffering = processingState == ProcessingState.buffering ||
          processingState == ProcessingState.loading;

      _updateState(_state.copyWith(
        isPlaying: isPlaying,
        isBuffering: isBuffering,
      ));

      if (processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
    }, onError: (error) async {
      final errStr = error.toString();
      // On Web, hot restarts leave previously allocated player IDs registered in the browser window
      if (errStr.contains('already exists')) {
        debugPrint('Stale Web platform player collision detected ($errStr). Auto-recovering player...');
        await _recoverPlayer();
        return;
      }
      _updateState(_state.copyWith(
        errorMessage: 'Playback error: $errStr',
      ));
    });

    _positionSub = _player.positionStream.listen((position) {
      _updateState(_state.copyWith(position: position));
    });

    _durationSub = _player.durationStream.listen((duration) {
      if (duration != null) {
        _updateState(_state.copyWith(duration: duration));
      }
    });
  }

  Future<void> _recoverPlayer() async {
    if (_isRecovering || _isDisposed) return;
    _isRecovering = true;
    try {
      _playerStateSub?.cancel();
      _positionSub?.cancel();
      _durationSub?.cancel();
      await _player.dispose().catchError((_) {});
    } catch (_) {}

    // Creating a fresh AudioPlayer advances the internal UUID to a unique uncollided ID
    _player = AudioPlayer();
    _listenToPlayerStreams();
    _isRecovering = false;

    _updateState(_state.copyWith(clearError: true));

    // Replay current track if one was queued
    if (_state.currentSong != null) {
      final song = _state.currentSong!;
      final queue = _state.queue;
      final idx = _state.currentIndex;
      await playSong(song, queue: queue, index: idx);
    }
  }

  void _updateState(DevotionalPlaybackState newState) {
    if (_isDisposed || _stateController.isClosed) return;
    _state = newState;
    _stateController.add(_state);
  }

  Future<void> playSong(
    SongModel song, {
    List<SongModel>? queue,
    int? index,
  }) async {
    try {
      final resolvedQueue = queue ?? (index != null && _state.queue.isNotEmpty ? _state.queue : [song]);
      final currentIndex = index ?? resolvedQueue.indexWhere((s) => s.id == song.id);

      _originalQueue = List.from(resolvedQueue);

      _updateState(_state.copyWith(
        currentSong: song,
        queue: resolvedQueue,
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        isBuffering: true,
        clearError: true,
      ));

      final audioUrl = song.audioUrl ?? '';
      if (audioUrl.isEmpty) {
        throw Exception('Audio stream URL is not available for "${song.title}"');
      }

      if (kIsWeb) {
        try {
          if (_player.playing) {
            await _player.stop();
          }
          await _player.setUrl(audioUrl);
        } catch (webErr) {
          debugPrint('Primary stream note on Web: $webErr');
          if (webErr.toString().contains('already exists')) {
            await _recoverPlayer();
            return;
          }
          // Fallback to high-availability CDN stream
          const fallbackUrl = 'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/41/Aum_sound.ogg/Aum_sound.ogg.mp3';
          try {
            await _player.setUrl(fallbackUrl);
          } catch (_) {}
        }
      } else {
        final mediaItem = MediaItem(
          id: song.id,
          album: song.deityId.toUpperCase(),
          title: song.title,
          artist: song.artist,
          artUri: song.artworkUrl != null && song.artworkUrl!.isNotEmpty
              ? Uri.tryParse(song.artworkUrl!)
              : null,
          duration: song.durationSeconds != null
              ? Duration(seconds: song.durationSeconds!)
              : null,
        );

        final audioSource = AudioSource.uri(
          Uri.parse(audioUrl),
          tag: mediaItem,
        );

        try {
          await _player.setAudioSource(audioSource);
        } catch (srcErr) {
          debugPrint('AudioSource error ($srcErr). Attempting direct URL...');
          await _player.setUrl(audioUrl);
        }
      }

      await _player.play();
    } catch (e) {
      debugPrint('Error playing song: $e');
      if (e.toString().contains('already exists')) {
        await _recoverPlayer();
        return;
      }
      _updateState(_state.copyWith(
        isBuffering: false,
        isPlaying: false,
        errorMessage: 'Playback error: ${e.toString()}',
      ));
    }
  }

  Future<void> playPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (_state.currentSong != null) {
          await _player.play();
        }
      }
    } catch (e) {
      if (e.toString().contains('already exists')) {
        await _recoverPlayer();
      } else {
        debugPrint('playPause error: $e');
      }
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('seek error: $e');
    }
  }

  Future<void> next() async {
    if (_state.queue.isEmpty) return;
    int nextIndex = _state.currentIndex + 1;
    if (nextIndex >= _state.queue.length) {
      if (_state.loopMode == AudioLoopMode.all) {
        nextIndex = 0;
      } else {
        return;
      }
    }
    await playSong(
      _state.queue[nextIndex],
      queue: _state.queue,
      index: nextIndex,
    );
  }

  Future<void> previous() async {
    if (_state.queue.isEmpty) return;
    if (_state.position.inSeconds > 4) {
      await seek(Duration.zero);
      return;
    }
    int prevIndex = _state.currentIndex - 1;
    if (prevIndex < 0) {
      if (_state.loopMode == AudioLoopMode.all) {
        prevIndex = _state.queue.length - 1;
      } else {
        prevIndex = 0;
      }
    }
    await playSong(
      _state.queue[prevIndex],
      queue: _state.queue,
      index: prevIndex,
    );
  }

  void toggleShuffle() {
    final nextShuffle = !_state.isShuffleEnabled;
    if (nextShuffle) {
      final List<SongModel> shuffled = List.from(_state.queue)..shuffle();
      if (_state.currentSong != null) {
        shuffled.removeWhere((s) => s.id == _state.currentSong!.id);
        shuffled.insert(0, _state.currentSong!);
      }
      _updateState(_state.copyWith(
        isShuffleEnabled: true,
        queue: shuffled,
        currentIndex: 0,
      ));
    } else {
      final currentIndex = _state.currentSong != null
          ? _originalQueue.indexWhere((s) => s.id == _state.currentSong!.id)
          : 0;
      _updateState(_state.copyWith(
        isShuffleEnabled: false,
        queue: List.from(_originalQueue),
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
      ));
    }
  }

  void toggleLoopMode() {
    AudioLoopMode nextMode;
    switch (_state.loopMode) {
      case AudioLoopMode.off:
        nextMode = AudioLoopMode.all;
        _player.setLoopMode(LoopMode.all);
        break;
      case AudioLoopMode.all:
        nextMode = AudioLoopMode.one;
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioLoopMode.one:
        nextMode = AudioLoopMode.off;
        _player.setLoopMode(LoopMode.off);
        break;
    }
    _updateState(_state.copyWith(loopMode: nextMode));
  }

  void _handleTrackCompleted() {
    if (_state.loopMode == AudioLoopMode.one) {
      seek(Duration.zero);
      _player.play();
    } else if (_state.hasNext || _state.loopMode == AudioLoopMode.all) {
      next();
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _updateState(const DevotionalPlaybackState());
  }

  void dispose() {
    _isDisposed = true;
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.dispose().catchError((_) {});
    _stateController.close();
  }
}
