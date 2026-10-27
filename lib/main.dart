import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'providers/favorites_providers.dart';
import 'services/audio/web_audio_platform_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Guard Web audio player instances against hot-restart ID collisions
  WebResilientAudioPlatform.ensureInitialized();

  // 2. Initialize Background Audio for Android lock-screen and notification controls (mobile only)
  if (!kIsWeb) {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.bhaktimusic.app.audio',
        androidNotificationChannelName: 'Bhakti Music Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      );
    } catch (e) {
      debugPrint('JustAudioBackground init note: $e');
    }
  }

  // 2. Initialize SharedPreferences for local favorites, playlists & settings
  final sharedPreferences = await SharedPreferences.getInstance();

  // 3. Initialize Firebase Backend
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppConfig.markFirebaseInitialized(true);
    debugPrint('Firebase successfully initialized for ${kIsWeb ? "Web" : "Android"}.');
  } catch (e) {
    debugPrint('Firebase setup note: Using local verified devotional catalog ($e). '
        'Run `flutterfire configure` or set your project keys in firebase_options.dart.');
    AppConfig.markFirebaseInitialized(false);
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const BhaktiMusicApp(),
    ),
  );
}
