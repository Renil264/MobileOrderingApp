class RegisterResponseModel {
  final int userId;
  final String userName;
  final String userPhoneNumber;
  final String userEmailId;
  final bool loginStatus;

  RegisterResponseModel({
    required this.userId,
    required this.userName,
    required this.userPhoneNumber,
    required this.userEmailId,
    required this.loginStatus,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      userId: json["userId"],
      userName: json["userName"],
      userPhoneNumber: json["userPhoneNumber"].toString(),
      userEmailId: json["userEmailId"],
      loginStatus: json["loginStatus"],
    );
  }
}