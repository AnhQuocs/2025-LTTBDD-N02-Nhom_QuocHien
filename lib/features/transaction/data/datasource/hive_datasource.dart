import 'package:fin_track/features/transaction/domain/entities/daily_budget.dart';
import 'package:fin_track/features/transaction/domain/entities/transaction.dart';
import 'package:hive_flutter/adapters.dart';

class HiveDataSource {
  Future<void> init({bool clearOldData = false}) async {
    await Hive.initFlutter();

    if(clearOldData) {
      if(await Hive.boxExists("transactions")) {
        await Hive.deleteBoxFromDisk("transactions");
      }

      if(await Hive.boxExists("daily_budgets")) {
        await Hive.deleteBoxFromDisk("daily_budgets");
      }
    }

    // Register adapter
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(DailyBudgetAdapter());

    await Hive.openBox<Transaction>("transactions");
    await Hive.openBox<DailyBudget>("daily_budgets");
  }

  // Get transaction box
  Box<Transaction> get transactionBox => Hive.box<Transaction>("transactions");

  // Get daily budget box
  Box<DailyBudget> get dailyBudgetBox => Hive.box<DailyBudget>("daily_budgets");
}