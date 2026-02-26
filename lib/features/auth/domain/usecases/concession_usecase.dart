// lib/features/auth/domain/usecases/concession_usecase.dart
// Class name matches your injection_container: GetConcessions

import 'package:concession_tracker_ui/features/auth/domain/repositories/concession_repository.dart';

class GetConcessions {
  final ConcessionRepository repository;

  GetConcessions(this.repository);

  Future<List<String>> call(String marketName) {
    return repository.getConcessions(marketName);
  }
}