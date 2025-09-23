
import 'package:fin_track/features/transaction/domain/usecases/get_total_expense_usecase.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/entities/daily_budget.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/get_all_transaction_usecase.dart';
import '../../domain/usecases/get_daily_budget_usecase.dart';
import '../../domain/usecases/get_daily_progress_usecase.dart';
import '../../domain/usecases/get_total_balance_use_case.dart';
import '../../domain/usecases/update_daily_pudget_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';

class TransactionViewModel extends ChangeNotifier {
  final AddTransactionUseCase addTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final GetAllTransactionsUseCase getAllTransactionsUseCase;
  final GetTotalBalanceUseCase getTotalBalanceUseCase;
  final GetTotalExpenseUseCase getTotalExpenseUseCase;
  final GetDailyProgressUseCase getDailyProgressUseCase;
  final UpdateDailyBudgetUseCase updateDailyBudgetUseCase;
  final GetDailyBudgetUseCase getDailyBudgetUseCase;

  TransactionViewModel({
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getAllTransactionsUseCase,
    required this.getTotalBalanceUseCase,
    required this.getTotalExpenseUseCase,
    required this.getDailyProgressUseCase,
    required this.updateDailyBudgetUseCase,
    required this.getDailyBudgetUseCase,
  });

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  DailyBudget? todayBudget;

  double get totalBalance => getTotalBalanceUseCase.call();

  double get totalExpense => getTotalExpenseUseCase.call();

  Future<void> loadTransactions({String? userId}) async {
    _loading = true;
    notifyListeners();

    try {
      _transactions = await getAllTransactionsUseCase(userId: userId);

      todayBudget ??= await getDailyBudgetUseCase.call(DateTime.now());

      updateTodayBudgetSpent();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction tx) async {
    await addTransactionUseCase.call(tx);
    await loadTransactions();
  }

  Future<void> updateTransaction(Transaction tx) async {
    await updateTransactionUseCase.call(tx);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await deleteTransactionUseCase.call(id);
    await loadTransactions();
  }

  double getDailyProgress(DateTime date) => getDailyProgressUseCase.call(date);

  Future<void> updateDailyBudget(DailyBudget dailyBudget) async {
    _loading = true;
    notifyListeners();
    try {
      await updateDailyBudgetUseCase.call(dailyBudget);
      todayBudget = dailyBudget;
      updateTodayBudgetSpent();
    } catch (e) {
      print('Error updating daily budget: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadDailyBudget() async {
    todayBudget = await getDailyBudgetUseCase.call(DateTime.now());
    updateTodayBudgetSpent();
    notifyListeners();
  }

  void updateTodayBudgetSpent() {
    if (todayBudget == null) return;

    final today = DateTime.now();
    final spent = transactions
        .where((tx) =>
    tx.type == TransactionType.Expense &&
        tx.date.year == today.year &&
        tx.date.month == today.month &&
        tx.date.day == today.day)
        .fold<double>(0.0, (sum, tx) => sum + tx.price);

    todayBudget!.spent = spent;

    notifyListeners();
  }

}