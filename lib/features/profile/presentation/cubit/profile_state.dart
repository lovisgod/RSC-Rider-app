import 'package:equatable/equatable.dart';
import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.riderProfile,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isUploadingAvatar = false,
    this.error,
    this.successMessage,
  });

  final RiderProfileEntity? riderProfile;
  final bool isLoading;
  final bool isSubmitting;
  final bool isUploadingAvatar;
  final String? error;
  final String? successMessage;

  ProfileState copyWith({
    RiderProfileEntity? riderProfile,
    bool? isLoading,
    bool? isSubmitting,
    bool? isUploadingAvatar,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) =>
      ProfileState(
        riderProfile: riderProfile ?? this.riderProfile,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
        error: clearError ? null : (error ?? this.error),
        successMessage:
            clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      );

  @override
  List<Object?> get props => [
        riderProfile,
        isLoading,
        isSubmitting,
        isUploadingAvatar,
        error,
        successMessage,
      ];
}
