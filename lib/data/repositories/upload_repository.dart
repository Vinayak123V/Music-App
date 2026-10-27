import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';

abstract class UploadRepository {
  Future<String> uploadAudioFile({
    required String songId,
    required Uint8List fileBytes,
    required String fileName,
    int? fileSize,
    void Function(double progress)? onProgress,
  });

  Future<String> uploadArtworkFile({
    required String songId,
    required Uint8List fileBytes,
    required String fileName,
    int? fileSize,
    void Function(double progress)? onProgress,
  });

  Future<void> deleteAudioFile(String storagePath);
  Future<void> deleteArtworkFile(String artworkPath);
}

class FirebaseStorageUploadRepository implements UploadRepository {
  final FirebaseStorage? _storage;

  FirebaseStorageUploadRepository({FirebaseStorage? storage})
      : _storage = storage;

  @override
  Future<String> uploadAudioFile({
    required String songId,
    required Uint8List fileBytes,
    required String fileName,
    int? fileSize,
    void Function(double progress)? onProgress,
  }) async {
    // 1. Validate file extension
    final ext = fileName.split('.').last.toLowerCase();
    if (!AppConfig.allowedAudioExtensions.contains(ext)) {
      throw UploadFailure(
        'Invalid audio format (.$ext). Allowed formats: ${AppConfig.allowedAudioExtensions.join(", ")}',
      );
    }

    // 2. Validate file size (max 50MB)
    if (fileSize != null && fileSize > AppConfig.maxAudioFileSizeBytes) {
      throw const UploadFailure(
        'Audio file exceeds maximum allowed limit of 50 MB.',
      );
    }

    final String storagePath = 'audio/$songId/original.mp3';

    if (AppConfig.isFirebaseInitialized && _storage != null) {
      try {
        final ref = _storage!.ref().child(storagePath);
        final metadata = SettableMetadata(
          contentType: 'audio/mpeg',
          customMetadata: {'songId': songId, 'originalName': fileName},
        );

        final uploadTask = ref.putData(fileBytes, metadata);

        if (onProgress != null) {
          uploadTask.snapshotEvents.listen((event) {
            final progress = event.bytesTransferred / event.totalBytes;
            onProgress(progress);
          });
        }

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        throw UploadFailure('Failed to upload audio to Cloud Storage: $e');
      }
    } else {
      // In local demo mode: simulate upload progress and return playable stream URL
      if (onProgress != null) {
        for (double p = 0.2; p <= 1.0; p += 0.2) {
          await Future.delayed(const Duration(milliseconds: 100));
          onProgress(p);
        }
      }
      return 'https://archive.org/download/ShivaTandavStotram_201604/Shiva%20Tandav%20Stotram.mp3';
    }
  }

  @override
  Future<String> uploadArtworkFile({
    required String songId,
    required Uint8List fileBytes,
    required String fileName,
    int? fileSize,
    void Function(double progress)? onProgress,
  }) async {
    final ext = fileName.split('.').last.toLowerCase();
    if (!AppConfig.allowedArtworkExtensions.contains(ext)) {
      throw UploadFailure(
        'Invalid image format (.$ext). Allowed formats: ${AppConfig.allowedArtworkExtensions.join(", ")}',
      );
    }

    if (fileSize != null && fileSize > AppConfig.maxArtworkFileSizeBytes) {
      throw const UploadFailure(
        'Cover artwork exceeds maximum allowed limit of 5 MB.',
      );
    }

    final String storagePath = 'artwork/$songId/cover.jpg';

    if (AppConfig.isFirebaseInitialized && _storage != null) {
      try {
        final ref = _storage!.ref().child(storagePath);
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'songId': songId},
        );

        final uploadTask = ref.putData(fileBytes, metadata);

        if (onProgress != null) {
          uploadTask.snapshotEvents.listen((event) {
            final progress = event.bytesTransferred / event.totalBytes;
            onProgress(progress);
          });
        }

        final snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        throw UploadFailure('Failed to upload artwork to Cloud Storage: $e');
      }
    } else {
      if (onProgress != null) {
        onProgress(1.0);
      }
      return 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&auto=format&fit=crop&q=80';
    }
  }

  @override
  Future<void> deleteAudioFile(String storagePath) async {
    if (AppConfig.isFirebaseInitialized && _storage != null) {
      try {
        await _storage!.ref(storagePath).delete();
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteArtworkFile(String artworkPath) async {
    if (AppConfig.isFirebaseInitialized && _storage != null) {
      try {
        await _storage!.ref(artworkPath).delete();
      } catch (_) {}
    }
  }
}
