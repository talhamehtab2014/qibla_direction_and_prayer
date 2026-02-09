import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
          'Ramadan Calendar 1447',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
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

          final now = DateTime.now();
          final todayStr = DateFormat('dd-MM-yyyy').format(now);

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: provider.ramadanDays.length,
            itemBuilder: (context, index) {
              final day = provider.ramadanDays[index];
              final isToday = day.gregorian.date == todayStr;

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
                    ? theme.primaryColor.withOpacity(0.1)
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
                              day.hijri.day,
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
                              '${day.gregorian.day} ${day.gregorian.monthEn} ${day.gregorian.year}',
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '${day.hijri.day} ${day.hijri.monthEn} ${day.hijri.year}',
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'TODAY',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
