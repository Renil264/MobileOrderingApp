// lib/features/auth/domain/repositories/item_category_repository.dart

import '../entities/item_category.dart';

abstract class ItemCategoryRepository {
  Future<List<ItemCategory>> getItemCategories(String marketName);
}