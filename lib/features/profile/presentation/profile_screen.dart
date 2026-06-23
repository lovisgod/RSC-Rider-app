import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// Stub — replaced in Phase 10 with profile / edit / documents screens.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.profile)),
        body: const Center(
          child: Text(
            'Profile — Phase 10',
            style: AppTextStyles.headlineMedium,
          ),
        ),
      );
}
