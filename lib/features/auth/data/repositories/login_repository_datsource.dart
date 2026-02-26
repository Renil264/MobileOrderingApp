import '../../domain/entities/login_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDatasource remoteDatasource;

  LoginRepositoryImpl(this.remoteDatasource );

  @override
  Future<LoginEntity> login({
    required String email,
    required String password,
    required String fcmToken,
  }) {
    return remoteDatasource.login(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
  }
}
