import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String fcmToken;

  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.fcmToken,
  });

  @override
  List<Object?> get props => [name, email, password,phoneNumber, fcmToken];
}
