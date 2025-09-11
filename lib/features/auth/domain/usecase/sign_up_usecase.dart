import 'package:fin_track/features/auth/domain/model/user.dart';
import 'package:fin_track/features/auth/domain/repository/user_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserModel> call(String email, String password, String username) async {
    try {
      return await repository.signUp(email, password, username);
    } catch (e) {
      rethrow;
    }
  }
}