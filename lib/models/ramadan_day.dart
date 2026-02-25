import 'package:qibla_direction/models/prayer_times.dart';

class RamadanDay {
  final HijriDate hijri;
  final GregorianDate gregorian;
  final String readableDate;
  final String sehri;
  final String iftar;

  RamadanDay({
    required this.hijri,
    required this.gregorian,
    required this.readableDate,
    required this.sehri,
    required this.iftar,
  });

  factory RamadanDay.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    final timings = json['timings'];

    return RamadanDay(
      hijri: HijriDate.fromJson(date['hijri']),
      gregorian: GregorianDate.fromJson(date['gregorian']),
      readableDate: date['readable'] ?? '',
      sehri: _cleanTime(timings['Fajr'] ?? ''),
      iftar: _cleanTime(timings['Maghrib'] ?? ''),
    );
  }

  static String _cleanTime(String time) {
    return time.split(' ')[0];
  }

  String get day => hijri.day;
  String get date => readableDate;
}
