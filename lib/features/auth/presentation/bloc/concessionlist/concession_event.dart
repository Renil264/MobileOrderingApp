abstract class ConcessionEvent {}

class FetchConcessions extends ConcessionEvent {
  final String marketName;
  FetchConcessions(this.marketName);
}