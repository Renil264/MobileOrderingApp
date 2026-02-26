class UserEntity {
  final int userId;
  final String userName;
  final String userEmailId;
  final String userPhoneNumber;
  final bool loginStatus;

  UserEntity({
    required this.userId,
    required this.userName,
    required this.userEmailId,
    required this.userPhoneNumber,
    required this.loginStatus,
  });
}