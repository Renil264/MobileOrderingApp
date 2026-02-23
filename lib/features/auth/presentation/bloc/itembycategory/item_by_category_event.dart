// lib/features/auth/presentation/bloc/itembycategory/item_by_category_event.dart

abstract class ItemByCategoryEvent {}

class FetchItemsByCategory extends ItemByCategoryEvent {
  final String concessionName;
  final int categoryId;

  FetchItemsByCategory({
    required this.concessionName,
    required this.categoryId,
  });
}

class LoadAllItems extends ItemByCategoryEvent {
  final String concessionName;
  final int userId;
  final String userName;
  final String userEmail;

  LoadAllItems({
    required this.concessionName,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });
}