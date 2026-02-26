// lib/features/auth/data/repositories/concession_repository_impl.dart

import 'package:concession_tracker_ui/features/auth/data/datasources/remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/concession_repository.dart';

class ConcessionRepositoryImpl implements ConcessionRepository {
  final ConcessionRemoteDataSource remoteDataSource;

  ConcessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<String>> getConcessions(String marketName) {
    return remoteDataSource.getConcessions(marketName);
  }
}