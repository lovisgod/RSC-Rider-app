class RiderLocationRequestModel {
  const RiderLocationRequestModel({
    required this.latitude,
    required this.longitude,
    this.masterOrderId,
  });

  final double latitude;
  final double longitude;
  final String? masterOrderId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (masterOrderId != null) {
      map['masterOrderId'] = masterOrderId;
    }
    return map;
  }
}
