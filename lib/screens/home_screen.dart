import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/qibla_provider.dart';
import 'package:qibla_direction/providers/theme_provider.dart';
import 'package:qibla_direction/providers/hadith_provider.dart';
import 'package:qibla_direction/screens/qibla_compass_screen.dart';
import 'package:qibla_direction/screens/prayer_times_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Qibla & Prayer Times',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: primaryColor,
              ),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF1A1A1A)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Text(
                    'Assalamu Alaikum,',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Welcome to Qibla & Prayer',
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Random Hadith Card
                  Consumer<HadithProvider>(
                    builder: (context, hadithProvider, child) {
                      if (hadithProvider.isLoading) {
                        return _buildShimmerLoading();
                      }
                      final hadith = hadithProvider.currentHadith;
                      if (hadith == null) return const SizedBox.shrink();

                      return Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  color: Colors.white,
                                  size: 24.r,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Daily Hadith',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              hadith.text,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16.sp,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '- ${hadith.narrator ?? "Unknown Narrator"}',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      hadith.source ?? "Sunnah",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32.h),

                  // Main Services Grid
                  Text(
                    'Our Features',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          title: 'Qibla Compass',
                          subtitle: 'Accurate Direction',
                          icon: Icons.explore_rounded,
                          color: const Color(0xFF2E7D32),
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
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          title: 'Prayer Times',
                          subtitle: 'Daily Schedule',
                          icon: Icons.access_time_filled_rounded,
                          color: const Color(0xFF1565C0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrayerTimesScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Quick Access / About Section (Placeholder for clean look)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 24.r,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About Us',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Text(
                                'Helping you stay connected to your faith, wherever you are.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: color, size: 28.r),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
