import 'package:fin_track/features/transaction/domain/entities/transaction.dart';

import '../../repositories/transaction_repository.dart';

class GetTransactionsByCategoryIdUseCase {
  final TransactionRepository repository;
  GetTransactionsByCategoryIdUseCase(this.repository);

  List<Transaction> call(String categoryId, String? userId) {
    return repository.getTransactionsByCategoryId(categoryId, userId);
  }
}