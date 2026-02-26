// lib/features/auth/data/models/item_by_category_model.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';



class ItemByCategoryModel extends ItemByCategory {
  const ItemByCategoryModel({
    super.itemId = 0,
    super.categoryId = 0,
    required super.itemName,
    required super.itemPrice,
  });

  factory ItemByCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemByCategoryModel(
      itemId: (json['itemId'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      itemName: (json['itemName'] ?? json['Item Name'] ?? '') as String,
      itemPrice: ((json['itemPrice'] ?? json['Item Price']) as num?)?.toDouble() ?? 0.0,
    );
  }
}