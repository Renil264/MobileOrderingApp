class GlobalFCM {
  /// Holds the FCM token globally
  static String? _token;

  /// Get FCM Token
  static String get token => _token ?? "";

  /// Set FCM Token
  static set token(String? value) {
    _token = value;
  }

  /// Clear token (optional, useful during logout)
  static void clear() {
    _token = null;
  }
}
