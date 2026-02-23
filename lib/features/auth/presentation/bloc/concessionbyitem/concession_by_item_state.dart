// lib/features/auth/presentation/bloc/concessionbyitem/concession_by_item_state.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/concession_by_item.dart';

abstract class ConcessionByItemState {}

class ConcessionByItemInitial extends ConcessionByItemState {}

class ConcessionByItemLoading extends ConcessionByItemState {}

class ConcessionByItemLoaded extends ConcessionByItemState {
  final List<ConcessionByItem> concessions;
  final int? selectedCategoryId; // null means "All"
  ConcessionByItemLoaded(this.concessions, {this.selectedCategoryId});
}

class ConcessionByItemError extends ConcessionByItemState {
  final String message;
  ConcessionByItemError(this.message);
}