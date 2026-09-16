import 'package:equatable/equatable.dart';

class RiderProfileEntity extends Equatable {
  const RiderProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.vehicleType,
    this.plateNumber,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;
  // Set by the admin, never editable from the app.
  final String? vehicleType;
  final String? plateNumber;

  // First letter of each word in the name, max 2 characters.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  // e.g. "Motorcycle · LAG-234-XY"; empty when the admin hasn't set a vehicle.
  String get displayVehicle {
    if (vehicleType != null && plateNumber != null) {
      return '${vehicleType!} · ${plateNumber!}';
    }
    return vehicleType ?? '';
  }

  // "2348031234117" -> "08031234117"
  String get displayPhone {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('234')) return '0${digits.substring(3)}';
    return phone;
  }

  RiderProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) =>
      RiderProfileEntity(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        vehicleType: vehicleType,
        plateNumber: plateNumber,
      );

  @override
  List<Object?> get props =>
      [id, name, email, phone, role, avatarUrl, vehicleType, plateNumber];
}
