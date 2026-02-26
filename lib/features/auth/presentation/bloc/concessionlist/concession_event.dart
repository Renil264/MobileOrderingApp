// lib/features/auth/presentation/bloc/concessionlist/concession_event.dart

abstract class ConcessionEvent {}

class FetchConcessions extends ConcessionEvent {
  final String marketName;
  FetchConcessions(this.marketName);
}