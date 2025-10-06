import '../../repositories/transaction_repository.dart';

class GetDailyProgressUseCase {
  final TransactionRepository repository;

  GetDailyProgressUseCase(this.repository);

  double call(DateTime date) {
    return repository.getDailyProgress(date);
  }
}