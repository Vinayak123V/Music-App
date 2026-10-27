import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';
import '../models/user_profile_model.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  final StreamController<UserProfileModel?> _authStreamController =
      StreamController<UserProfileModel?>.broadcast();

  UserProfileModel? _currentUser;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore {
    if (AppConfig.isFirebaseInitialized && _firebaseAuth != null) {
      _firebaseAuth!.authStateChanges().listen((User? user) async {
        if (user == null) {
          _currentUser = null;
          _authStreamController.add(null);
        } else {
          final isAdmin = await verifyAdminAccess(user.uid);
          _currentUser = UserProfileModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? (isAdmin ? 'Admin' : 'User'),
            isAdmin: isAdmin,
          );
          _authStreamController.add(_currentUser);
        }
      });
    }
  }

  @override
  Stream<UserProfileModel?> get authStateChanges => _authStreamController.stream;

  @override
  UserProfileModel? get currentUser => _currentUser;

  @override
  Future<UserProfileModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (AppConfig.isFirebaseInitialized && _firebaseAuth != null) {
        final credential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final uid = credential.user!.uid;
        final isAdmin = await verifyAdminAccess(uid);

        if (!isAdmin) {
          await _firebaseAuth!.signOut();
          throw const AuthFailure('Access denied. This account does not have administrator privileges.');
        }

        _currentUser = UserProfileModel(
          uid: uid,
          email: credential.user!.email ?? email,
          displayName: credential.user!.displayName ?? 'Admin',
          isAdmin: true,
        );
        _authStreamController.add(_currentUser);
        return _currentUser!;
      } else {
        // Fallback demo mode for initial local development before Firebase project linking
        if (email.toLowerCase().contains('admin') && password.length >= 6) {
          _currentUser = UserProfileModel(
            uid: 'demo-admin-uid-1008',
            email: email,
            displayName: 'Devotional Administrator',
            isAdmin: true,
          );
          _authStreamController.add(_currentUser);
          return _currentUser!;
        } else {
          throw const AuthFailure('Invalid credentials. In demo mode, use an email containing "admin" and min 6 char password.');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed: ${e.message}';
      if (e.code == 'user-not-found') message = 'No administrator account found with this email.';
      if (e.code == 'wrong-password') message = 'Incorrect password.';
      if (e.code == 'invalid-email') message = 'Please enter a valid email address.';
      if (e.code == 'user-disabled') message = 'This account has been disabled.';
      throw AuthFailure(message, code: e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    if (AppConfig.isFirebaseInitialized && _firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }
    _currentUser = null;
    _authStreamController.add(null);
  }

  @override
  Future<bool> verifyAdminAccess(String uid) async {
    if (!AppConfig.isFirebaseInitialized || _firestore == null) {
      return _currentUser?.isAdmin ?? true;
    }
    try {
      // 1. Check custom claim if available
      final idTokenResult = await _firebaseAuth?.currentUser?.getIdTokenResult();
      if (idTokenResult?.claims?['admin'] == true) {
        return true;
      }

      // 2. Check Firestore /admins/{uid} collection
      final adminDoc = await _firestore!.collection('admins').doc(uid).get();
      return adminDoc.exists;
    } catch (_) {
      return false;
    }
  }
}
