// lib/features/auth/presentation/bloc/storeitems/store_item_event.dart

abstract class StoreItemEvent {}

class FetchStoreItems extends StoreItemEvent {
  final String concessionName;
  final int userId;
  final String userName;
  final String userEmail;

  FetchStoreItems({
    required this.concessionName,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });
}