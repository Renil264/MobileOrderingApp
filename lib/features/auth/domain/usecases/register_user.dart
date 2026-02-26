import 'package:concession_tracker_ui/features/auth/domain/repositories/auth_repositories.dart';
import '../entities/user_entity.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String phoneNumber, // ✅ added
  }) {
    return repository.registerUser(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber, // ✅ forward it
    );
  }
}