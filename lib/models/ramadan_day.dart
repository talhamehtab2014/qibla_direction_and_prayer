import 'package:qibla_direction/models/prayer_times.dart';

class RamadanDay {
  final HijriDate hijri;
  final GregorianDate gregorian;

  RamadanDay({required this.hijri, required this.gregorian});

  factory RamadanDay.fromJson(Map<String, dynamic> json) {
    return RamadanDay(
      hijri: HijriDate.fromJson(json['hijri']),
      gregorian: GregorianDate.fromJson(json['gregorian']),
    );
  }
}
