import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_direction/models/hadith.dart';

class HadithSwipeCard extends StatelessWidget {
  final Hadith hadith;
  final Color? color;

  const HadithSwipeCard({super.key, required this.hadith, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.primaryColor;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            Color.fromARGB(
              255,
              (primaryColor.red * 0.8).round(),
              (primaryColor.green * 0.8).round(),
              (primaryColor.blue * 0.8).round(),
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: Colors.white, size: 24.r),
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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                hadith.text,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16.sp,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
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
  }
}
