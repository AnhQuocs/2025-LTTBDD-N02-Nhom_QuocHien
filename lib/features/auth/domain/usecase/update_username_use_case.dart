import 'package:fin_track/features/auth/domain/model/user.dart';

import '../repository/user_repository.dart';

class UpdateUsernameUseCase {
  final AuthRepository repository;

  UpdateUsernameUseCase(this.repository);

  Future<UserModel> call(String newUsername) async {
    return await repository.updateUsername(newUsername);
  }
}