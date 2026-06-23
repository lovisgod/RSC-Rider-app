import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_text_styles.dart';

// Stub — replaced in Phase 8 with accept/reject bottom sheet + countdown timer.
class IncomingRequestScreen extends StatelessWidget {
  const IncomingRequestScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Incoming Request')),
        body: const Center(
          child: Text(
            'Dispatch — Phase 8',
            style: AppTextStyles.headlineMedium,
          ),
        ),
      );
}
