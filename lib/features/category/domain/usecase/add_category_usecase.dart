import '../entity/category.dart';
import '../repository/category_repository.dart';

class AddCategoryUseCase {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return repository.addCategory(category);
  }
}