import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/history.dart';

class ActivityService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'activity';

  static Future<void> recordEvent(History event) async {
    try {
      await _db.collection(_collection).add(event.toFirestore());
      print('Evento registrado con éxito: ${event.tipo}');
    } catch (e) {
      print('Error al registrar evento: $e');
    }
  }

  static Stream<List<History>> getUserActivity(String userId, {String? userEmail}) {
    // Create a list of IDs to check (both UID and Email)
    final List<String> ids = [userId];
    if (userEmail != null && userEmail != userId) {
      ids.add(userEmail);
    }

    return _db
        .collection(_collection)
        .where('userId', whereIn: ids)
        // .orderBy('fecha', descending: true) // Removing to avoid index requirement
        .snapshots()
        .map((snapshot) {
          final historyList = snapshot.docs
            .map((doc) => History.fromFirestore(doc.data()))
            .toList();
          
          // Sort in memory: descending by fecha
          historyList.sort((a, b) => b.fecha.compareTo(a.fecha));
          
          return historyList;
        });
  }
}
