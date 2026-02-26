import 'package:concession_tracker_ui/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:concession_tracker_ui/features/auth/domain/repositories/auth_repositories.dart';

import '../../domain/entities/user_entity.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {

    final userModel = await remoteDataSource.registerUser(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );

    return userModel; // Model extends Entity
  }
}