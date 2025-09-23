import '../entities/daily_budget.dart';
import '../repositories/transaction_repository.dart';

class GetDailyBudgetUseCase {
  final TransactionRepository repository;

  GetDailyBudgetUseCase(this.repository);

  Future<DailyBudget?> call(DateTime date) async {
    return await repository.getDailyBudget(date);
  }
}