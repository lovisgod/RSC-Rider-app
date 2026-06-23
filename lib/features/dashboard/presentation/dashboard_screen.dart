import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// Stub — replaced in Phase 7 with online/offline toggle + earnings summary.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.appName)),
        body: const Center(
          child: Text(
            'Dashboard — Phase 7',
            style: AppTextStyles.headlineMedium,
          ),
        ),
      );
}
