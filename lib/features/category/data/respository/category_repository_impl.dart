import '../../domain/entity/category.dart';
import '../../domain/repository/category_repository.dart';
import '../data_source/hive_category_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final HiveCategoryDataSource hiveDataSource;

  CategoryRepositoryImpl(this.hiveDataSource);

  @override
  Future<void> addCategory(Category category) async {
    return hiveDataSource.addCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    return hiveDataSource.deleteCategory(id);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final defaultCategories = [
      Category(id: 'food', name: 'Food', icon: '🍔'),
      Category(id: 'entertainment', name: 'Entertainment', icon: '🎬'),
      Category(id: 'travel', name: 'Travel', icon: '✈️'),
    ];

    final saved = await hiveDataSource.getAllCategories();
    return [...defaultCategories, ...saved];
  }
}