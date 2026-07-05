import 'package:equatable/equatable.dart';
import 'package:rsc_rider/features/delivery/data/models/complete_delivery_response_model.dart';

enum DeliveryStatus { idle, completing, completed, failed }

class DeliveryState extends Equatable {
  const DeliveryState({
    this.status = DeliveryStatus.idle,
    this.orderId = '',
    this.deliveryCode = '',
    this.orderIdError,
    this.codeError,
    this.completedDelivery,
    this.errorMessage,
  });

  final DeliveryStatus status;
  final String orderId;
  final String deliveryCode;
  final String? orderIdError;
  final String? codeError;
  final CompleteDeliveryResponseModel? completedDelivery;
  final String? errorMessage;

  DeliveryState copyWith({
    DeliveryStatus? status,
    String? orderId,
    String? deliveryCode,
    String? orderIdError,
    String? codeError,
    CompleteDeliveryResponseModel? completedDelivery,
    String? errorMessage,
    bool clearOrderIdError = false,
    bool clearCodeError = false,
    bool clearErrorMessage = false,
  }) =>
      DeliveryState(
        status: status ?? this.status,
        orderId: orderId ?? this.orderId,
        deliveryCode: deliveryCode ?? this.deliveryCode,
        orderIdError:
            clearOrderIdError ? null : (orderIdError ?? this.orderIdError),
        codeError: clearCodeError ? null : (codeError ?? this.codeError),
        completedDelivery: completedDelivery ?? this.completedDelivery,
        errorMessage:
            clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        status,
        orderId,
        deliveryCode,
        orderIdError,
        codeError,
        completedDelivery,
        errorMessage,
      ];
}
