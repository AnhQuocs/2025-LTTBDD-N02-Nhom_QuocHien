import 'package:flutter/cupertino.dart';

import '../../domain/entity/category.dart';
import '../../domain/usecase/add_category_usecase.dart';
import '../../domain/usecase/delete_category_usecase.dart';
import '../../domain/usecase/get_all_categories_usecase.dart';

class CategoryViewModel extends ChangeNotifier {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  CategoryViewModel({
    required this.getAllCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
  });

  Future<void> loadCategories() async {
    _categories = await getAllCategoriesUseCase();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await addCategoryUseCase(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await deleteCategoryUseCase(id);
    await loadCategories();
  }
}