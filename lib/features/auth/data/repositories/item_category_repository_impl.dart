// lib/features/auth/data/repositories/item_category_repository_impl.dart

import '../../domain/entities/item_category.dart';
import '../../domain/repositories/item_category_repository.dart';
import '../datasources/item_category_remote_datasource.dart';

class ItemCategoryRepositoryImpl implements ItemCategoryRepository {
  final ItemCategoryRemoteDataSource remoteDataSource;

  ItemCategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ItemCategory>> getItemCategories(String marketName) async {
    return await remoteDataSource.getItemCategories(marketName);
  }
}