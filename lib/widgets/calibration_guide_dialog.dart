import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalibrationGuideDialog extends StatelessWidget {
  const CalibrationGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.vibration,
              size: 64.r,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Calibrate Your Compass',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'To improve accuracy, move your device in a "Figure 8" motion as shown below:',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Placeholder for an animation/image of Figure 8
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.gesture,
                      size: 48.r,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      '∞',
                      style: TextStyle(
                        fontSize: 48.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}
