import '../entities/concession_entity.dart';

abstract class ConcessionRepository {
  Future<List<Concession>> getConcessions(String marketName);
}
