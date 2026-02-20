// lib/injection_container.dart
// Run get_it to wire up dependencies.
// Add this to your main.dart: await setupLocator(); before runApp()

import 'package:concession_tracker_ui/features/auth/data/datasources/remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/data/repositories/concession_repository_impl.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/concession_repository.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/concession_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/concessionlist/concession_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;



final sl = GetIt.instance;

Future<void> setupLocator() async {
  // BLoC
  sl.registerFactory(
    () => ConcessionBloc(getConcessions: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetConcessions(sl()));

  // Repositories
  sl.registerLazySingleton<ConcessionRepository>(
    () => ConcessionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ConcessionRemoteDataSource>(
    () => ConcessionRemoteDataSourceImpl(client: sl()),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
}