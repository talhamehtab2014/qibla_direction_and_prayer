import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:qibla_direction/models/ramadan_timing_model.dart';
import 'package:intl/intl.dart';

class RamadanTimingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'ramadan_calendar';

  /// Fetches today's Ramadan timing from Firestore
  /// If today's date is not found, returns the nearest future date
  Future<RamadanTiming?> getTodayTiming() async {
    try {
      // Get current date in the format "22 Feb 2026"
      final now = DateTime.now();
      final formatter = DateFormat('d MMM yyyy');
      final todayDate = formatter.format(now);

      debugPrint('Fetching Ramadan timing for date: $todayDate');

      // Query Firestore for today's date
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('Date', isEqualTo: todayDate)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final timing = RamadanTiming.fromFirestore(doc.data());
        debugPrint(
          'Found Ramadan timing for today: Day ${timing.day}, Sehri: ${timing.sehri}, Iftar: ${timing.iftar}',
        );
        return timing;
      }

      // If today's date not found, fetch nearest future date
      debugPrint(
        'No Ramadan timing found for today, fetching nearest future date',
      );

      // Get all documents (no orderBy since Date is a string)
      final allDocs = await _firestore.collection(collectionName).get();

      if (allDocs.docs.isEmpty) {
        debugPrint('No Ramadan timings found in collection');
        return null;
      }

      // Parse dates and find nearest future date
      RamadanTiming? nearestTiming;
      DateTime? nearestDate;

      for (var doc in allDocs.docs) {
        final timing = RamadanTiming.fromFirestore(doc.data());
        try {
          final timingDate = DateFormat('d MMM yyyy').parse(timing.date);

          // Check if this date is today or in the future
          if (timingDate.isAfter(now.subtract(const Duration(days: 1)))) {
            if (nearestDate == null || timingDate.isBefore(nearestDate)) {
              nearestDate = timingDate;
              nearestTiming = timing;
            }
          }
        } catch (e) {
          debugPrint('Error parsing date ${timing.date}: $e');
        }
      }

      if (nearestTiming != null) {
        debugPrint(
          'Found nearest Ramadan timing: Day ${nearestTiming.day}, Date: ${nearestTiming.date}, Sehri: ${nearestTiming.sehri}, Iftar: ${nearestTiming.iftar}',
        );
        return nearestTiming;
      }

      debugPrint('No future Ramadan timings found');
      return null;
    } catch (e) {
      debugPrint('Error fetching Ramadan timing: $e');
      rethrow;
    }
  }

  /// Fetches Ramadan timing by day number
  Future<RamadanTiming?> getTimingByDay(int dayNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('Day', isEqualTo: dayNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No Ramadan timing found for day $dayNumber');
        return null;
      }

      final doc = querySnapshot.docs.first;
      return RamadanTiming.fromFirestore(doc.data());
    } catch (e) {
      debugPrint('Error fetching Ramadan timing by day: $e');
      rethrow;
    }
  }

  /// Fetches all Ramadan timings from Firestore sorted by date
  Future<List<RamadanTiming>> getAllTimings() async {
    try {
      final querySnapshot = await _firestore.collection(collectionName).get();

      List<RamadanTiming> timings = querySnapshot.docs
          .map((doc) => RamadanTiming.fromFirestore(doc.data()))
          .toList();

      // Sort timings by date in memory
      timings.sort((a, b) {
        try {
          final dateA = DateFormat('d MMM yyyy').parse(a.date);
          final dateB = DateFormat('d MMM yyyy').parse(b.date);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      return timings;
    } catch (e) {
      debugPrint('Error fetching all Ramadan timings: $e');
      rethrow;
    }
  }
}
