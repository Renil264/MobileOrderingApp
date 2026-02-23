// lib/features/auth/domain/usecases/get_concessions_by_item_usecase.dart

import '../entities/concession_by_item.dart';
import '../repositories/concession_by_item_repository.dart';

class GetConcessionsByItemUseCase {
  final ConcessionByItemRepository repository;

  GetConcessionsByItemUseCase(this.repository);

  Future<List<ConcessionByItem>> call(int itemId) {
    return repository.getConcessionsByItem(itemId);
  }
}