import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/model/user.dart';
import '../../domain/repository/user_repository.dart';
import '../source/firebase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService service;

  AuthRepositoryImpl(this.service);

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await service.signIn(email, password);
      final user = credential.user!;
      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String username) async {
    try {
      final credential = await service.signUp(email, password);
      final user = credential.user!;

      await user.updateDisplayName(username);

      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: username,
      );
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() => service.signOut();

  @override
  Future<void> resetPassword(String email) => service.resetPassword(email);

  @override
  Stream<UserModel?> authStateChanges() {
    return service.authStateChanges().map((user) =>
    user == null ? null : UserModel(uid: user.uid, email: user.email, displayName: user.displayName));
  }
}