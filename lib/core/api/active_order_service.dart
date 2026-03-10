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
      try {
        // Parse the response as JSON
        final dynamic decoded = jsonDecode(response.body);
        
        List<dynamic> ordersList = [];

        // Check if response is a direct List
        if (decoded is List) {
          ordersList = decoded;
          print('[ActiveOrdersService] Response is a direct List');
        } 
        // Check if response is a Map with 'data' field
        else if (decoded is Map<String, dynamic>) {
          ordersList = decoded['data'] ?? [];
          print('[ActiveOrdersService] Response is a Map, extracted data field');
        } 
        // Unexpected format
        else {
          print('[ActiveOrdersService] Unexpected response format: ${decoded.runtimeType}');
          return [];
        }

        print('[ActiveOrdersService] Found ${ordersList.length} orders');

        // If the list is empty, return an empty list (cart is empty)
        if (ordersList.isEmpty) {
          print('[ActiveOrdersService] No active orders found');
          return [];
        }

        // Map each item to ActiveOrderItem object
        final items = <ActiveOrderItem>[];
        for (var item in ordersList) {
          try {
            if (item is Map<String, dynamic>) {
              items.add(ActiveOrderItem.fromJson(item));
            }
          } catch (e) {
            print('[ActiveOrdersService] Error parsing item: $e');
            print('[ActiveOrdersService] Item data: $item');
          }
        }

        print('[ActiveOrdersService] Successfully parsed ${items.length} items');
        return items;
      } catch (e) {
        print('[ActiveOrdersService] Error during parsing: $e');
        print('[ActiveOrdersService] Error stack trace: $e');
        throw Exception('Failed to parse active orders: $e');
      }
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
    try {
      // Safely parse DateTime
      DateTime parsedDate = DateTime.now();
      if (json['orderDate'] != null) {
        try {
          parsedDate = DateTime.parse(json['orderDate'].toString());
        } catch (e) {
          print('[ActiveOrderItem] Error parsing date: $e');
          parsedDate = DateTime.now();
        }
      }

      return ActiveOrderItem(
        concessionName: json['concessionName']?.toString() ?? '',
        itemId: _toInt(json['itemId']),
        itemName: json['itemName']?.toString() ?? '',
        itemPrice: _toDouble(json['itemPrice']),
        quantity: _toInt(json['quantity']),
        totalAmount: _toDouble(json['totalAmount']),
        orderDate: parsedDate,
      );
    } catch (e) {
      print('[ActiveOrderItem.fromJson] Error: $e');
      throw Exception('Error parsing order item: $e');
    }
  }

  // Helper function to safely convert to int
  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper function to safely convert to double
  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}