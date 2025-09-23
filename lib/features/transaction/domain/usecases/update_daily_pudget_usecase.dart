import '../entities/daily_budget.dart';
import '../repositories/transaction_repository.dart';

class UpdateDailyBudgetUseCase {
  final TransactionRepository repository;

  UpdateDailyBudgetUseCase(this.repository);

  Future<void> call(DailyBudget dailyBudget) async {
    await repository.updateDailyBudget(dailyBudget);
  }
}