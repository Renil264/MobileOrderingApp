// lib/features/concessions/presentation/bloc/concession_bloc.dart

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
      final concessions = await getConcessions(event.marketName);
      emit(ConcessionLoaded(concessions));
    } catch (e) {
      emit(ConcessionError(e.toString()));
    }
  }
}