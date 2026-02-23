// lib/features/auth/presentation/bloc/itemcategory/item_category_event.dart

abstract class ItemCategoryEvent {}

class FetchItemCategories extends ItemCategoryEvent {
  final String marketName;
  FetchItemCategories(this.marketName);
}