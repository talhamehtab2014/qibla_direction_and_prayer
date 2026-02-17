import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/adhkar_provider.dart';
import 'package:qibla_direction/models/adhkar.dart';

class AdhkarDetailsScreen extends StatelessWidget {
  const AdhkarDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Daily Adhkar',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: Colors.white70,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            tabs: const [
              Tab(text: 'Morning'),
              Tab(text: 'Evening'),
            ],
          ),
        ),
        body: Consumer<AdhkarProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildAdhkarList(context, provider.morningAdhkar),
                _buildAdhkarList(context, provider.eveningAdhkar),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdhkarList(BuildContext context, List<Adhkar> adhkarList) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: adhkarList.length,
      itemBuilder: (context, index) {
        final adhkar = adhkarList[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  adhkar.arabic,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  adhkar.translation,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      adhkar.reference,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Optional: Add a counter if needed
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
