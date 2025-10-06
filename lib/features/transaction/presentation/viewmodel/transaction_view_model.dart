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

      debugPrint('Loading summaries for week: $_startOfWeek → $_endOfWeek');

      final all = await getDailySummariesUseCase(userId: userId);

      _summaries = all
          .where((s) =>
      s.date.isAfter(_startOfWeek!.subtract(const Duration(days: 1))) &&
          s.date.isBefore(_endOfWeek!.add(const Duration(days: 1))))
          .toList();

      debugPrint('Loaded ${_summaries.length} daily summaries');
      for (var s in _summaries) {
        debugPrint('  → ${s.date}: income=${s.income}, expense=${s.expense}');
      }
    } catch (e) {
      debugPrint('Error loading summaries: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---------------- WEEKLY SUMMARIES ----------------
  List<DailySummary> _weeklySummaries = [];
  List<DailySummary> get weeklySummaries => _weeklySummaries;

  DateTime? _startOfMonth;
  DateTime? _endOfMonth;
  DateTime? get startOfMonth => _startOfMonth;
  DateTime? get endOfMonth => _endOfMonth;

  Future<void> loadWeeklySummaries({String? userId, DateTime? date}) async {
    _loading = true;
    notifyListeners();

    try {
      final target = date ?? DateTime.now();
      final firstDayOfMonth = DateTime(target.year, target.month, 1);
      final lastDayOfMonth = DateTime(target.year, target.month + 1, 0);

      _startOfMonth = firstDayOfMonth;
      _endOfMonth = lastDayOfMonth;

      final all = await getDailySummariesUseCase(userId: userId);

      Map<int, List<DailySummary>> groupedByWeek = {};

      for (final s in all) {
        if (s.date.isBefore(firstDayOfMonth) || s.date.isAfter(lastDayOfMonth)) continue;

        final weekOfMonth = _getWeekOfMonth(s.date);
        groupedByWeek.putIfAbsent(weekOfMonth, () => []).add(s);
      }

      final List<DailySummary> weeks = [];

      for (int i = 1; i <= 5; i++) {
        final weekItems = groupedByWeek[i] ?? [];

        final incomeSum = weekItems.fold<double>(0.0, (sum, s) => sum + (s.income ?? 0.0));
        final expenseSum = weekItems.fold<double>(0.0, (sum, s) => sum + (s.expense ?? 0.0));

        final weekStart = firstDayOfMonth.add(Duration(days: (i - 1) * 7));
        weeks.add(DailySummary(
          date: weekStart,
          income: incomeSum,
          expense: expenseSum,
        ));
      }

      _weeklySummaries = weeks;
      debugPrint('Weekly summaries: ${_weeklySummaries.map((w) => '${w.date.day}/${w.date.month}: +${w.income}, -${w.expense}').join(', ')}');

    } catch (e) {
      debugPrint('Error in loadWeeklySummaries: $e');
      _weeklySummaries = List.generate(4, (i) => DailySummary(date: DateTime.now(), income: 0.0, expense: 0.0));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    int adjust = (firstDayOfMonth.weekday + 6) % 7; // Nếu thứ 2 là 0
    return ((date.day + adjust - 1) ~/ 7) + 1;
  }


  // ---------------- MONTHLY SUMMARIES ----------------
  List<DailySummary> _monthlySummaries = [];
  List<DailySummary> get monthlySummaries => _monthlySummaries;

  Future<void> loadMonthlySummaries({String? userId, DateTime? date}) async {
    _loading = true;
    notifyListeners();

    try {
      final target = date ?? DateTime.now();
      final year = target.year;

      final all = await getDailySummariesUseCase(userId: userId);

      final List<DailySummary> months = [];

      for (int month = 1; month <= 12; month++) {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 0);

        final items = all.where((s) =>
        s.date.isAfter(start.subtract(const Duration(days: 1))) &&
            s.date.isBefore(end.add(const Duration(days: 1))));

        final incomeSum =
        items.fold<double>(0.0, (sum, s) => sum + (s.income ?? 0.0));
        final expenseSum =
        items.fold<double>(0.0, (sum, s) => sum + (s.expense ?? 0.0));

        months.add(DailySummary(date: start, income: incomeSum, expense: expenseSum));
      }

      _monthlySummaries = months;
      debugPrint(
          'Loaded monthly summaries: ${months.map((m) => '${m.date.month}/${m.date.year}: i=${m.income}, e=${m.expense}').toList()}');
    } catch (e) {
      debugPrint('Error in loadMonthlySummaries: $e');
      _monthlySummaries = List.generate(
        12,
            (i) => DailySummary(date: DateTime.now(), income: 0.0, expense: 0.0),
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
