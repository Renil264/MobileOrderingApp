// Global Order Number Storage
class GlobalOrderNo {
  static int _orderNo = 0;

  /// Set the order number globally
  static void setOrderNo(int orderNo) {
    _orderNo = orderNo;
    print('[GlobalOrderNo] Order No set to: $_orderNo');
  }

  /// Get the order number globally
  static int get orderNo => _orderNo;

  /// Check if order number is available
  static bool get hasOrderNo => _orderNo > 0;

  /// Clear the order number (use when order is completed)
  static void clearOrderNo() {
    _orderNo = 0;
    print('[GlobalOrderNo] Order No cleared');
  }

  /// Reset to default
  static void reset() {
    _orderNo = 0;
  }
}