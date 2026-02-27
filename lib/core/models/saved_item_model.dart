class SaveItemRequest {
  final int concessionId;
  final int itemId;
  final int customerId;
  final int categoryId;
  final String itemName;
  final double itemPrice;

  SaveItemRequest({
    required this.concessionId,
    required this.itemId,
    required this.customerId,
    required this.categoryId,
    required this.itemName,
    required this.itemPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'concessionId': concessionId,
      'itemId': itemId,
      'customerId': customerId,
      'categoryId': categoryId,
      'itemName': itemName,
      'itemPrice': itemPrice,
    };
  }
}

class SaveItemResponse {
  final String message;

  SaveItemResponse({required this.message});

  factory SaveItemResponse.fromJson(Map<String, dynamic> json) {
    return SaveItemResponse(
      message: json['message'] ?? '',
    );
  }
}