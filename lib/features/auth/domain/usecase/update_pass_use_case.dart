import '../model/user.dart';
import '../repository/user_repository.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<UserModel> call(String newPassword) async {
    return await repository.updatePassword(newPassword);
  }
}