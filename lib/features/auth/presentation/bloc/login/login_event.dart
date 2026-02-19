

import 'package:equatable/equatable.dart' ;

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class Login extends LoginEvent {
  final String email;
  final String password;
  final String fcmToken;

  Login({
    required this.email,
    required this.password,
    required this.fcmToken,
  });

  @override
  List<Object?> get props => [email, password, fcmToken];
}
