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

  // From JSON
  factory SavedItemModel.fromJson(Map<String, dynamic> json) {
    return SavedItemModel(
      concessionName: json['concessionName'] ?? '',
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? 'Unknown Item',
      itemPrice: (json['itemPrice'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? 0,
    );
  }

  // To JSON
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