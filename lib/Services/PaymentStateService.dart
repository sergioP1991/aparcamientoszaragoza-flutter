import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio unificado para manejar pagos y actualizar estado
/// Centraliza toda la lógica relacionada con pagos y cambios de estado
class PaymentStateService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Actualiza el estado después de un pago exitoso
  /// - Para alquileres por horas: crea el alquiler
  /// - Para multas/penalizaciones: marca como pagada
  /// - Actualiza la plaza: la marca como ocupada si aplica
  static Future<bool> updateStateAfterPayment({
    required Garaje plaza,
    required int rentalDays,
    required double totalAmount,
    required String paymentIntentId,
    AlquilerType? rentalType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      final plazaId = plaza.idPlaza ?? 0;
      final batch = _firestore.batch();

      if (rentalType == AlquilerType.porHoras) {
        // Crear alquiler por horas
        final now = DateTime.now();
        final fechaVencimiento = now.add(Duration(days: rentalDays));
        
        final alquiler = AlquilerPorHoras(
          fechaInicio: now,
          fechaVencimiento: fechaVencimiento,
          duracionContratada: rentalDays * 24 * 60, // convertir a minutos
          precioMinuto: totalAmount / (rentalDays * 24 * 60),
          idPlaza: plazaId,
          idArrendatario: user.uid,
          estado: EstadoAlquilerPorHoras.activo,
        );

        // Guardar alquiler en Firestore
        final alquilerRef = _firestore.collection('alquileres').doc();
        batch.set(alquilerRef, {
          ...alquiler.objectToMap(),
          'paymentIntentId': paymentIntentId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Actualizar plaza: asignar el alquiler
        batch.update(_firestore.collection('garaje').doc(plazaId.toString()), {
          'alquiler': alquiler.objectToMap(),
          'disponible': false,
        });
      } else if (rentalType == AlquilerType.normal) {
        // Para alquileres mensuales (si aplica)
        // TODO: Implementar según estructura de AlquilerNormal
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error actualizando estado después del pago: $e');
      return false;
    }
  }

  /// Marca una penalización como pagada
  static Future<bool> markPenaltyAsPaid({
    required String rentalId,
    required double paidAmount,
    required String paymentIntentId,
  }) async {
    try {
      await _firestore.collection('alquileres').doc(rentalId).update({
        'estado': EstadoAlquilerPorHoras.liberado.toString(),
        'precioCalculado': paidAmount,
        'paymentIntentId': paymentIntentId,
        'fechaLiberacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error marcando penalización como pagada: $e');
      return false;
    }
  }

  /// Actualiza el estado de la plaza después de liberar un alquiler
  static Future<bool> markPlazaAsAvailable({
    required int plazaId,
  }) async {
    try {
      await _firestore.collection('garaje').doc(plazaId.toString()).update({
        'alquiler': null,
        'disponible': true,
      });
      return true;
    } catch (e) {
      print('Error actualizando disponibilidad de plaza: $e');
      return false;
    }
  }

  /// Obtiene el estado actualizado de una plaza desde Firestore
  static Future<Garaje?> getUpdatedPlaza(int plazaId) async {
    try {
      final doc = await _firestore.collection('garaje').doc(plazaId.toString()).get();
      if (doc.exists) {
        return Garaje.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo plaza actualizada: $e');
      return null;
    }
  }
}

enum AlquilerType {
  porHoras,  // Alquiler por horas
  normal,    // Alquiler mensual
  especial,  // Alquiler especial (días específicos)
}
