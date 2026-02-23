// lib/features/auth/domain/repositories/store_item_repository.dart
import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';



abstract class ItemByCategoryRepository {
  Future<List<ItemByCategory>> getItemsByCategory({
    required String concessionName,
    required int categoryId,
  });
}