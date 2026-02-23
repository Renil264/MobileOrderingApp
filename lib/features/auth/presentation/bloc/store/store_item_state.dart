// lib/features/auth/presentation/bloc/storeitems/store_item_state.dart

import 'package:concession_tracker_ui/features/auth/domain/entities/store_item.dart';

abstract class StoreItemState {}

class StoreItemInitial extends StoreItemState {}

class StoreItemLoading extends StoreItemState {}

class StoreItemLoaded extends StoreItemState {
  final List<StoreItem> items;
  final String concessionName;
  StoreItemLoaded(this.items, {required this.concessionName});
}

class StoreItemError extends StoreItemState {
  final String message;
  StoreItemError(this.message);
}