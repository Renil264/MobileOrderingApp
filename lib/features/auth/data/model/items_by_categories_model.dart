// lib/features/auth/data/models/item_by_category_model.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';


class ItemByCategoryModel extends ItemByCategory {
  const ItemByCategoryModel({
    required super.itemName,
    required super.itemPrice,
  });

  factory ItemByCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemByCategoryModel(
      itemName: json['Item Name'] as String,
      itemPrice: (json['Item Price'] as num).toDouble(),
    );
  }
}