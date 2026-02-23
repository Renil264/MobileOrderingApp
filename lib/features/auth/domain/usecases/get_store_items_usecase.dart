// lib/features/auth/domain/usecases/get_store_items_usecase.dart

import '../entities/store_item.dart';
import '../repositories/store_item_repository.dart';

class GetStoreItemsUseCase {
  final StoreItemRepository repository;

  GetStoreItemsUseCase(this.repository);

  Future<List<StoreItem>> call({
    required String concessionName,
    required int userId,
    required String userName,
    required String userEmail,
  }) {
    return repository.getStoreItems(
      concessionName: concessionName,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    );
  }
}