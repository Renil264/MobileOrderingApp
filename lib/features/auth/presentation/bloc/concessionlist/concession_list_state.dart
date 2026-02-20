// lib/features/concessions/presentation/bloc/concession_state.dart



import 'package:concession_tracker_ui/features/auth/domain/entities/concession_entity.dart';

abstract class ConcessionState {}

class ConcessionInitial extends ConcessionState {}

class ConcessionLoading extends ConcessionState {}

class ConcessionLoaded extends ConcessionState {
  final List<Concession> concessions;
  ConcessionLoaded(this.concessions);
}

class ConcessionError extends ConcessionState {
  final String message;
  ConcessionError(this.message);
}