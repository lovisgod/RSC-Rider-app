import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// Stub — replaced in Phase 10 with paginated delivery history list.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.deliveryHistory)),
        body: const Center(
          child: Text(
            'History — Phase 10',
            style: AppTextStyles.headlineMedium,
          ),
        ),
      );
}
