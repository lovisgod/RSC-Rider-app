import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// Stub — replaced in Phase 9 with Google Maps + live location + status stepper.
class ActiveDeliveryScreen extends StatelessWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.activeDelivery)),
        body: const Center(
          child: Text(
            'Active Delivery — Phase 9',
            style: AppTextStyles.headlineMedium,
          ),
        ),
      );
}
