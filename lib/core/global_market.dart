class GlobalMarket {
  static String _marketName = '';

  static void setMarket(String name) {
    _marketName = name;
  }

  static String get marketName => _marketName;
}