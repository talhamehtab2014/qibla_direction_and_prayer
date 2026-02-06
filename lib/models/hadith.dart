class Hadith {
  final String text;
  final String? narrator;
  final String? source;
  final bool isActive;

  Hadith({
    required this.text,
    this.narrator,
    this.source,
    this.isActive = true,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      text: json['hadith_english'] ?? json['text'] ?? 'No text available',
      narrator: json['narrator'] ?? json['header'],
      source: json['book_name'] ?? json['source'],
      isActive: json['isActive'] ?? false,
    );
  }

  factory Hadith.fromFirestore(Map<String, dynamic> json) {
    return Hadith(
      text: json['text'] ?? 'No text available',
      narrator: json['narrator'],
      source: json['source'],
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'narrator': narrator,
      'source': source,
      'isActive': isActive,
    };
  }
}
