class Hadith {
  final String text;
  final String? narrator;
  final String? source;

  Hadith({required this.text, this.narrator, this.source});

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      text: json['hadith_english'] ?? json['text'] ?? 'No text available',
      narrator: json['narrator'] ?? json['header'],
      source: json['book_name'] ?? json['source'],
    );
  }
}
