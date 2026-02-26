// lib/features/auth/data/models/store_item_model.dart

import '../../domain/entities/store_item.dart';

class StoreItemModel extends StoreItem {
  const StoreItemModel({
    required super.itemId,
    required super.categoryId,
    required super.itemName,
    required super.itemPrice,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      itemId: (json['itemId'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      itemName: (json['itemName'] ?? '') as String,
      itemPrice: (json['itemPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}