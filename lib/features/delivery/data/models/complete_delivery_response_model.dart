import 'package:rsc_rider/core/utils/formatters.dart';

class CompleteDeliveryResponseModel {
  const CompleteDeliveryResponseModel({
    required this.orderId,
    required this.status,
    required this.total,
    required this.deliveryAddress,
    required this.paymentReference,
    required this.itemCount,
    required this.firstItemName,
  });

  final String orderId;
  final String status;
  final double total;
  final String deliveryAddress;
  final String paymentReference;
  final int itemCount;
  final String firstItemName;

  factory CompleteDeliveryResponseModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>;
    final lineItems = json['lineItems'] as List<dynamic>? ?? [];
    final firstItem =
        lineItems.isNotEmpty ? lineItems.first as Map<String, dynamic> : null;

    return CompleteDeliveryResponseModel(
      orderId: order['id'] as String,
      status: order['status'] as String,
      total: (order['totalMinor'] as num) / 100,
      deliveryAddress: order['deliveryAddress'] as String,
      paymentReference: order['paymentReference'] as String,
      itemCount: lineItems.length,
      firstItemName: firstItem != null
          ? (firstItem['itemNameSnapshot'] as String? ?? '')
          : '',
    );
  }

  String get shortOrderId {
    final id = orderId.length > 8
        ? orderId.substring(orderId.length - 8)
        : orderId;
    return '#${id.toUpperCase()}';
  }

  String get displayTotal => AppFormatters.currency(total, decimals: false);
}
