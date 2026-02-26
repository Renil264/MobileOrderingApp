// lib/features/auth/domain/entities/item_by_category.dart

class ItemByCategory {
  final int itemId;
  final int categoryId;
  final String itemName;
  final double itemPrice;

  const ItemByCategory({
    this.itemId = 0,
    this.categoryId = 0,
    required this.itemName,
    required this.itemPrice,
  });
}