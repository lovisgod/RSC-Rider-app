import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// Stub — replaced in Phase 10 with notifications list + read/unread state.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.notifications)),
        body: const Center(
          child: Text(
            'Notifications — Phase 10',
            style: AppTextStyles.headlineMedium,
          ),
        ),
      );
}
