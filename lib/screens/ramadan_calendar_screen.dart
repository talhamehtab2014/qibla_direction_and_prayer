import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/prayer_provider.dart';
import 'package:qibla_direction/providers/ramadan_provider.dart';
import 'package:intl/intl.dart';

class RamadanCalendarScreen extends StatelessWidget {
  const RamadanCalendarScreen({super.key});

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
      body: Consumer<RamadanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ramadanDays.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: provider.ramadanDays.length,
            itemBuilder: (context, index) {
              final day = provider.ramadanDays[index];
              final adj = context.read<PrayerProvider>().hijriAdjustment;
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
                    ? Colors.white
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
