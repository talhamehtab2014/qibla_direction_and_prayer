import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/qibla_provider.dart';
import 'package:qibla_direction/providers/theme_provider.dart';
import 'package:qibla_direction/widgets/compass_widget.dart';
import 'package:qibla_direction/widgets/location_info_card.dart';
import 'package:qibla_direction/widgets/calibration_guide_dialog.dart';

/// Main screen for Qibla compass functionality
class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with WidgetsBindingObserver {
  bool _hasNavigatedToSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize compass when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QiblaProvider>().initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns from app settings, re-initialize once
    if (state == AppLifecycleState.resumed && _hasNavigatedToSettings) {
      _hasNavigatedToSettings = false; // Reset flag
      final provider = context.read<QiblaProvider>();
      // Only re-initialize if permission was previously denied
      if (provider.errorMessage != null) {
        provider.initialize();
      }
    }
  }

  /// Show dialog to open app settings
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Location Permission Required',
            style: TextStyle(fontSize: 18.sp),
          ),
          content: Text(
            'Location permission is required to calculate Qibla direction. Please enable it in app settings.',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // Set flag before opening settings
                _hasNavigatedToSettings = true;
                // Open app settings
                await openAppSettings();
              },
              child: Text('Open Settings', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Consumer<QiblaProvider>(
        builder: (context, qiblaProvider, child) {
          // Loading state
          if (qiblaProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 24.h),
                  Text(
                    'Initializing compass...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          // Error state
          if (qiblaProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80.r,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      qiblaProvider.errorMessage!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (qiblaProvider.isPermanentlyDenied) {
                          _showSettingsDialog(context);
                        } else {
                          qiblaProvider.initialize();
                        }
                      },
                      icon: Icon(
                        qiblaProvider.isPermanentlyDenied
                            ? Icons.settings
                            : Icons.refresh,
                        size: 20.r,
                      ),
                      label: Text(
                        qiblaProvider.isPermanentlyDenied
                            ? 'Open Settings'
                            : 'Try Again',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Success state - Show compass
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Calibration Warning
                  if (qiblaProvider.needsCalibration)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Card(
                        color: Colors.orange.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Colors.orange.withOpacity(0.5),
                            width: 1.w,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[800],
                                size: 24.r,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Low Compass Accuracy',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange[900],
                                          ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              const CalibrationGuideDialog(),
                                        );
                                      },
                                      child: Text(
                                        'How to calibrate?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.orange[900],
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Instructions card
                  Card(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Hold your device flat and rotate until the arrow points upward',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Compass widget
                  Center(
                    child: CompassWidget(
                      compassHeading: qiblaProvider.compassHeading,
                      qiblaDirection: qiblaProvider.qiblaDirection,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Qibla status indicator
                  if (qiblaProvider.qiblaDirection != null)
                    _buildQiblaStatusIndicator(
                      context,
                      qiblaProvider.qiblaDirection!,
                    ),
                  SizedBox(height: 24.h),

                  // Location information
                  if (qiblaProvider.locationData != null)
                    LocationInfoCard(locationData: qiblaProvider.locationData!),
                  SizedBox(height: 16.h),

                  // Refresh location button
                  OutlinedButton.icon(
                    onPressed: () {
                      qiblaProvider.refreshLocation();
                    },
                    icon: Icon(Icons.refresh, size: 20.r),
                    label: const Text('Refresh Location'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQiblaStatusIndicator(
    BuildContext context,
    double qiblaDirection,
  ) {
    final isAligned = qiblaDirection.abs() < 5; // Within 5 degrees

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isAligned
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isAligned
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
          width: 2.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAligned ? Icons.check_circle : Icons.explore,
            color: isAligned
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
            size: 28.r,
          ),
          SizedBox(width: 12.w),
          Text(
            isAligned
                ? 'Aligned with Qibla!'
                : 'Rotate ${qiblaDirection > 0 ? "clockwise" : "counter-clockwise"}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isAligned
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
