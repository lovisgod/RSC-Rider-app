import 'package:rsc_rider/features/history/data/models/delivery_history_model.dart';

class DeliveryHistoryResponseModel {
  const DeliveryHistoryResponseModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalEarnedMinor,
    required this.currency,
    required this.deliveries,
  });

  final int page;
  final int limit;
  final int total;
  final int totalEarnedMinor;
  final String currency;
  final List<DeliveryHistoryModel> deliveries;

  double get totalEarned => totalEarnedMinor / 100;

  factory DeliveryHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      DeliveryHistoryResponseModel(
        page: json['page'] as int,
        limit: json['limit'] as int,
        total: json['total'] as int,
        totalEarnedMinor: json['totalEarnedMinor'] as int,
        currency: json['currency'] as String,
        deliveries: (json['deliveries'] as List<dynamic>)
            .map(
              (d) => DeliveryHistoryModel.fromJson(d as Map<String, dynamic>),
            )
            .toList(),
      );
}
