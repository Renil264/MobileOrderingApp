// lib/features/auth/data/models/concession_by_item_model.dart

import '../../domain/entities/concession_by_item.dart';

class ConcessionByItemModel extends ConcessionByItem {
  const ConcessionByItemModel({required super.concessionName});

  factory ConcessionByItemModel.fromJson(Map<String, dynamic> json) {
    return ConcessionByItemModel(
      concessionName: json['concessionName'] as String,
    );
  }
}