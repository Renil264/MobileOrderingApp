// lib/features/auth/presentation/bloc/concessionbyitem/concession_by_item_event.dart

abstract class ConcessionByItemEvent {}

class FetchConcessionsByItem extends ConcessionByItemEvent {
  final int itemId;
  FetchConcessionsByItem(this.itemId);
}

class LoadAllConcessions extends ConcessionByItemEvent {}