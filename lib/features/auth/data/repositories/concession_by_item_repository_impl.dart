// lib/features/auth/data/repositories/concession_by_item_repository_impl.dart

import '../../domain/entities/concession_by_item.dart';
import '../../domain/repositories/concession_by_item_repository.dart';
import '../datasources/concession_by_item_remote_datasource.dart';

class ConcessionByItemRepositoryImpl implements ConcessionByItemRepository {
  final ConcessionByItemRemoteDataSource remoteDataSource;

  ConcessionByItemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ConcessionByItem>> getConcessionsByItem(int itemId) async {
    return await remoteDataSource.getConcessionsByItem(itemId);
  }
}