import 'dart:io';

import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';

abstract interface class RiderProfileRepository {
  Future<RiderProfileEntity> getProfile();

  Future<RiderProfileEntity> updateProfile(
    String name,
    String phone,
    String email,
  );

  Future<RiderProfileEntity> uploadAvatar(File imageFile);

  Future<void> changePassword(String currentPassword, String newPassword);
}
