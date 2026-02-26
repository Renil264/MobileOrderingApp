// lib/features/auth/domain/entities/store_item.dart

class StoreItem {
  final int itemId;
  final int categoryId;
  final String itemName;
  final double itemPrice;

  const StoreItem({
    required this.itemId,
    required this.categoryId,
    required this.itemName,
    required this.itemPrice,
  });
}