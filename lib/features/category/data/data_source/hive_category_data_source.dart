import 'package:hive_flutter/hive_flutter.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../domain/entity/category.dart';

class HiveCategoryDataSource {
  static const String categoryBoxName = 'categories';
  static const String transactionBoxName = 'transactions';

  Future<void> init() async {
    await Hive.openBox<Category>(categoryBoxName);
    await Hive.openBox<Transaction>(transactionBoxName);
  }

  Box<Category> get categoryBox => Hive.box<Category>(categoryBoxName);
  Box<Transaction> get transactionBox => Hive.box<Transaction>(transactionBoxName);

  Future<List<Category>> getAllCategories() async {
    return categoryBox.values.toList();
  }

  Future<void> addCategory(Category category) async {
    await categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String categoryId) async {
    final allTransactions = transactionBox.values.toList();

    final transactionsToDelete = allTransactions
        .where((t) => t.category.id == categoryId)
        .toList();

    for (var transaction in transactionsToDelete) {
      await transactionBox.delete(transaction.id);
    }

    await categoryBox.delete(categoryId);
  }
}