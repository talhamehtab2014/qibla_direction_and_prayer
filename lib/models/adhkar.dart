class Adhkar {
  final String category;
  final String text;
  final String translation;
  final String reference;
  final int count;

  Adhkar({
    required this.category,
    required this.text,
    required this.translation,
    required this.reference,
    this.count = 1,
  });
}
