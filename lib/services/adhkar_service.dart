import 'package:qibla_direction/models/adhkar.dart';

class AdhkarService {
  List<Adhkar> getMorningAdhkar() {
    return [
      Adhkar(
        category: 'Morning',
        text:
            'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        translation:
            'We have entered a new day and with it all dominion is Allah\'s. All praise is to Allah. None has the right to be worshipped but Allah alone, Who has no partner.',
        reference: 'Muslim 4/2088',
      ),
      Adhkar(
        category: 'Morning',
        text:
            'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
        translation:
            'O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and to You is the Final Return.',
        reference: 'Tirmidhi 5/466',
      ),
    ];
  }

  List<Adhkar> getEveningAdhkar() {
    return [
      Adhkar(
        category: 'Evening',
        text:
            'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        translation:
            'We have entered the evening and with it all dominion is Allah\'s. All praise is to Allah. None has the right to be worshipped but Allah alone, Who has no partner.',
        reference: 'Muslim 4/2088',
      ),
      Adhkar(
        category: 'Evening',
        text:
            'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
        translation:
            'O Allah, by You we enter the evening and by You we enter the morning, by You we live and by You we die, and to You is the Final Return.',
        reference: 'Tirmidhi 5/466',
      ),
    ];
  }

  List<Adhkar> getAllDailyAdhkar() {
    return [...getMorningAdhkar(), ...getEveningAdhkar()];
  }
}
