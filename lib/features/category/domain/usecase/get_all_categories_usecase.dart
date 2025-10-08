import '../entity/category.dart';
import '../repository/category_repository.dart';

class GetAllCategoriesUseCase {
  final CategoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  Future<List<Category>> call() async {
    return repository.getAllCategories();
  }
}