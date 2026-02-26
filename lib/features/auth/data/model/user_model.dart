import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required int userId,
    required String userName,
    required String userEmailId,
    required String userPhoneNumber,
    required bool loginStatus,
  }) : super(
          userId: userId,
          userName: userName,
          userEmailId: userEmailId,
          userPhoneNumber: userPhoneNumber,
          loginStatus: loginStatus,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? "",
      userEmailId: json['userEmailId'] ?? "",
      userPhoneNumber: json['userPhoneNumber']?.toString() ?? "",
      loginStatus: json['loginStatus'] ?? false,
    );
  }
}