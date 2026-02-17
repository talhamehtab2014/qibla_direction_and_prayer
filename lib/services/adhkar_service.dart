import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qibla_direction/models/adhkar.dart';

class AdhkarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Adhkar>> getAdhkarByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('daily_adhkar')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => Adhkar.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching adhkar: $e');
      return [];
    }
  }

  Future<List<Adhkar>> getMorningAdhkar() async {
    return getAdhkarByCategory('morning');
  }

  Future<List<Adhkar>> getEveningAdhkar() async {
    return getAdhkarByCategory('evening');
  }

  Future<List<Adhkar>> getAllDailyAdhkar() async {
    try {
      final querySnapshot = await _firestore.collection('daily_adhkar').get();
      return querySnapshot.docs
          .map((doc) => Adhkar.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching all adhkar: $e');
      return [];
    }
  }
}
