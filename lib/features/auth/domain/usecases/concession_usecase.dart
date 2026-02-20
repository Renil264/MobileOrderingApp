
import 'package:concession_tracker_ui/features/auth/domain/entities/concession_entity.dart';

import '../repositories/concession_repository.dart';

class GetConcessions {
  final ConcessionRepository repository;

  GetConcessions(this.repository);

  Future<List<Concession>> call(String marketName) {
    return repository.getConcessions(marketName);
  }
}