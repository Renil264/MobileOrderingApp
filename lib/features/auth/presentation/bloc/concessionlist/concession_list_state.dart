// lib/features/auth/presentation/bloc/concessionlist/concession_list_state.dart

abstract class ConcessionState {}

class ConcessionInitial extends ConcessionState {}

class ConcessionLoading extends ConcessionState {}

/// [concessions] is a plain List<String> of concession names.
/// [marketId] is saved globally but also available here for convenience.
class ConcessionLoaded extends ConcessionState {
  final List<String> concessions;
  final int marketId;

  ConcessionLoaded({required this.concessions, required this.marketId});
}

class ConcessionError extends ConcessionState {
  final String message;
  ConcessionError(this.message);
}