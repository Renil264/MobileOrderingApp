// lib/features/concessions/data/models/concession_model.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/concession_entity.dart';



class ConcessionModel extends Concession {
  const ConcessionModel({required super.name});

  factory ConcessionModel.fromString(String name) {
    return ConcessionModel(name: name);
  }
}