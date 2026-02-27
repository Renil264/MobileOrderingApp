class SavedItemModel {
  final String concessionName;
  final int itemId;
  final String itemName;
  final double itemPrice;
  final int categoryId;

  SavedItemModel({
    required this.concessionName,
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.categoryId,
  });

  factory SavedItemModel.fromJson(Map<String, dynamic> json) {
    return SavedItemModel(
      concessionName: json['concessionName'] ?? '',
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      itemPrice: (json['itemPrice'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'concessionName': concessionName,
      'itemId': itemId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'categoryId': categoryId,
    };
  }
}