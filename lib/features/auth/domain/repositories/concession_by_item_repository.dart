// lib/features/auth/domain/repositories/concession_by_item_repository.dart

import '../entities/concession_by_item.dart';

abstract class ConcessionByItemRepository {
  /// Fetches concessions filtered by [marketId] and [categoryId].
  /// Maps to GET /concessions-by-category/{marketId}/{categoryId}
  Future<List<ConcessionByItem>> getConcessionsByCategory({
    required int marketId,
    required int categoryId,
  });
}