// lib/features/auth/domain/usecases/get_items_by_category_usecase.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/items_by_category_repository.dart';



class GetItemsByCategoryUseCase {
  final ItemByCategoryRepository repository;

  GetItemsByCategoryUseCase(this.repository);

  Future<List<ItemByCategory>> call({
    required String concessionName,
    required int categoryId,
  }) {
    return repository.getItemsByCategory(
      concessionName: concessionName,
      categoryId: categoryId,
    );
  }
}