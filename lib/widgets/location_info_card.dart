import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qibla_direction/models/location_data.dart';

/// Widget to display location information and Qibla details
class LocationInfoCard extends StatelessWidget {
  final LocationData locationData;

  const LocationInfoCard({super.key, required this.locationData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            Text(
              'Location Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            // Coordinates
            _buildInfoRow(
              context,
              icon: Icons.location_on,
              label: 'Coordinates',
              value:
                  '${locationData.latitude.toStringAsFixed(6)}°, '
                  '${locationData.longitude.toStringAsFixed(6)}°',
            ),
            Divider(height: 24.h),

            // Qibla bearing
            _buildInfoRow(
              context,
              icon: Icons.explore,
              label: 'Qibla Bearing',
              value: '${locationData.qiblaBearing.toStringAsFixed(2)}°',
            ),
            Divider(height: 24.h),

            // Distance to Kaaba
            _buildInfoRow(
              context,
              icon: Icons.social_distance,
              label: 'Distance to Kaaba',
              value: '${locationData.distanceToKaaba.toStringAsFixed(2)} km',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28.r),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
