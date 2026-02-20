class GlobalUser {
  static int? _id;
  static String? _name;
  static String? _email;

  // ===== GETTERS =====
  static int get id => _id ?? 0;
  static String get name => _name ?? "";
  static String get email => _email ?? "";

  // ===== SETTERS =====
  static set id(int? value) => _id = value;
  static set name(String? value) => _name = value;
  static set email(String? value) => _email = value;

  static void clear() {
    _id = null;
    _name = null;
    _email = null;
  }
}
