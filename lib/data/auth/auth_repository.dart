import '../models/user_profile_model.dart';

abstract class AuthRepository {
  Stream<UserProfileModel?> get authStateChanges;
  UserProfileModel? get currentUser;

  Future<UserProfileModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<bool> verifyAdminAccess(String uid);
}
