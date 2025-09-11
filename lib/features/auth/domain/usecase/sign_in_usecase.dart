import 'package:fin_track/features/auth/domain/model/user.dart';
import 'package:fin_track/features/auth/domain/repository/user_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<UserModel> call(String email, String password) async {
    try {
      return await repository.signIn(email, password);
    } catch (e) {
      rethrow;
    }
  }
}