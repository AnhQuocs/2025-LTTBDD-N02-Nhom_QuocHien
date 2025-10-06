import 'package:flutter/cupertino.dart';

import '../../domain/entities/daily_budget.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/create/add_transaction_usecase.dart';
import '../../domain/usecases/delete/delete_transaction_usecase.dart';
import '../../domain/usecases/read/get_all_transaction_usecase.dart';
import '../../domain/usecases/read/get_daily_budget_usecase.dart';
import '../../domain/usecases/read/get_daily_progress_usecase.dart';
import '../../domain/usecases/read/get_daily_summaries_usecase.dart';
import '../../domain/usecases/read/get_monthly_total_use_case.dart';
import '../../domain/usecases/read/get_total_balance_use_case.dart';
import '../../domain/usecases/read/get_total_expense_usecase.dart';
import '../../domain/usecases/read/get_weekly_total_use_case.dart';
import '../../domain/usecases/update/update_daily_pudget_usecase.dart';
import '../../domain/usecases/update/update_transaction_usecase.dart';

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
  final GetDailySummariesUseCase getDailySummariesUseCase;
  final GetMonthlyTotalUseCase getMonthlyTotalUseCase;
  final GetWeeklyTotalUseCase getWeeklyTotalUseCase;

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
    required this.getDailySummariesUseCase,
    required this.getWeeklyTotalUseCase,
    required this.getMonthlyTotalUseCase
  });

  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  List<DailySummary> _summaries = [];
  List<DailySummary> get summaries => _summaries;

  DateTime? _startOfWeek;
  DateTime? _endOfWeek;
  DateTime? get startOfWeek => _startOfWeek;
  DateTime? get endOfWeek => _endOfWeek;

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
    await loadTransactions(userId: tx.userId);
    await loadDailySummaries(userId: tx.userId);
  }

  Future<void> updateTransaction(Transaction tx) async {
    await updateTransactionUseCase.call(tx);
    await loadTransactions(userId: tx.userId);
    await loadDailySummaries(userId: tx.userId);
  }

  Future<void> deleteTransaction(String id, {String? userId}) async {
    await deleteTransactionUseCase.call(id);
    await loadTransactions(userId: userId);
    await loadDailySummaries(userId: userId);
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
        .where(
          (tx) =>
              tx.type == TransactionType.Expense &&
              tx.date.year == today.year &&
              tx.date.month == today.month &&
              tx.date.day == today.day,
        )
        .fold<double>(0.0, (sum, tx) => sum + tx.price);

    todayBudget!.spent = spent;

    notifyListeners();
  }

  Future<void> loadDailySummaries({String? userId, DateTime? date}) async {
    _loading = true;
    notifyListeners();

    try {
      final target = date ?? DateTime.now();
      _startOfWeek = target.subtract(Duration(days: target.weekday - 1));
      _endOfWeek = _startOfWeek!.add(const Duration(days: 6));

      debugPrint('📅 Loading summaries for week: $_startOfWeek → $_endOfWeek');

      final all = await getDailySummariesUseCase(userId: userId);

      // Lọc dữ liệu theo tuần
      _summaries = all
          .where((s) =>
      s.date.isAfter(_startOfWeek!.subtract(const Duration(days: 1))) &&
          s.date.isBefore(_endOfWeek!.add(const Duration(days: 1))))
          .toList();

      debugPrint('✅ Loaded ${_summaries.length} daily summaries');
      for (var s in _summaries) {
        debugPrint('  → ${s.date}: income=${s.income}, expense=${s.expense}');
      }
    } catch (e) {
      debugPrint('❌ Error loading summaries: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Weekly totals
  double _weeklyIncome = 0.0;
  double _weeklyExpense = 0.0;
  double _weeklyBalance = 0.0;

  double get weeklyIncome => _weeklyIncome;
  double get weeklyExpense => _weeklyExpense;
  double get weeklyBalance => _weeklyBalance;

  Future<void> loadWeeklyTotals({String? userId, DateTime? date}) async {
    _loading = true;
    notifyListeners();

    try {
      final target = date ?? DateTime.now();
      final startOfWeek = target.subtract(Duration(days: target.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final result = await getWeeklyTotalUseCase.execute(
        startOfWeek: startOfWeek,
        endOfWeek: endOfWeek,
        userId: userId,
      );

      _weeklyIncome = result['income'] ?? 0.0;
      _weeklyExpense = result['expense'] ?? 0.0;
      _weeklyBalance = result['balance'] ?? 0.0;

    } catch (e) {
      debugPrint('❌ Error loading weekly totals: $e');
      _weeklyIncome = 0.0;
      _weeklyExpense = 0.0;
      _weeklyBalance = 0.0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Monthly totals
  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;
  double _monthlyBalance = 0.0;

  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get monthlyBalance => _monthlyBalance;

  Future<void> loadMonthlyTotals({required int year, required int month, String? userId}) async {
    _loading = true;
    notifyListeners();

    try {
      final result = await getMonthlyTotalUseCase.execute(
        year: year,
        month: month,
        userId: userId,
      );

      _monthlyIncome = result['income'] ?? 0.0;
      _monthlyExpense = result['expense'] ?? 0.0;
      _monthlyBalance = result['balance'] ?? 0.0;

    } catch (e) {
      debugPrint('❌ Error loading monthly totals: $e');
      _monthlyIncome = 0.0;
      _monthlyExpense = 0.0;
      _monthlyBalance = 0.0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
