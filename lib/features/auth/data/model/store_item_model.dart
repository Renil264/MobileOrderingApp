// lib/features/auth/data/models/store_item_model.dart

import '../../domain/entities/store_item.dart';

class StoreItemModel extends StoreItem {
  const StoreItemModel({
    required super.itemName,
    required super.itemPrice,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      itemName: json['Item Name'] as String,
      itemPrice: (json['Item Price'] as num).toDouble(),
    );
  }
}