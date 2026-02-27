import 'dart:convert';
import 'package:http/http.dart' as http;

class ActiveOrdersService {
  static const String _baseUrl =
      'http://192.168.10.144/ConcessionTracker/api/Users/active-orders';

  Future<List<ActiveOrderItem>> fetchActiveOrders({
    required int marketId,
    required int userId,
  }) async {
    final url = '$_baseUrl/$marketId/$userId';

    print('══════════════════════════════════════');
    print('[ActiveOrdersService] GET $url');
    print('══════════════════════════════════════');

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    print('[ActiveOrdersService] Status : ${response.statusCode}');
    print('[ActiveOrdersService] Body   : ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((e) => ActiveOrderItem.fromJson(e)).toList();
    } else {
      throw Exception(
          'Failed to load active orders. Status: ${response.statusCode}');
    }
  }
}

class ActiveOrderItem {
  final String concessionName;
  final int itemId;
  final String itemName;
  final double itemPrice;
  final int quantity;
  final double totalAmount;
  final DateTime orderDate;

  ActiveOrderItem({
    required this.concessionName,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.quantity,
    required this.totalAmount,
    required this.orderDate,
  });

  factory ActiveOrderItem.fromJson(Map<String, dynamic> json) {
    return ActiveOrderItem(
      concessionName: json['concessionName'] ?? '',
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      itemPrice: (json['itemPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
    );
  }
}