import 'package:flutter/material.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';

class BikeMarker extends StatelessWidget {
  const BikeMarker({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.navy : AppColors.neutralGray,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('🏍️', style: TextStyle(fontSize: 24)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.onlineGreen : AppColors.offlineRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      );
}
