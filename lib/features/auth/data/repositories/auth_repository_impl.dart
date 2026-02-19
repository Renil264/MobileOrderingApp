import 'package:concession_tracker_ui/features/auth/domain/repositories/auth_repositories.dart';

import '../../domain/entities/user_entity.dart';

import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> registerUser({
    required String name,
    required String email,
    required String password,
  }) {
    return remoteDataSource.registerUser(
      name: name,
      email: email,
      password: password,
    );
  }
}
