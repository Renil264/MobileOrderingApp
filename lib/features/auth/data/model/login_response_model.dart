class LoginResponseModel {
  final String message;
  final int? usrId;   // 👈 Make nullable
  final String? name; // 👈 Make nullable

  LoginResponseModel({
    required this.message,
    this.usrId,
    this.name,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? '',
      usrId: json['usr_int_usrid'] is int
          ? json['usr_int_usrid']
          : int.tryParse(json['usr_int_usrid']?.toString() ?? ''),
      name: json['usr_vch_name'],
    );
  }
}
