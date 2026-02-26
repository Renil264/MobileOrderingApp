import 'package:concession_tracker_ui/core/user_storage.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/register_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;

  AuthBloc(this.registerUser) : super(AuthInitial()) {
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final user = await registerUser(
          name: event.name,
          email: event.email,
          password: event.password,
          phoneNumber: event.phoneNumber,
        );

        // ✅ SAVE HERE
        await UserStorage.saveUser(
          id: user.userId,
          name: user.userName,
          email: user.userEmailId,
        );

        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
