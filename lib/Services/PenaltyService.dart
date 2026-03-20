import 'package:aparcamientoszaragoza/Models/multa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class PenaltyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crear una multa por exceso de tiempo
  /// Este método es llamado cuando el alquiler pasa el margen de 5 minutos
  /// VALIDACIÓN: Solo permite 1 multa no-pagada por plaza
  static Future<Multa?> createPenalty({
    required int idPlaza,
    required String idArrendatario,
    required String? idAlquilerPorHoras,
    required double monto,
    required String razon,
  }) async {
    try {
      debugPrint('💰 [PENALTY] Creando multa por: $razon, monto: €$monto');

      // ✅ FIX 2: Validar que no exista otra multa no-pagada para esta plaza
      final existingQuery = await _firestore
          .collection('multas')
          .where('idPlaza', isEqualTo: idPlaza)
          .where('idArrendatario', isEqualTo: idArrendatario)
          .where('estado', isNotEqualTo: EstadoMulta.pagada.name)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        debugPrint('⚠️ [PENALTY] Ya existe multa para plaza $idPlaza (arrendatario: $idArrendatario). No crear duplicado.');
        return null;
      }

      final multa = Multa(
        idPlaza: idPlaza,
        idArrendatario: idArrendatario,
        idAlquilerPorHoras: idAlquilerPorHoras,
        monto: monto,
        razon: razon,
        fechaCreacion: DateTime.now(),
        estado: EstadoMulta.pendiente,
      );

      final docRef = await _firestore
          .collection('multas')
          .add(multa.toMap());

      debugPrint('✅ [PENALTY] Multa creada con ID: ${docRef.id}');

      // Retornar la multa con el ID asignado
      return Multa(
        id: docRef.id,
        idPlaza: multa.idPlaza,
        idArrendatario: multa.idArrendatario,
        idAlquilerPorHoras: multa.idAlquilerPorHoras,
        monto: multa.monto,
        razon: multa.razon,
        fechaCreacion: multa.fechaCreacion,
        estado: multa.estado,
      );
    } catch (e) {
      debugPrint('❌ [PENALTY] Error creando multa: $e');
      return null;
    }
  }

  /// Obtener todas las multas pendientes del usuario actual
  /// ✅ FIX ARQUITECTÓNICO: Ordenar en cliente en lugar de en Firestore
  static Future<List<Multa>> getPendingPenaltiesForCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      debugPrint('🔍 [PENALTY] Obteniendo multas pendientes para usuario: ${currentUser.uid}');

      final snapshot = await _firestore
          .collection('multas')
          .where('idArrendatario', isEqualTo: currentUser.uid)
          .where('estado', isEqualTo: EstadoMulta.pendiente.name)
          // ✅ REMOVIDO orderBy para evitar requerimiento de índice compuesto
          .get();

      final penalties = snapshot.docs
          .map((doc) => Multa.fromFirestore(doc))
          .toList();
      
      // ✅ Ordenar en cliente
      penalties.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      
      debugPrint('✅ [PENALTY] Obtenidas ${penalties.length} multas pendientes ordenadas por fecha');
      return penalties;
    } catch (e) {
      debugPrint('❌ [PENALTY] Error obteniendo multas: $e');
      return [];
    }
  }

  /// Obtener todas las multas PENDIENTES del usuario (excluye pagadas y condonadas)
  /// ✅ FIX ARQUITECTÓNICO: Sin orderBy para evitar requerimiento de índice compuesto
  /// El ordenamiento se hace en el cliente (Dart) en lugar de en Firestore
  static Stream<List<Multa>> watchUserPenalties() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('⚠️ [PENALTY] No hay usuario autenticado');
      return Stream.value([]);
    }

    debugPrint('🔍 [PENALTY STREAM] Iniciando stream de multas pendientes para usuario: ${currentUser.uid}');

    return _firestore
        .collection('multas')
        .where('idArrendatario', isEqualTo: currentUser.uid)
        .where('estado', isEqualTo: EstadoMulta.pendiente.name)
        // ✅ REMOVIDO orderBy para evitar requerimiento de índice Firestore
        // El ordenamiento se hace en el cliente
        .snapshots()
        .map((snapshot) {
      debugPrint('📦 [PENALTY STREAM] Firestore devolvió ${snapshot.docs.length} multas pendientes');
      
      final penalties = snapshot.docs
          .map((doc) => Multa.fromFirestore(doc))
          .toList();
      
      // ✅ Ordenar en cliente (más robusto que en Firestore)
      penalties.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      
      debugPrint('✅ [PENALTY STREAM] Emitiendo ${penalties.length} multas ordenadas por fecha');
      return penalties;
    });
  }

  /// Marcar una multa como pagada
  static Future<bool> markPenaltyAsPaid({
    required String penaltyId,
    required String paymentIntentId,
  }) async {
    try {
      debugPrint('💳 [PENALTY] Marcando multa como pagada: $penaltyId');

      await _firestore
          .collection('multas')
          .doc(penaltyId)
          .update({
        'estado': EstadoMulta.pagada.name,
        'fechaPago': Timestamp.now(),
        'paymentIntentId': paymentIntentId,
      });

      debugPrint('✅ [PENALTY] Multa $penaltyId marcada como pagada');
      return true;
    } catch (e) {
      debugPrint('❌ [PENALTY] Error marcando multa como pagada: $e');
      return false;
    }
  }

  /// Perdonar una multa (solo para admin)
  static Future<bool> forgivePenalty({required String penaltyId}) async {
    try {
      debugPrint('🎁 [PENALTY] Condonando multa: $penaltyId');

      await _firestore
          .collection('multas')
          .doc(penaltyId)
          .update({
        'estado': EstadoMulta.condonada.name,
      });

      debugPrint('✅ [PENALTY] Multa $penaltyId condonada');
      return true;
    } catch (e) {
      debugPrint('❌ [PENALTY] Error condonando multa: $e');
      return false;
    }
  }

  /// Obtener el monto total de multas pendientes
  static Future<double> getTotalPendingPenalties() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0.0;

      final snapshot = await _firestore
          .collection('multas')
          .where('idArrendatario', isEqualTo: currentUser.uid)
          .where('estado', isEqualTo: EstadoMulta.pendiente.name)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final monto = doc['monto'] as num?;
        if (monto != null) {
          total += monto.toDouble();
        }
      }

      debugPrint('💰 [PENALTY] Total multas pendientes: €$total');
      return total;
    } catch (e) {
      debugPrint('❌ [PENALTY] Error calculando total: $e');
      return 0.0;
    }
  }

  /// Obtener las primeras N multas pendientes
  /// ✅ FIX ARQUITECTÓNICO: Ordenar en cliente en lugar de en Firestore
  static Future<List<Multa>> getTopPendingPenalties({int limit = 5}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      debugPrint('🔝 [PENALTY] Obteniendo top $limit multas pendientes');

      final snapshot = await _firestore
          .collection('multas')
          .where('idArrendatario', isEqualTo: currentUser.uid)
          .where('estado', isEqualTo: EstadoMulta.pendiente.name)
          // ✅ REMOVIDO orderBy para evitar requerimiento de índice compuesto
          .get();

      final penalties = snapshot.docs
          .map((doc) => Multa.fromFirestore(doc))
          .toList();
      
      // ✅ Ordenar en cliente
      penalties.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      
      // Limitar al número solicitado
      final top = penalties.take(limit).toList();
      
      debugPrint('✅ [PENALTY] Top $limit multas: ${top.length} de ${penalties.length} obtenidas');
      return top;
    } catch (e) {
      debugPrint('❌ [PENALTY] Error obteniendo multas top: $e');
      return [];
    }
  }

  /// Verificar si un usuario tiene multas pendientes
  static Future<bool> userHasPendingPenalties() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final snapshot = await _firestore
          .collection('multas')
          .where('idArrendatario', isEqualTo: currentUser.uid)
          .where('estado', isEqualTo: EstadoMulta.pendiente.name)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [PENALTY] Error verificando multas: $e');
      return false;
    }
  }

  /// Eliminar una multa (solo después de ser pagada, para limpieza)
  static Future<bool> deletePenalty({required String penaltyId}) async {
    try {
      debugPrint('🗑️ [PENALTY] Eliminando multa: $penaltyId');

      await _firestore
          .collection('multas')
          .doc(penaltyId)
          .delete();

      debugPrint('✅ [PENALTY] Multa $penaltyId eliminada');
      return true;
    } catch (e) {
      debugPrint('❌ [PENALTY] Error eliminando multa: $e');
      return false;
    }
  }
}
