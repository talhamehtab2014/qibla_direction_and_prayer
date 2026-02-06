import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:qibla_direction/models/hadith.dart';

class HadithService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A curated list of authentic hadiths as a fallback
  final List<Hadith> _fallbackHadiths = [
    Hadith(
      text:
          "The best among you are those who have the best manners and character.",
      source: "Sahih Bukhari",
      narrator: "Abdullah ibn Amr",
    ),
    Hadith(
      text:
          "None of you will have faith until he wishes for his brother what he likes for himself.",
      source: "Sahih Bukhari",
      narrator: "Anas bin Malik",
    ),
    Hadith(
      text:
          "Allah does not look at your appearance or your wealth, but He looks at your hearts and your deeds.",
      source: "Sahih Muslim",
      narrator: "Abu Hurairah",
    ),
    Hadith(
      text:
          "The most beloved of deeds to Allah are those that are most consistent, even if they are small.",
      source: "Sahih Bukhari",
      narrator: "Aisha (RA)",
    ),
    Hadith(
      text:
          "He who believes in Allah and the Last Day should either speak good or keep silent.",
      source: "Sahih Bukhari",
      narrator: "Abu Hurairah",
    ),
    Hadith(
      text: "Cleanliness is half of faith.",
      source: "Sahih Muslim",
      narrator: "Abu Malik al-Ashari",
    ),
    Hadith(
      text:
          "The strong is not the one who overcomes the people by his strength, but the strong is the one who controls himself while in anger.",
      source: "Sahih Bukhari",
      narrator: "Abu Hurairah",
    ),
  ];

  Future<Hadith> fetchRandomHadith() async {
    try {
      // Fetch all hadiths from Firestore (assuming a relatively small collection for "Daily Hadith")
      // For very large collections, we would use a different randomizing strategy.
      final QuerySnapshot snapshot = await _firestore
          .collection('islamic_hadiths')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final random = Random();
        final doc = snapshot.docs.where((e) => e['isActive'] == true).toList();
        final docsList = doc[random.nextInt(doc.length)];
        return Hadith.fromFirestore(docsList.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error fetching Hadith from Firestore: $e');
    }

    // Fallback if Firestore fails or is empty
    final random = Random();
    return _fallbackHadiths[random.nextInt(_fallbackHadiths.length)];
  }
}
