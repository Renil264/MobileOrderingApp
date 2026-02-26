class GlobalMarket {
  static String _marketName = '';
  static int _marketId = 0;

  static void setMarket(String name) {
    _marketName = name;
  }

  static void setMarketId(int id) {
    _marketId = id;
  }

  static String get marketName => _marketName;
  static int get marketId => _marketId;
}