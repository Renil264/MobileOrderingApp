// lib/features/auth/domain/repositories/concession_repository.dart

abstract class ConcessionRepository {
  Future<List<String>> getConcessions(String marketName);
}