import 'package:fin_track/features/transaction/data/datasource/hive_datasource.dart';
import 'package:fin_track/features/transaction/domain/entities/daily_budget.dart';
import 'package:fin_track/features/transaction/domain/repositories/transaction_repository.dart';

import '../../domain/entities/transaction.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final HiveDataSource hive;

  TransactionRepositoryImpl(this.hive);

  @override
  Future<void> addTransaction(Transaction tx) async {
    await hive.transactionBox.put(tx.id, tx);
    if (tx.type == TransactionType.Expense) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      DailyBudget? budget = hive.dailyBudgetBox.get(dateKey.toIso8601String());
      if (budget == null) {
        budget = DailyBudget(date: dateKey, limit: 0, spent: tx.price);
      } else {
        budget.spent += tx.price;
      }
      await hive.dailyBudgetBox.put(dateKey.toIso8601String(), budget);
    }
  }

  @override
  Future<void> updateTransaction(Transaction tx) async {
    await hive.transactionBox.put(tx.id, tx);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final tx = hive.transactionBox.get(id);
    if (tx != null && tx.type == TransactionType.Expense) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final budget = hive.dailyBudgetBox.get(dateKey.toIso8601String());
      if (budget != null) {
        budget.spent -= tx.price;
        await hive.dailyBudgetBox.put(dateKey.toIso8601String(), budget);
      }
    }
    await hive.transactionBox.delete(id);
  }

  @override
  List<Transaction> getAllTransactions({String? userId}) {
    final all = hive.transactionBox.values.toList();
    if (userId != null) {
      return all.where((tx) => tx.userId == userId).toList();
    }
    return all;
  }

  @override
  double getTotalBalance() {
    double income = 0,
        expense = 0;
    for (var tx in hive.transactionBox.values) {
      if (tx.type == TransactionType.Income) {
        income += tx.price;
      } else {
        expense += tx.price;
      }
    }
    return income - expense;
  }

  @override
  double getDailyProgress(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final budget = hive.dailyBudgetBox.get(dateKey.toIso8601String());
    if (budget == null || budget.limit == 0) return 0;
    return (budget.spent / budget.limit).clamp(0, 1);
  }

  @override
  Future<DailyBudget?> getDailyBudget(DateTime date) async {
    final box = hive.dailyBudgetBox;
    try {
      return box.values
          .cast<DailyBudget>()
          .firstWhere(
            (b) =>
        b.date.year == date.year &&
            b.date.month == date.month &&
            b.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateDailyBudget(DailyBudget dailyBudget) async {
    final box = hive.dailyBudgetBox;
    final existing = await getDailyBudget(dailyBudget.date);
    if(existing != null) {
      existing.limit = dailyBudget.limit;
      await existing.save();
    } else {
      await box.add(dailyBudget);
    }
  }
}