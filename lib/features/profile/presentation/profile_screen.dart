import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/widgets/app_loader.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/error_view.dart';
import 'package:rsc_rider/core/widgets/logout_confirmation_sheet.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rsc_rider/features/auth/presentation/bloc/auth_state.dart';
import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_state.dart';
import 'package:rsc_rider/features/profile/presentation/widgets/edit_profile_bottom_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => GetIt.instance<ProfileCubit>()..loadProfile(),
          ),
          BlocProvider(create: (_) => GetIt.instance<AuthBloc>()),
        ],
        child: const _ProfileView(),
      );
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) context.go(RouteNames.login);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: BlocConsumer<ProfileCubit, ProfileState>(
            listenWhen: (previous, current) =>
                current.error != null &&
                current.error != previous.error &&
                current.riderProfile != null,
            listener: (context, state) =>
                AppSnackbar.showError(context, state.error!),
            builder: (context, state) {
              final profile = state.riderProfile;
              if (state.isLoading && profile == null) {
                return const Center(child: AppLoader());
              }
              if (state.error != null && profile == null) {
                return ErrorView(
                  message: state.error!,
                  onRetry: () => context.read<ProfileCubit>().loadProfile(),
                );
              }
              if (profile == null) return const SizedBox.shrink();
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.navyDark,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: _AvatarHeader(
                        profile: profile,
                        isUploading: state.isUploadingAvatar,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoCard(profile: profile),
                  const _SecurityCard(),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => showLogoutConfirmationSheet(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size.fromHeight(
                            AppSpacing.buttonHeight,
                          ),
                        ),
                        child: Text(
                          AppStrings.logout,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            },
          ),
        ),
      );
}

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({required this.profile, required this.isUploading});

  final RiderProfileEntity profile;
  final bool isUploading;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          GestureDetector(
            onTap: isUploading ? null : () => _showPickerSheet(context),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: profile.avatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: profile.avatarUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  _InitialsAvatar(initials: profile.initials),
                              errorWidget: (_, _, _) =>
                                  _InitialsAvatar(initials: profile.initials),
                            )
                          : _InitialsAvatar(initials: profile.initials),
                    ),
                  ),
                  if (isUploading)
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0x66000000),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppLoader(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile.email,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
          Text(
            profile.displayPhone,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      );

  void _showPickerSheet(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(AppStrings.takePhoto),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _pickAndUpload(cubit, ImageSource.camera);
              },
            ),
            ListTile(
              title: const Text(AppStrings.chooseFromGallery),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _pickAndUpload(cubit, ImageSource.gallery);
              },
            ),
            ListTile(
              title: const Text(AppStrings.cancel),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ProfileCubit cubit, ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) await cubit.uploadAvatar(File(picked.path));
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.navy,
        alignment: Alignment.center,
        child: Text(
          initials,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textOnDark,
          ),
        ),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.profile});

  final RiderProfileEntity profile;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                AppStrings.accountInformation,
                style: AppTextStyles.labelMedium,
              ),
            ),
            _InfoRow(
              icon: Icons.person_outline,
              label: AppStrings.fullName,
              value: profile.name,
              onTap: () => _openEdit(context),
            ),
            const Divider(
              height: 1,
              color: AppColors.divider,
              indent: 16,
              endIndent: 16,
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              label: AppStrings.email,
              value: profile.email,
              onTap: () => _openEdit(context),
            ),
            const Divider(
              height: 1,
              color: AppColors.divider,
              indent: 16,
              endIndent: 16,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: AppStrings.phoneNumber,
              value: profile.displayPhone,
              onTap: () => _openEdit(context),
            ),
          ],
        ),
      );

  void _openEdit(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: EditProfileBottomSheet(profile: profile),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(label, style: AppTextStyles.bodyMedium),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
        onTap: onTap,
      );
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          0,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(AppStrings.security, style: AppTextStyles.labelMedium),
            ),
            ListTile(
              leading: const Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
              ),
              title: const Text(
                AppStrings.changePassword,
                style: AppTextStyles.bodyMedium,
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
              onTap: () => context.push(RouteNames.changePassword),
            ),
          ],
        ),
      );
}
