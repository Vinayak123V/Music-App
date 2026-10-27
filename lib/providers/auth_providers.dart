import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/auth/auth_repository.dart';
import '../data/auth/firebase_auth_repository.dart';
import '../data/models/user_profile_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  FirebaseAuth? auth;
  FirebaseFirestore? firestore;

  if (AppConfig.isFirebaseInitialized) {
    try {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
    } catch (_) {}
  }

  return FirebaseAuthRepository(
    firebaseAuth: auth,
    firestore: firestore,
  );
});

final authStateProvider = StreamProvider<UserProfileModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

final currentUserProvider = Provider<UserProfileModel?>((ref) {
  return ref.watch(authStateProvider).value ?? ref.watch(authRepositoryProvider).currentUser;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});
