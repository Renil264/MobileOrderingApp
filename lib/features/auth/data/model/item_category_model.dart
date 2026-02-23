// lib/features/auth/data/models/item_category_model.dart

import '../../domain/entities/item_category.dart';

class ItemCategoryModel extends ItemCategory {
  const ItemCategoryModel({
    required super.categoryId,
    required super.categoryName,
  });

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
    );
  }
}