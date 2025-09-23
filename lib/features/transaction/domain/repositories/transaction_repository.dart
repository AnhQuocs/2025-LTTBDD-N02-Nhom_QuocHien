import '../entities/daily_budget.dart';
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
}