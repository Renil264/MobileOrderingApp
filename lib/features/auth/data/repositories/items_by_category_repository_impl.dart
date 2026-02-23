// lib/features/auth/data/repositories/item_by_category_repository_impl.dart

import 'package:concession_tracker_ui/features/auth/data/datasources/items_by_category_remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/domain/entities/items_by_category.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/items_by_category_repository.dart';


class ItemByCategoryRepositoryImpl implements ItemByCategoryRepository {
  final ItemByCategoryRemoteDataSource remoteDataSource;

  ItemByCategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ItemByCategory>> getItemsByCategory({
    required String concessionName,
    required int categoryId,
  }) async {
    return await remoteDataSource.getItemsByCategory(
      concessionName: concessionName,
      categoryId: categoryId,
    );
  }
}