import '../entities/daily_budget.dart';
import '../entities/daily_summary.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(Transaction tx);
  Future<void> updateTransaction(Transaction tx);
  Future<void> deleteTransaction(String id);
  List<Transaction> getAllTransactions({String? userId});
  double getTotalBalance();
  double getTotalExpense();
  double getDailyProgress(DateTime date);
  Future<DailyBudget?> getDailyBudget(DateTime date);
  Future<void> updateDailyBudget(DailyBudget dailyBudget);
  Future<List<DailySummary>> getDailySummaries({
    String? userId,
    required DateTime date,
  });

  Future<double> getWeeklyAmount({
    required DateTime startOfWeek,
    required DateTime endOfWeek,
    required TransactionType type,
    String? userId,
  });

  Future<double> getMonthlyAmount({
    required int year,
    required int month,
    required TransactionType type,
    String? userId,
  });
}