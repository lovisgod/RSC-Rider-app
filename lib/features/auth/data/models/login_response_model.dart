import 'package:rsc_rider/features/auth/domain/entities/rider_entity.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.id, required this.role});

  final String id;
  final String role;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['data']['user'] as Map<String, dynamic>;
    return LoginResponseModel(
      id: user['id'] as String,
      role: user['role'] as String,
    );
  }

  RiderEntity toEntity() => RiderEntity(riderId: id, role: role);
}
