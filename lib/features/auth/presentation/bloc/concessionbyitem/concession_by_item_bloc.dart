// lib/features/auth/presentation/bloc/concessionbyitem/concession_by_item_bloc.dart

import 'package:concession_tracker_ui/features/auth/domain/usecases/get_concessions_by_item_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConcessionByItemBloc
    extends Bloc<ConcessionByItemEvent, ConcessionByItemState> {
  final GetConcessionsByItemUseCase getConcessionsByItem;

  // Cache of all concessions for the "All" tab
  List<dynamic> _allConcessions = [];

  ConcessionByItemBloc({required this.getConcessionsByItem})
      : super(ConcessionByItemInitial()) {
    on<FetchConcessionsByItem>(_onFetchByItem);
    on<LoadAllConcessions>(_onLoadAll);
  }

  Future<void> _onFetchByItem(
    FetchConcessionsByItem event,
    Emitter<ConcessionByItemState> emit,
  ) async {
    emit(ConcessionByItemLoading());
    try {
      final concessions =
          await getConcessionsByItem(event.itemId);
      emit(ConcessionByItemLoaded(
        concessions,
        selectedCategoryId: event.itemId,
      ));
    } catch (e) {
      emit(ConcessionByItemError(e.toString()));
    }
  }

  Future<void> _onLoadAll(
    LoadAllConcessions event,
    Emitter<ConcessionByItemState> emit,
  ) async {
    // "All" tab — emit loaded with no filter (selectedCategoryId = null)
    emit(ConcessionByItemLoaded(
      const [],
      selectedCategoryId: null,
    ));
  }
}