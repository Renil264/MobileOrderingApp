// lib/features/auth/data/repositories/store_item_repository_impl.dart

import '../../domain/entities/store_item.dart';
import '../../domain/repositories/store_item_repository.dart';
import '../datasources/store_item_remote_datasource.dart';

class StoreItemRepositoryImpl implements StoreItemRepository {
  final StoreItemRemoteDataSource remoteDataSource;

  StoreItemRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StoreItem>> getStoreItems({
    required String concessionName,
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    return await remoteDataSource.getStoreItems(
      concessionName: concessionName,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    );
  }
}