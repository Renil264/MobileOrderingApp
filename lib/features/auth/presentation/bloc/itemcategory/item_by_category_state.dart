// lib/features/auth/presentation/bloc/itemcategory/item_category_state.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/item_category.dart';

abstract class ItemCategoryState {}

class ItemCategoryInitial extends ItemCategoryState {}

class ItemCategoryLoading extends ItemCategoryState {}

class ItemCategoryLoaded extends ItemCategoryState {
  final List<ItemCategory> categories;
  ItemCategoryLoaded(this.categories);
}

class ItemCategoryError extends ItemCategoryState {
  final String message;
  ItemCategoryError(this.message);
}