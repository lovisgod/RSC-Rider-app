import 'package:rsc_rider/features/dashboard/domain/entities/rider_status_entity.dart';

class RiderStatusModel {
  const RiderStatusModel({required this.isOnline});

  final bool isOnline;

  factory RiderStatusModel.fromJson(Map<String, dynamic> json) =>
      RiderStatusModel(isOnline: json['is_online'] as bool? ?? false);

  RiderStatusEntity toEntity() => RiderStatusEntity(isOnline: isOnline);
}
