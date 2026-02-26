// lib/features/auth/presentation/bloc/concessionlist/concession_bloc.dart


import 'package:concession_tracker_ui/core/globalmarketdata.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/concession_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConcessionBloc extends Bloc<ConcessionEvent, ConcessionState> {
  final GetConcessions getConcessions;

  ConcessionBloc({required this.getConcessions}) : super(ConcessionInitial()) {
    on<FetchConcessions>(_onFetchConcessions);
  }

  Future<void> _onFetchConcessions(
    FetchConcessions event,
    Emitter<ConcessionState> emit,
  ) async {
    emit(ConcessionLoading());
    try {
      print('[ConcessionBloc] Fetching for market: "${event.marketName}"');

      // getConcessions returns List<String> AND saves marketId as side effect
      final concessions = await getConcessions(event.marketName);

      print('[ConcessionBloc] Loaded ${concessions.length} concessions');
      print('[ConcessionBloc] marketId: ${GlobalMarketData.marketId}');

      emit(ConcessionLoaded(
        concessions: concessions,
        marketId: GlobalMarketData.marketId,
      ));
    } catch (e) {
      print('[ConcessionBloc] Error: $e');
      emit(ConcessionError(e.toString()));
    }
  }
}