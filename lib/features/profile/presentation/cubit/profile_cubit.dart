import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/features/profile/domain/usecases/change_rider_password_usecase.dart';
import 'package:rsc_rider/features/profile/domain/usecases/get_rider_profile_usecase.dart';
import 'package:rsc_rider/features/profile/domain/usecases/update_rider_profile_usecase.dart';
import 'package:rsc_rider/features/profile/domain/usecases/upload_rider_avatar_usecase.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._getProfile,
    required this._updateProfile,
    required this._uploadAvatar,
    required this._changePassword,
  }) : super(const ProfileState());

  final GetRiderProfileUsecase _getProfile;
  final UpdateRiderProfileUsecase _updateProfile;
  final UploadRiderAvatarUsecase _uploadAvatar;
  final ChangeRiderPasswordUsecase _changePassword;

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final profile = await _getProfile();
      emit(state.copyWith(riderProfile: profile, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _clean(e)));
    }
  }

  Future<void> updateProfile(String name, String phone, String email) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );
    try {
      final profile = await _updateProfile(name, phone, email);
      emit(
        state.copyWith(
          riderProfile: profile,
          isSubmitting: false,
          successMessage: AppStrings.profileUpdated,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _clean(e)));
    }
  }

  Future<void> uploadAvatar(File imageFile) async {
    emit(state.copyWith(isUploadingAvatar: true, clearError: true));
    try {
      final profile = await _uploadAvatar(imageFile);
      emit(
        state.copyWith(riderProfile: profile, isUploadingAvatar: false),
      );
    } catch (e) {
      emit(state.copyWith(isUploadingAvatar: false, error: _clean(e)));
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        clearSuccessMessage: true,
      ),
    );
    try {
      await _changePassword(currentPassword, newPassword);
      emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: AppStrings.passwordUpdated,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _clean(e)));
    }
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');
}
