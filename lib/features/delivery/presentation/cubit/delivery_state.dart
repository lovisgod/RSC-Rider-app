import 'package:equatable/equatable.dart';
import 'package:rsc_rider/features/delivery/data/models/complete_delivery_response_model.dart';

enum DeliveryStatus { idle, completing, completed, failed }

class DeliveryState extends Equatable {
  const DeliveryState({
    this.status = DeliveryStatus.idle,
    this.deliveryCode = '',
    this.codeError,
    this.completedDelivery,
    this.errorMessage,
  });

  final DeliveryStatus status;
  final String deliveryCode;
  final String? codeError;
  final CompleteDeliveryResponseModel? completedDelivery;
  final String? errorMessage;

  DeliveryState copyWith({
    DeliveryStatus? status,
    String? deliveryCode,
    String? codeError,
    CompleteDeliveryResponseModel? completedDelivery,
    String? errorMessage,
    bool clearCodeError = false,
    bool clearErrorMessage = false,
  }) =>
      DeliveryState(
        status: status ?? this.status,
        deliveryCode: deliveryCode ?? this.deliveryCode,
        codeError: clearCodeError ? null : (codeError ?? this.codeError),
        completedDelivery: completedDelivery ?? this.completedDelivery,
        errorMessage:
            clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        status,
        deliveryCode,
        codeError,
        completedDelivery,
        errorMessage,
      ];
}
