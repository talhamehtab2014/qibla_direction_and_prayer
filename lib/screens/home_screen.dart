import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/qibla_provider.dart';
import 'package:qibla_direction/providers/theme_provider.dart';
import 'package:qibla_direction/providers/hadith_provider.dart';
import 'package:qibla_direction/screens/qibla_compass_screen.dart';
import 'package:qibla_direction/screens/prayer_times_screen.dart';
import 'package:qibla_direction/widgets/banner_ad_widget.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:qibla_direction/widgets/hadith_swipe_card.dart';
import 'package:qibla_direction/screens/ramadan_calendar_screen.dart';
import 'package:qibla_direction/screens/adhkar_details_screen.dart';
import 'package:qibla_direction/providers/remote_config_provider.dart';
import 'package:qibla_direction/providers/ramadan_timing_provider.dart';

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
      body: Stack(
        children: [
          Container(
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
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

                      // Swipeable Hadith Cards
                      Consumer<HadithProvider>(
                        builder: (context, hadithProvider, child) {
                          if (hadithProvider.isLoading) {
                            return _buildShimmerLoading();
                          }
                          final hadiths = hadithProvider.hadiths;
                          if (hadiths.isEmpty) return const SizedBox.shrink();

                          final cardColors = [
                            const Color(0xFF2E7D32), // Forest Green
                            const Color(0xFF1B5E20), // Deep Islamic Green
                            const Color(0xFF388E3C), // Medium Green
                            const Color(0xFF43A047), // Darker Sage
                            const Color(0xFF004D40), // Dark Teal-Green
                            const Color(0xFF00695C), // Pine Green
                          ];

                          return SizedBox(
                            height: 220.h,
                            child: CardSwiper(
                              cardsCount: hadiths.length,
                              numberOfCardsDisplayed: hadiths.length > 1
                                  ? 2
                                  : 1,
                              backCardOffset: const Offset(0, 23),
                              padding: EdgeInsets.zero,
                              cardBuilder:
                                  (
                                    context,
                                    index,
                                    horizontalThresholdPercentage,
                                    verticalThresholdPercentage,
                                  ) {
                                    return HadithSwipeCard(
                                      hadith: hadiths[index],
                                      color:
                                          cardColors[index % cardColors.length],
                                    );
                                  },
                            ),
                          );
                        },
                      ),
                      26.verticalSpace,

                      // Ramadan Sehri & Iftar Times Card
                      Consumer<RemoteConfigProvider>(
                        builder: (context, remoteConfig, child) {
                          if (!remoteConfig.showRamadanCalendar) {
                            return const SizedBox.shrink();
                          }

                          return Consumer<RamadanTimingProvider>(
                            builder: (context, ramadanTimingProvider, child) {
                              if (ramadanTimingProvider.isLoading) {
                                return Container(
                                  height: 100.h,
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.05),
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final timing =
                                  ramadanTimingProvider.currentTiming;
                              if (timing != null) {
                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(14.r),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF2E7D32),
                                        const Color(0xFF1B5E20),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2E7D32,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Header
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                color: Colors.white,
                                                size: 16.r,
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                'Ramadan Day ${timing.day}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            timing.date,
                                            style: GoogleFonts.outfit(
                                              fontSize: 11.sp,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      // Times Row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(12.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.nightlight_round,
                                                    color: Colors.white,
                                                    size: 22.r,
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    'Sehri',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 11.sp,
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    timing.sehri,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(12.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.wb_twilight,
                                                    color: Colors.white,
                                                    size: 22.r,
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    'Iftar',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 11.sp,
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    timing.iftar,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                      26.verticalSpace,
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

                      Consumer<RemoteConfigProvider>(
                        builder: (context, remoteConfig, child) {
                          return Row(
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
                                        builder: (context) =>
                                            ChangeNotifierProvider(
                                              create: (_) => QiblaProvider(),
                                              child: const QiblaCompassScreen(),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (remoteConfig.showPrayersTime) ...[
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
                                          builder: (context) =>
                                              const PrayerTimesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 16.h),

                      Consumer<RemoteConfigProvider>(
                        builder: (context, remoteConfig, child) {
                          final hasRamadan = remoteConfig.showRamadanCalendar;
                          final hasAdhkar = remoteConfig.showDailyAdhkar;

                          if (!hasRamadan && !hasAdhkar) {
                            return const SizedBox.shrink();
                          }

                          return Row(
                            children: [
                              if (hasRamadan) ...[
                                Expanded(
                                  child: _buildFeatureCard(
                                    context,
                                    title: 'Ramadan Calendar',
                                    subtitle: 'Hijri 1447 Schedule',
                                    icon: Icons.calendar_month_rounded,
                                    color: const Color(0xFFE65100),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RamadanCalendarScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (hasAdhkar) SizedBox(width: 16.w),
                              ],
                              if (hasAdhkar)
                                Expanded(
                                  child: _buildFeatureCard(
                                    context,
                                    title: 'Daily Adhkar',
                                    subtitle: 'Morning & Evening',
                                    icon: Icons.auto_stories_rounded,
                                    color: const Color(0xFF7B1FA2),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdhkarDetailsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
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
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Consumer<RemoteConfigProvider>(
              builder: (context, remoteConfig, child) {
                if (remoteConfig.isShowAds) {
                  return const BannerAdWidget();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
        height: 160.h,
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
