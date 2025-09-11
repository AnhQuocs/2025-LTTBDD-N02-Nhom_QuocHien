import 'package:fin_track/features/auth/domain/repository/user_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() => repository.signOut();
}