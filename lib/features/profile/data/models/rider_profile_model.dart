import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';

class RiderProfileModel {
  const RiderProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;

  factory RiderProfileModel.fromJson(Map<String, dynamic> json) =>
      RiderProfileModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  RiderProfileEntity toEntity() => RiderProfileEntity(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role,
        avatarUrl: avatarUrl,
      );
}
