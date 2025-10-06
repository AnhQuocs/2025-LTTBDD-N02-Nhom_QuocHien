import '../../repositories/transaction_repository.dart';

class GetTotalBalanceUseCase {
  final TransactionRepository repository;

  GetTotalBalanceUseCase(this.repository);

  double call() {
    return repository.getTotalBalance();
  }
}