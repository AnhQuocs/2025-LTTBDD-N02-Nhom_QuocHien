import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetAllTransactionsUseCase {
  final TransactionRepository repository;

  GetAllTransactionsUseCase(this.repository);

  List<Transaction> call({String? userId}) {
    return repository.getAllTransactions(userId: userId);
  }
}