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

  Map<String, dynamic> toJson() {
    return {
      "concessionId": concessionId,
      "customerId": customerId,
      "customerName": customerName,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      "itemId": itemId,
      "itemName": itemName,
      "quantity": quantity,
      "itemPrice": itemPrice,
    };
  }
}