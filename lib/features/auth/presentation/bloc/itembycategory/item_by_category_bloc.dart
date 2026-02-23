// lib/features/auth/presentation/bloc/itembycategory/item_by_category_bloc.dart


import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/get_store_items_usecase.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/items_by_category_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itembycategory/item_by_category_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itembycategory/item_by_category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemByCategoryBloc
    extends Bloc<ItemByCategoryEvent, ItemByCategoryState> {
  final GetItemsByCategoryUseCase getItemsByCategory;
  final GetStoreItemsUseCase getAllItems;

  ItemByCategoryBloc({
    required this.getItemsByCategory,
    required this.getAllItems,
  }) : super(ItemByCategoryInitial()) {
    on<FetchItemsByCategory>(_onFetchByCategory);
    on<LoadAllItems>(_onLoadAll);
  }

  // ── Fetch items for a specific category ──────────────────────────
  Future<void> _onFetchByCategory(
    FetchItemsByCategory event,
    Emitter<ItemByCategoryState> emit,
  ) async {
    emit(ItemByCategoryLoading());
    try {
      final items = await getItemsByCategory(
        concessionName: event.concessionName,
        categoryId: event.categoryId,
      );
      emit(ItemByCategoryLoaded(
        items,
        selectedCategoryId: event.categoryId,
      ));
    } catch (e) {
      emit(ItemByCategoryError(e.toString()));
    }
  }

  // ── Fetch all items (no category filter) ─────────────────────────
  Future<void> _onLoadAll(
    LoadAllItems event,
    Emitter<ItemByCategoryState> emit,
  ) async {
    emit(ItemByCategoryLoading());
    try {
      final rawItems = await getAllItems(
        concessionName: event.concessionName,
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
      );
      // Convert StoreItem → ItemByCategory (same shape, different entity)
      final items = rawItems
          .map((s) => ItemByCategory(
                itemName: s.itemName,
                itemPrice: s.itemPrice,
              ))
          .toList();
      emit(ItemByCategoryLoaded(items, selectedCategoryId: null));
    } catch (e) {
      emit(ItemByCategoryError(e.toString()));
    }
  }
}