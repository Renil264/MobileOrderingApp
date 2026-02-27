// lib/features/auth/presentation/bloc/concessionbyitem/concession_by_item_bloc.dart

import 'package:concession_tracker_ui/features/auth/domain/usecases/get_concessions_by_item_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConcessionByItemBloc
    extends Bloc<ConcessionByItemEvent, ConcessionByItemState> {
  final GetConcessionsByItemUseCase getConcessionsByItem;

  ConcessionByItemBloc({required this.getConcessionsByItem})
      : super(ConcessionByItemInitial()) {
    on<FetchConcessionsByItem>(_onFetchByCategory);
    on<LoadAllConcessions>(_onLoadAll);
  }

  Future<void> _onFetchByCategory(
    FetchConcessionsByItem event,
    Emitter<ConcessionByItemState> emit,
  ) async {
    emit(ConcessionByItemLoading());
    try {
      print('══════════════════════════════════════');
      print('[ConcessionByItemBloc] FetchConcessionsByItem');
      print('  marketId   : ${event.marketId}');
      print('  categoryId : ${event.categoryId}');
      print('══════════════════════════════════════');

      if (event.marketId == 0) {
        emit(ConcessionByItemError(
            'marketId is 0 — market data not loaded yet. '
            'Please return to the market selection screen.'));
        return;
      }

      final concessions = await getConcessionsByItem(
        marketId: event.marketId,
        categoryId: event.categoryId,
      );

      print('[ConcessionByItemBloc] Loaded ${concessions.length} concessions');

      emit(ConcessionByItemLoaded(
        concessions,
        selectedCategoryId: event.categoryId,
      ));
    } catch (e) {
      print('[ConcessionByItemBloc] Error: $e');
      emit(ConcessionByItemError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
    LoadAllConcessions event,
    Emitter<ConcessionByItemState> emit,
  ) async {
    // "All" tab — no category filter, emit empty loaded state
    emit(ConcessionByItemLoaded(const [], selectedCategoryId: null));
  }
}