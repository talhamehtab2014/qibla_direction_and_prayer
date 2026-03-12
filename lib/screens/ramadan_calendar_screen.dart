import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/models/ramadan_day.dart';
import 'package:qibla_direction/providers/prayer_provider.dart';
import 'package:qibla_direction/providers/ramadan_provider.dart';
import 'package:intl/intl.dart';

class RamadanCalendarScreen extends StatefulWidget {
  const RamadanCalendarScreen({super.key});

  @override
  State<RamadanCalendarScreen> createState() => _RamadanCalendarScreenState();
}

class _RamadanCalendarScreenState extends State<RamadanCalendarScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday(List<RamadanDay> days, int adj) {
    if (_hasScrolled || days.isEmpty) return;

    final formatter = DateFormat('dd MMM yyyy');
    final now = DateTime.now();
    final todayStr = formatter.format(now);

    int todayIndex = -1;

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      DateTime? parsedDate;
      try {
        parsedDate = formatter.parse(day.date);
      } catch (_) {}
      final shiftedDate = parsedDate?.add(Duration(days: adj));
      final displayDate = shiftedDate != null ? formatter.format(shiftedDate) : day.date;

      if (displayDate == todayStr) {
        todayIndex = i;
        break;
      }
    }

    if (todayIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        // Dynamic item height estimation:
        // Card padding (16*2) + Margin (12) + Content (approx 50) = ~95.h
        final double itemHeight = 90.h; 
        final double scrollOffset = todayIndex * itemHeight;
        
        // Ensure we don't scroll past max extent
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double targetOffset = scrollOffset > maxScroll ? maxScroll : scrollOffset;

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        _hasScrolled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ramadan Calendar',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? theme.primaryColorDark : theme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer2<RamadanProvider, PrayerProvider>(
        builder: (context, ramadanProvider, prayerProvider, child) {
          if (ramadanProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ramadanProvider.ramadanDays.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          // Trigger scroll after build if data is ready
          if (!_hasScrolled) {
            _scrollToToday(ramadanProvider.ramadanDays, prayerProvider.hijriAdjustment);
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16.r),
            itemCount: ramadanProvider.ramadanDays.length,
            itemBuilder: (context, index) {
              final day = ramadanProvider.ramadanDays[index];
              final adj = prayerProvider.hijriAdjustment;
              final formatter = DateFormat('dd MMM yyyy');

              // Parse the Gregorian date from the API and shift it by adj days
              DateTime? parsedDate;
              try {
                parsedDate = formatter.parse(day.date);
              } catch (_) {}
              final shiftedDate = parsedDate?.add(Duration(days: adj));
              final displayDate = shiftedDate != null
                  ? formatter.format(shiftedDate)
                  : day.date;

              final now = DateTime.now();
              final todayStr = formatter.format(now);
              final isToday = displayDate == todayStr;

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                elevation: isToday ? 4 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: isToday
                        ? theme.primaryColor
                        : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black12),
                    width: isToday ? 2 : 1,
                  ),
                ),
                color: isToday
                    ? Colors.white.withOpacity(0.3)
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Container(
                        width: 50.w,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Day',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                            Text(
                              day.day,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayDate,
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.nightlight_round,
                                  size: 14.r,
                                  color: theme.primaryColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Sehri: ${day.sehri}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Icon(
                                  Icons.wb_twilight,
                                  size: 14.r,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Iftar: ${day.iftar}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isToday)
                        Container(
                          width: 10.h,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
