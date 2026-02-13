class RamadanTiming {
  final String date;
  final int day;
  final String iftar;
  final String sehri;
  final String uploadedAt;

  RamadanTiming({
    required this.date,
    required this.day,
    required this.iftar,
    required this.sehri,
    required this.uploadedAt,
  });

  factory RamadanTiming.fromFirestore(Map<String, dynamic> data) {
    return RamadanTiming(
      date: data['Date'] ?? '',
      day: data['Day'] ?? 0,
      iftar: data['Iftar'] ?? '',
      sehri: data['Sehri'] ?? '',
      uploadedAt: data['uploadedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Day': day,
      'Iftar': iftar,
      'Sehri': sehri,
      'uploadedAt': uploadedAt,
    };
  }
}
