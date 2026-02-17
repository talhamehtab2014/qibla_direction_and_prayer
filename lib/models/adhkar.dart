class Adhkar {
  final String category;
  final String arabic;
  final String translation;
  final String reference;
  final int count;

  Adhkar({
    required this.category,
    required this.arabic,
    required this.translation,
    this.reference = '',
    this.count = 1,
  });

  factory Adhkar.fromFirestore(Map<String, dynamic> data) {
    return Adhkar(
      category: data['category'] ?? '',
      arabic: data['arabic'] ?? '',
      translation: data['translation'] ?? '',
      reference: data['reference'] ?? '',
      count: data['count'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'arabic': arabic,
      'translation': translation,
      'reference': reference,
      'count': count,
    };
  }
}
