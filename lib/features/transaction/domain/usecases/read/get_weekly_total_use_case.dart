import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class GetWeeklyTotalUseCase {
  final TransactionRepository repository;

  GetWeeklyTotalUseCase(this.repository);

  /// Trả về tổng income, expense và balance tuần
  Future<Map<String, double>> execute({
    required DateTime startOfWeek,
    required DateTime endOfWeek,
    String? userId,
  }) async {
    final income = await repository.getWeeklyAmount(
      startOfWeek: startOfWeek,
      endOfWeek: endOfWeek,
      type: TransactionType.Income,
      userId: userId,
    );

    final expense = await repository.getWeeklyAmount(
      startOfWeek: startOfWeek,
      endOfWeek: endOfWeek,
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