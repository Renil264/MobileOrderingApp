// lib/features/auth/presentation/bloc/storeitems/store_item_bloc.dart

import 'package:concession_tracker_ui/features/auth/domain/usecases/get_store_items_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/store/store_item_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/store/store_item_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreItemBloc extends Bloc<StoreItemEvent, StoreItemState> {
  final GetStoreItemsUseCase getStoreItems;

  StoreItemBloc({required this.getStoreItems}) : super(StoreItemInitial()) {
    on<FetchStoreItems>(_onFetchStoreItems);
  }

  Future<void> _onFetchStoreItems(
    FetchStoreItems event,
    Emitter<StoreItemState> emit,
  ) async {
    emit(StoreItemLoading());
    try {
      final items = await getStoreItems(
        concessionName: event.concessionName,
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
      );
      emit(StoreItemLoaded(items, concessionName: event.concessionName));
    } catch (e) {
      emit(StoreItemError(e.toString()));
    }
  }
}