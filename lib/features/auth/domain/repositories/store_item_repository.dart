
import '../entities/store_item.dart';

abstract class StoreItemRepository {
  Future<List<StoreItem>> getStoreItems({
    required String concessionName,
    required int userId,
    required String userName,
    required String userEmail,
  });
}