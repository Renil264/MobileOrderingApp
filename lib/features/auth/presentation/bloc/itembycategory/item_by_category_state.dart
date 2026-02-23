// lib/features/auth/presentation/bloc/itembycategory/item_by_category_state.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';

abstract class ItemByCategoryState {}

class ItemByCategoryInitial extends ItemByCategoryState {}

class ItemByCategoryLoading extends ItemByCategoryState {}

class ItemByCategoryLoaded extends ItemByCategoryState {
  final List<ItemByCategory> items;
  final int? selectedCategoryId; // null = "All"
  ItemByCategoryLoaded(this.items, {this.selectedCategoryId});
}

class ItemByCategoryError extends ItemByCategoryState {
  final String message;
  ItemByCategoryError(this.message);
}