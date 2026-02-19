class AuthSession {
  static String? email;
  static String? name;
  static String? profilePhoto;
  static String? provider;
  static String? providerToken;

  static void clear() {
    email = null;
    name = null;
    profilePhoto = null;
    provider = null;
    providerToken = null;
  }

  static Map<String, dynamic> toBackendPayload() {
    return {
      "email": email,
      "name": name,
      "profilePhoto": profilePhoto,
      "provider": provider,
      "providerToken": providerToken,
    };
  }

  static void debugPrintSession() {
    print('====== SOCIAL LOGIN PAYLOAD ======');
    print('Email        : $email');
    print('Name         : $name');
    print('Photo URL    : $profilePhoto');
    print('Provider     : $provider');
    print('ProviderToken: $providerToken');
    print('==================================');
  }
}
