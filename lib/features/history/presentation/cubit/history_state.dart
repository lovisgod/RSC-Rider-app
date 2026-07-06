import 'package:equatable/equatable.dart';
import 'package:rsc_rider/features/history/domain/entities/delivery_history_entity.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.deliveries = const [],
    this.isLoading = false,
    this.error,
    this.totalEarned = 0.0,
    this.totalFromApi = 0,
  });

  final List<DeliveryHistoryEntity> deliveries;
  final bool isLoading;
  final String? error;

  // From the API's pagination summary (totalEarnedMinor / 100, and total).
  final double totalEarned;
  final int totalFromApi;

  // Sum of the currently loaded batch — used for the "this session" panel.
  double get totalEarnings =>
      deliveries.fold(0.0, (sum, delivery) => sum + delivery.earned);

  int get totalDeliveries => deliveries.length;

  HistoryState copyWith({
    List<DeliveryHistoryEntity>? deliveries,
    bool? isLoading,
    String? error,
    bool clearError = false,
    double? totalEarned,
    int? totalFromApi,
  }) =>
      HistoryState(
        deliveries: deliveries ?? this.deliveries,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        totalEarned: totalEarned ?? this.totalEarned,
        totalFromApi: totalFromApi ?? this.totalFromApi,
      );

  @override
  List<Object?> get props =>
      [deliveries, isLoading, error, totalEarned, totalFromApi];
}
