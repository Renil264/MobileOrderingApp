// lib/injection_container.dart

import 'package:concession_tracker_ui/features/auth/data/datasources/concession_by_item_remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/data/datasources/item_category_remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/data/datasources/items_by_category_remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/data/datasources/remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/data/datasources/store_item_remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/data/repositories/concession_by_item_repository_impl.dart';
import 'package:concession_tracker_ui/features/auth/data/repositories/concession_repository_impl.dart';
import 'package:concession_tracker_ui/features/auth/data/repositories/item_category_repository_impl.dart';
import 'package:concession_tracker_ui/features/auth/data/repositories/items_by_category_repository_impl.dart';
import 'package:concession_tracker_ui/features/auth/data/repositories/store_item_repository_impl.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/concession_by_item_repository.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/concession_repository.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/item_category_repository.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/items_by_category_repository.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/store_item_repository.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/concession_usecase.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/get_concessions_by_item_usecase.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/get_store_items_usecase.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/item_category_usecase.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/items_by_category_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionbyitem/concession_by_item_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itembycategory/item_by_category_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_bloc.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/itemcategory/item_by_category_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/store/store_item_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ── External ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => http.Client());

  // ── Concessions (market-wide) ─────────────────────────────────────
  // Datasource now parses { marketId, concessions[] } and saves
  // marketId to GlobalMarketData (SharedPreferences) as a side effect.
  // Returns List<String> — no Concession entity, no .name null errors.
  sl.registerFactory(() => ConcessionBloc(getConcessions: sl()));
  sl.registerLazySingleton(() => GetConcessions(sl()));
  sl.registerLazySingleton<ConcessionRepository>(
      () => ConcessionRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ConcessionRemoteDataSource>(
      () => ConcessionRemoteDataSourceImpl(client: sl()));

  // ── Item Categories ───────────────────────────────────────────────
  sl.registerFactory(() => ItemCategoryBloc(getItemCategories: sl()));
  sl.registerLazySingleton(() => GetItemCategoriesUseCase(sl()));
  sl.registerLazySingleton<ItemCategoryRepository>(
      () => ItemCategoryRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ItemCategoryRemoteDataSource>(
      () => ItemCategoryRemoteDataSourceImpl(client: sl()));

  // ── Concessions by Item (homepage category filter) ────────────────
  sl.registerFactory(
      () => ConcessionByItemBloc(getConcessionsByItem: sl()));
  sl.registerLazySingleton(() => GetConcessionsByItemUseCase(sl()));
  sl.registerLazySingleton<ConcessionByItemRepository>(
      () => ConcessionByItemRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ConcessionByItemRemoteDataSource>(
      () => ConcessionByItemRemoteDataSourceImpl(client: sl()));

  // ── Store Items (all items, no category filter) ───────────────────
  sl.registerFactory(() => StoreItemBloc(getStoreItems: sl()));
  sl.registerLazySingleton(() => GetStoreItemsUseCase(sl()));
  sl.registerLazySingleton<StoreItemRepository>(
      () => StoreItemRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<StoreItemRemoteDataSource>(
      () => StoreItemRemoteDataSourceImpl(client: sl()));

  // ── Items by Category (store menu page) ──────────────────────────
  sl.registerFactory(() => ItemByCategoryBloc(
        getItemsByCategory: sl(),
        getAllItems: sl(),
      ));
  sl.registerLazySingleton(() => GetItemsByCategoryUseCase(sl()));
  sl.registerLazySingleton<ItemByCategoryRepository>(
      () => ItemByCategoryRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ItemByCategoryRemoteDataSource>(
      () => ItemByCategoryRemoteDataSourceImpl(client: sl()));
}