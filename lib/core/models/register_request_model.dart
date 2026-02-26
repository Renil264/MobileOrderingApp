class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String fcmToken;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password": password,
        "phoneNumber": phoneNumber,
        "fcmToken": fcmToken,
      };
}