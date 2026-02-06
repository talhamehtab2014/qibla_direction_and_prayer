import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/qibla_provider.dart';
import 'package:qibla_direction/providers/theme_provider.dart';
import 'package:qibla_direction/screens/qibla_compass_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    children: [
                      Icon(
                        Icons.explore,
                        size: 80.r,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Welcome to Qibla Direction',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Find the accurate direction to Qibla from anywhere in the world',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Compass Card
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => QiblaProvider(),
                          child: const QiblaCompassScreen(),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.compass_calibration,
                            size: 32.r,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qibla Compass',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Use compass to find direction',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.r,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              SizedBox(height: 12.h),

              // Map View Card
              Card(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Map view feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.map,
                            size: 32.r,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Map View',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'View Qibla direction on map',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.r,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Prayer Times Card
              Card(
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prayer times feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.access_time,
                            size: 32.r,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prayer Times',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Check daily prayer times',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.r,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Theme Toggle Info
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.nightlight_round : Icons.wb_sunny,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Currently in ${isDark ? "Dark" : "Light"} mode. Tap the icon in the app bar to switch themes.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
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
    );
  }
}
