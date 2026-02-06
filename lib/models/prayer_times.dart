class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final HijriDate hijriDate;
  final GregorianDate gregorianDate;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.hijriDate,
    required this.gregorianDate,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final date = json['data']['date'];

    return PrayerTimes(
      fajr: timings['Fajr'],
      sunrise: timings['Sunrise'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      sunset: timings['Sunset'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
      imsak: timings['Imsak'],
      midnight: timings['Midnight'],
      hijriDate: HijriDate.fromJson(date['hijri']),
      gregorianDate: GregorianDate.fromJson(date['gregorian']),
    );
  }

  Map<String, String> get asMap => {
    'Fajr': fajr,
    'Sunrise': sunrise,
    'Dhuhr': dhuhr,
    'Asr': asr,
    'Maghrib': maghrib,
    'Isha': isha,
  };
}

class HijriDate {
  final String date;
  final String day;
  final String monthEn;
  final String monthAr;
  final String year;

  HijriDate({
    required this.date,
    required this.day,
    required this.monthEn,
    required this.monthAr,
    required this.year,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'],
      day: json['day'],
      monthEn: json['month']['en'],
      monthAr: json['month']['ar'],
      year: json['year'],
    );
  }

  @override
  String toString() => '$day $monthEn $year';
}

class GregorianDate {
  final String date;
  final String day;
  final String monthEn;
  final String year;

  GregorianDate({
    required this.date,
    required this.day,
    required this.monthEn,
    required this.year,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'],
      day: json['day'],
      monthEn: json['month']['en'],
      year: json['year'],
    );
  }

  @override
  String toString() => '$day $monthEn $year';
}
