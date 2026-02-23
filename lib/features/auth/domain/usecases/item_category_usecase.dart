// lib/features/auth/domain/usecases/get_item_categories_usecase.dart

import '../entities/item_category.dart';
import '../repositories/item_category_repository.dart';

class GetItemCategoriesUseCase {
  final ItemCategoryRepository repository;

  GetItemCategoriesUseCase(this.repository);

  Future<List<ItemCategory>> call(String marketName) {
    return repository.getItemCategories(marketName);
  }
}