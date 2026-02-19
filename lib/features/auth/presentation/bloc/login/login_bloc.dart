import 'package:concession_tracker_ui/features/auth/domain/entities/login_entity.dart';
import 'package:concession_tracker_ui/features/auth/domain/usecases/login_usecase.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/login/login_event.dart';
import 'package:concession_tracker_ui/features/auth/presentation/bloc/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase) : super(LoginInitial()) {
    on<Login>(_onLogin);
  }

  Future<void> _onLogin(
      Login event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final result = await loginUseCase(
        email: event.email,
        password: event.password,
        fcmToken: event.fcmToken,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("userId", result.userId);
      await prefs.setString("userName", result.name);

      emit(LoginSuccess(result as LoginEntity));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
