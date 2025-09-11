import '../model/user.dart';

abstract class AuthRepository {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<UserModel?> authStateChanges();
}