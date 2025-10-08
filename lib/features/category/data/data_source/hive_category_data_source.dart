import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entity/category.dart';

class HiveCategoryDataSource {
  static const String boxName = 'categories';

  Future<void> init() async {
    await Hive.openBox<Category>(boxName);
  }

  Box<Category> get box => Hive.box<Category>(boxName);

  Future<List<Category>> getAllCategories() async {
    return box.values.toList();
  }

  Future<void> addCategory(Category category) async {
    await box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await box.delete(id);
  }
}