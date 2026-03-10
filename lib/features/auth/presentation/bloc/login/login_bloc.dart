import 'package:concession_tracker_ui/core/global_user.dart';
import 'package:concession_tracker_ui/core/user_storage.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/login_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/login/login_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase) : super(LoginInitial()) {
    on<Login>(_onLogin);
  }

  Future<void> _onLogin(Login event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final result = await loginUseCase(
        email: event.email,
        password: event.password,
        fcmToken: event.fcmToken,
        uuid: event.uuid
      );

      // Persist user + write isLoggedIn=true to SharedPreferences.
      // GlobalUser.setUser() covers both in-memory and SP in one call,
      // so SplashScreen._route() will see isLoggedIn=true on next cold start.
      await GlobalUser.setUser(
        id: result.userId,
        name: result.name,
        email: event.email,
      );

      // Also write UserStorage keys (user_id / user_name / user_email)
      // so UserStorage.isLoggedIn() and loadUser() continue to work.
      await UserStorage.saveUser(
        id: result.userId,
        name: result.name,
        email: event.email,
      );

      emit(LoginSuccess(result));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}