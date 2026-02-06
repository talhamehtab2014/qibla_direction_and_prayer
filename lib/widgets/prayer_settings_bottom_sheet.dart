import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qibla_direction/providers/prayer_provider.dart';

class PrayerSettingsBottomSheet extends StatefulWidget {
  const PrayerSettingsBottomSheet({super.key});

  @override
  State<PrayerSettingsBottomSheet> createState() =>
      _PrayerSettingsBottomSheetState();
}

class _PrayerSettingsBottomSheetState extends State<PrayerSettingsBottomSheet> {
  late int _tempMethod;
  late int _tempSchool;
  int? _tempMidnightMode;
  int? _tempLatitudeAdj;

  final List<Map<String, dynamic>> _methods = [
    {'id': 0, 'name': 'Shia Ithna-Ashari, Leva Institute, Qum'},
    {'id': 1, 'name': 'University of Islamic Sciences, Karachi'},
    {'id': 2, 'name': 'Islamic Society of North America (ISNA)'},
    {'id': 3, 'name': 'Muslim World League'},
    {'id': 4, 'name': 'Umm Al-Qura University, Makkah'},
    {'id': 5, 'name': 'Egyptian General Authority of Survey'},
    {'id': 7, 'name': 'Institute of Geophysics, University of Tehran'},
    {'id': 8, 'name': 'Gulf Region'},
    {'id': 9, 'name': 'Kuwait'},
    {'id': 10, 'name': 'Qatar'},
    {'id': 11, 'name': 'Majlis Ugama Islam Singapura'},
    {'id': 12, 'name': 'Union Organization Islamic de France'},
    {'id': 13, 'name': 'Diyanet İşleri Başkanlığı, Turkey'},
    {'id': 14, 'name': 'Spiritual Administration of Muslims of Russia'},
    {'id': 15, 'name': 'Moonsighting Committee Worldwide'},
    {'id': 16, 'name': 'Dubai (Official)'},
    {'id': 17, 'name': 'Jabatan Kemajuan Islam Malaysia (JAKIM)'},
    {'id': 18, 'name': 'Tunisia'},
    {'id': 19, 'name': 'Algeria'},
    {'id': 20, 'name': 'KEMENAG - Indonesia'},
    {'id': 21, 'name': 'Morocco'},
    {'id': 22, 'name': 'Comunidade Islâmica de Lisboa'},
    {'id': 23, 'name': 'Ministry of Awqaf, UAE'},
  ];

  final List<Map<String, dynamic>> _schools = [
    {'id': 0, 'name': 'Shafi, Maliki, Hanbali'},
    {'id': 1, 'name': 'Hanafi'},
  ];

  final List<Map<String, dynamic>> _midnightModes = [
    {'id': null, 'name': 'Default'},
    {'id': 0, 'name': 'Standard (Mid-Night)'},
    {'id': 1, 'name': 'Jafari (Isha to Fajr)'},
  ];

  final List<Map<String, dynamic>> _latitudeAdjs = [
    {'id': null, 'name': 'None'},
    {'id': 1, 'name': 'Middle of the Night'},
    {'id': 2, 'name': 'One Seventh'},
    {'id': 3, 'name': 'Angle Based'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<PrayerProvider>();
    _tempMethod = provider.selectedMethod;
    _tempSchool = provider.selectedSchool;
    _tempMidnightMode = provider.midnightMode;
    _tempLatitudeAdj = provider.latitudeAdjustmentMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Prayer Settings',
              style: GoogleFonts.outfit(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Customize calculation parameters for Aladhan API.',
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Calculation Method',
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _methods.any((m) => m['id'] == _tempMethod)
                      ? _tempMethod
                      : 4,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).primaryColor,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() => _tempMethod = newValue);
                    }
                  },
                  items: _methods.map((method) {
                    return DropdownMenuItem<int>(
                      value: method['id'],
                      child: Text(
                        method['name'],
                        style: GoogleFonts.outfit(fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Midnight Mode',
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _tempMidnightMode,
                            isExpanded: true,
                            onChanged: (val) =>
                                setState(() => _tempMidnightMode = val),
                            items: _midnightModes
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m['id'] as int?,
                                    child: Text(
                                      m['name'],
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
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
                        'Lat Adjustment',
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _tempLatitudeAdj,
                            isExpanded: true,
                            onChanged: (val) =>
                                setState(() => _tempLatitudeAdj = val),
                            items: _latitudeAdjs
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m['id'] as int?,
                                    child: Text(
                                      m['name'],
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Asr Calculation (School)',
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: _schools.map((school) {
                final isSelected = _tempSchool == school['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tempSchool = school['id']),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          school['name'],
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<PrayerProvider>().updateSettings(
                    _tempMethod,
                    _tempSchool,
                    midnightMode: _tempMidnightMode,
                    latitudeAdj: _tempLatitudeAdj,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
