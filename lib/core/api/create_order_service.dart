import 'dart:convert';
import 'package:concession_tracker_ui/core/global_ordno.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 // Import the global class

class CreateOrderService {
  static const String _baseUrl =
      'http://192.168.10.144/ConcessionTracker/api/Users/create-order';
  static const String _orderNoPrefKey = 'order_no';

  // ── POST: create order ───────────────────────────────────────────
  Future<CreateOrderResponse> createOrder(CreateOrderRequest request) async {
    final body = jsonEncode(request.toJson());

    print('══════════════════════════════════════');
    print('[CreateOrderService] POST $_baseUrl');
    print('[CreateOrderService] Body: $body');
    print('══════════════════════════════════════');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('[CreateOrderService] Status: ${response.statusCode}');
    print('[CreateOrderService] Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final result = CreateOrderResponse.fromJson(decoded);

      // ── Save orderNo to SharedPreferences ──────────────────────
      await _saveOrderNo(result.orderNo);

      // ── Save orderNo globally ──────────────────────────────────
      GlobalOrderNo.setOrderNo(result.orderNo);

      return result;
    } else {
      throw Exception(
          'Failed to create order. Status: ${response.statusCode}');
    }
  }

  // ── Save orderNo to SharedPreferences ──────────────────────────
  Future<void> _saveOrderNo(int orderNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_orderNoPrefKey, orderNo);
    print('[CreateOrderService] orderNo $orderNo saved to SharedPreferences');
  }

  // ── Read orderNo from SharedPreferences ────────────────────────
  static Future<int?> getSavedOrderNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_orderNoPrefKey);
  }

  // ── Load orderNo from SharedPreferences to Global ───────────────
  static Future<void> loadOrderNoFromPrefs() async {
    final orderNo = await getSavedOrderNo();
    if (orderNo != null && orderNo > 0) {
      GlobalOrderNo.setOrderNo(orderNo);
      print('[CreateOrderService] Loaded orderNo from SharedPreferences: $orderNo');
    }
  }
}

// ── Request model ─────────────────────────────────────────────────
class CreateOrderRequest {
  final int concessionId;
  final int customerId;
  final String customerName;
  final List<OrderItem> items;

  CreateOrderRequest({
    required this.concessionId,
    required this.customerId,
    required this.customerName,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'concessionId': concessionId,
        'customerId': customerId,
        'customerName': customerName,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderItem {
  final int itemId;
  final String itemName;
  final int quantity;
  final double itemPrice;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.itemPrice,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'quantity': quantity,
        'itemPrice': itemPrice,
      };
}

// ── Response model ────────────────────────────────────────────────
class CreateOrderResponse {
  final String message;
  final int orderNo;

  CreateOrderResponse({required this.message, required this.orderNo});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) =>
      CreateOrderResponse(
        message: json['message'] ?? '',
        orderNo: json['orderNo'] ?? 0,
      );
}