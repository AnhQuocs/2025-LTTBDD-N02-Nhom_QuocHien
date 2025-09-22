import '../../domain/model/user.dart';
import '../repository/user_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserModel?> call() async {
    return repository.getUser();
  }
}