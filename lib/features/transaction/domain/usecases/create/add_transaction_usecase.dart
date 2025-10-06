import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<void> call(Transaction tx) async {
    await repository.addTransaction(tx);
  }
}