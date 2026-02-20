// lib/features/concessions/data/repositories/concession_repository_impl.dart

import 'package:concession_tracker_ui/features/auth/data/datasources/remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/data/model/concession_model.dart';
import 'package:concession_tracker_ui/features/auth/domain/entities/concession_entity.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/concession_repository.dart';


class ConcessionRepositoryImpl implements ConcessionRepository {
  final ConcessionRemoteDataSource remoteDataSource;

  ConcessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Concession>> getConcessions(String marketName) async {
    final rawList = await remoteDataSource.getConcessions(marketName);
    return rawList.map((name) => ConcessionModel.fromString(name)).toList();
  }
}