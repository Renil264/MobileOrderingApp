// lib/features/auth/presentation/bloc/itemcategory/item_category_bloc.dart

import 'package:concession_tracker_ui/core/global_item_category.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/item_category_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemCategoryBloc extends Bloc<ItemCategoryEvent, ItemCategoryState> {
  final GetItemCategoriesUseCase getItemCategories;

  ItemCategoryBloc({required this.getItemCategories})
      : super(ItemCategoryInitial()) {
    on<FetchItemCategories>(_onFetchItemCategories);
  }

  Future<void> _onFetchItemCategories(
    FetchItemCategories event,
    Emitter<ItemCategoryState> emit,
  ) async {
    emit(ItemCategoryLoading());
    try {
      final categories = await getItemCategories(event.marketName);

      // Persist the first category as the selected one by default
      if (categories.isNotEmpty) {
        await GlobalItemCategory.setCategory(
          id: categories.first.categoryId,
          name: categories.first.categoryName,
        );
      }

      emit(ItemCategoryLoaded(categories));
    } catch (e) {
      emit(ItemCategoryError(e.toString()));
    }
  }
}