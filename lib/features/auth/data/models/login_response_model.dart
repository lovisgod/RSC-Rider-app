import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.riderId,
    this.email = '',
  });

  final String accessToken;
  final String refreshToken;
  final String riderId;
  final String email;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        riderId: json['rider_id'] as String,
        email: json['email'] as String? ?? '',
      );

  RiderEntity toEntity() => RiderEntity(riderId: riderId, email: email);
}
