import 'package:fin_track/features/transaction/domain/repositories/transaction_repository.dart';

class GetTotalExpenseUseCase {
  final TransactionRepository repository;

  GetTotalExpenseUseCase(this.repository);

  double call() {
    return repository.getTotalExpense();
  }
}