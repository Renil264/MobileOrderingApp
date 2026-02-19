import '../entities/login_entity.dart';
import '../repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<LoginEntity> call({
    required String email,
    required String password,
    required String fcmToken,
  }) {
    return repository.login(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
  }
}
