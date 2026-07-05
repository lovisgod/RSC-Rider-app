import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_spacing.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';
import 'package:rsc_rider/core/utils/validators.dart';
import 'package:rsc_rider/core/widgets/app_button.dart';
import 'package:rsc_rider/core/widgets/app_snackbar.dart';
import 'package:rsc_rider/core/widgets/app_text_field.dart';
import 'package:rsc_rider/features/profile/domain/entities/rider_profile_entity.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rsc_rider/features/profile/presentation/cubit/profile_state.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key, required this.profile});

  final RiderProfileEntity profile;

  @override
  State<EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.profile.name);
  late final _emailController =
      TextEditingController(text: widget.profile.email);
  late final _phoneController =
      TextEditingController(text: widget.profile.phone);

  bool get _hasChanges =>
      _nameController.text.trim() != widget.profile.name ||
      _emailController.text.trim() != widget.profile.email ||
      _phoneController.text.trim() != widget.profile.phone;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileCubit>().updateProfile(
          _nameController.text.trim(),
          _phoneController.text.trim(),
          _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              (current.successMessage != null &&
                  current.successMessage != previous.successMessage) ||
              (current.error != null && current.error != previous.error),
          listener: (context, state) {
            if (state.successMessage != null) {
              Navigator.pop(context);
              AppSnackbar.showSuccess(context, state.successMessage!);
            } else if (state.error != null) {
              AppSnackbar.showError(context, state.error!);
            }
          },
          builder: (context, state) => Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  AppStrings.editProfile,
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _nameController,
                  label: AppStrings.fullName,
                  validator: Validators.required,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: AppStrings.phoneNumber,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: AppStrings.saveChanges,
                  isLoading: state.isSubmitting,
                  onPressed:
                      _hasChanges && !state.isSubmitting ? _save : null,
                ),
              ],
            ),
          ),
        ),
      );
}
