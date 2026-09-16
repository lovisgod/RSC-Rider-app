class AvailabilityResponseModel {
  const AvailabilityResponseModel({
    required this.id,
    required this.riderStatus,
    required this.isAvailable,
  });

  final String id;
  final String riderStatus;
  final bool isAvailable;

  factory AvailabilityResponseModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityResponseModel(
        id: json['id'] as String,
        riderStatus: json['riderStatus'] as String,
        isAvailable: json['isAvailable'] as bool,
      );
}
