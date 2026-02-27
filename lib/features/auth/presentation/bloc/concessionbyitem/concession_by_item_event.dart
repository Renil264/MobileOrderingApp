// lib/features/auth/presentation/bloc/concessionbyitem/concession_by_item_event.dart

abstract class ConcessionByItemEvent {}

/// Fired when a category chip is tapped on the homepage.
/// [marketId]   comes from GlobalMarketData.marketId
/// [categoryId] comes from the tapped ItemCategory
class FetchConcessionsByItem extends ConcessionByItemEvent {
  final int marketId;
  final int categoryId;

  FetchConcessionsByItem({
    required this.marketId,
    required this.categoryId,
  });
}

class LoadAllConcessions extends ConcessionByItemEvent {}