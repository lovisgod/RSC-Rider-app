class CompleteDeliveryRequestModel {
  const CompleteDeliveryRequestModel(this.code);

  final String code;

  Map<String, dynamic> toJson() => {'code': code};
}
