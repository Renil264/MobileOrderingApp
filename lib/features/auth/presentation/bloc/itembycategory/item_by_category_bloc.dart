// lib/features/auth/presentation/bloc/itembycategory/item_by_category_bloc.dart

import 'package:concession_tracker_ui/core/global_selected_item.dart';
import 'package:concession_tracker_ui/core/global_user.dart';
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

  // ── Items filtered by category (POST /items-by-category) ─────────
  Future<void> _onFetchByCategory(
    FetchItemsByCategory event,
    Emitter<ItemByCategoryState> emit,
  ) async {
    emit(ItemByCategoryLoading());
    try {
      print('[Bloc] FetchItemsByCategory → concession="${event.concessionName}" categoryId=${event.categoryId}');

      final items = await getItemsByCategory(
        concessionName: event.concessionName,
        categoryId: event.categoryId,
      );

      // Persist first item's ids if list is non-empty
      if (items.isNotEmpty) {
        await GlobalSelectedItem.set(
          itemId: items.first.itemId,
          categoryId: items.first.categoryId,
          concessionId: GlobalSelectedItem.concessionId, // keep existing
        );
      }

      emit(ItemByCategoryLoaded(items, selectedCategoryId: event.categoryId));
    } catch (e) {
      print('[Bloc] FetchItemsByCategory error: $e');
      emit(ItemByCategoryError(e.toString()));
    }
  }

  // ── All items for a concession (POST /items) ──────────────────────
  Future<void> _onLoadAll(
    LoadAllItems event,
    Emitter<ItemByCategoryState> emit,
  ) async {
    emit(ItemByCategoryLoading());
    try {
      // Always read GlobalUser fresh — never rely on stale event fields
      final userId    = GlobalUser.id    != 0          ? GlobalUser.id    : event.userId;
      final userName  = GlobalUser.name.isNotEmpty      ? GlobalUser.name  : event.userName;
      final userEmail = GlobalUser.email.isNotEmpty     ? GlobalUser.email : event.userEmail;

      print('══════════════════════════════════════');
      print('[Bloc] LoadAllItems');
      print('  concessionName : "${event.concessionName}"');
      print('  userId         : $userId');
      print('  userName       : "$userName"');
      print('  userEmail      : "$userEmail"');
      print('══════════════════════════════════════');

      if (event.concessionName.trim().isEmpty) {
        emit(ItemByCategoryError('Concession name is empty.'));
        return;
      }
      if (userId == 0 || userName.trim().isEmpty || userEmail.trim().isEmpty) {
        emit(ItemByCategoryError(
            'User credentials missing — userId=$userId, '
            'userName="$userName", userEmail="$userEmail". Please log in again.'));
        return;
      }

      // getAllItems calls POST /items → returns List<StoreItem>
      // The datasource also saves concessionId to GlobalSelectedItem as a side effect
      final rawItems = await getAllItems(
        concessionName: event.concessionName,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      );

      // ── Convert StoreItem → ItemByCategory (all fields mapped) ──
      final items = rawItems.map((s) => ItemByCategory(
            itemId: s.itemId,
            categoryId: s.categoryId,
            itemName: s.itemName,
            itemPrice: s.itemPrice,
          )).toList();

      print('[Bloc] LoadAllItems → loaded ${items.length} items');
      emit(ItemByCategoryLoaded(items, selectedCategoryId: null));
    } catch (e) {
      print('[Bloc] LoadAllItems error: $e');
      emit(ItemByCategoryError(e.toString()));
    }
  }
}