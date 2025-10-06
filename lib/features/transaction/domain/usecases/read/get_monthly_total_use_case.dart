import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class GetMonthlyTotalUseCase {
  final TransactionRepository repository;

  GetMonthlyTotalUseCase(this.repository);

  Future<Map<String, double>> execute({
    required int year,
    required int month,
    String? userId,
  }) async {
    final income = await repository.getMonthlyAmount(
      year: year,
      month: month,
      type: TransactionType.Income,
      userId: userId,
    );

    final expense = await repository.getMonthlyAmount(
      year: year,
      month: month,
      type: TransactionType.Expense,
      userId: userId,
    );

    final balance = income - expense;

    return {
      'income': income,
      'expense': expense,
      'balance': balance,
    };
  }
}