// lib/features/auth/domain/repositories/concession_by_item_repository.dart

import '../entities/concession_by_item.dart';

abstract class ConcessionByItemRepository {
  Future<List<ConcessionByItem>> getConcessionsByItem(int itemId);
}