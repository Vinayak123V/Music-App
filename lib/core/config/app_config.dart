import 'package:flutter/foundation.dart';

class AppConfig {
  static const bool useFirebaseEmulator = false;
  static const String emulatorHost = '127.0.0.1';
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int storagePort = 9199;

  // Maximum audio file size in bytes (50MB)
  static const int maxAudioFileSizeBytes = 50 * 1024 * 1024;

  // Maximum artwork file size in bytes (5MB)
  static const int maxArtworkFileSizeBytes = 5 * 1024 * 1024;

  // Allowed audio MIME extensions
  static const List<String> allowedAudioExtensions = ['mp3', 'm4a', 'aac', 'wav', 'ogg'];
  static const List<String> allowedArtworkExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  static bool isFirebaseInitialized = false;

  static void markFirebaseInitialized(bool value) {
    isFirebaseInitialized = value;
    debugPrint('Firebase initialized status: $isFirebaseInitialized');
  }
}
