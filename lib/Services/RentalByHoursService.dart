import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';

class RentalByHoursService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crea un nuevo alquiler por horas
  static Future<String?> createRental({
    required int plazaId,
    required int durationMinutes,
    required double pricePerMinute,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final fechaInicio = DateTime.now();
      final fechaVencimiento = fechaInicio.add(Duration(minutes: durationMinutes));

      final alquiler = AlquilerPorHoras(
        idPlaza: plazaId,
        idArrendatario: user.uid,
        fechaInicio: fechaInicio,
        fechaVencimiento: fechaVencimiento,
        duracionContratada: durationMinutes,
        precioMinuto: pricePerMinute,
        estado: EstadoAlquilerPorHoras.activo,
      );

      final docRef = await _firestore.collection('alquileres').add(alquiler.objectToMap());
      return docRef.id;
    } catch (e) {
      print('Error al crear alquiler por horas: $e');
      rethrow;
    }
  }

  /// Obtiene el alquiler activo de una plaza
  static Future<AlquilerPorHoras?> getActiveRentalForPlaza(int plazaId) async {
    try {
      final snapshot = await _firestore
          .collection('alquileres')
          .where('idPlaza', isEqualTo: plazaId)
          .where('tipo', isEqualTo: 2) // tipo 2 es alquiler por horas
          .where('estado', isNotEqualTo: 'EstadoAlquilerPorHoras.liberado')
          .get();

      if (snapshot.docs.isEmpty) return null;
      return AlquilerPorHoras.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error al obtener alquiler activo: $e');
      return null;
    }
  }

  /// Obtiene el alquiler activo del usuario actual
  static Future<List<AlquilerPorHoras>> getActiveRentalsForUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('alquileres')
          .where('idArrendatario', isEqualTo: user.uid)
          .where('tipo', isEqualTo: 2) // tipo 2 es alquiler por horas
          .where('estado', isNotEqualTo: 'EstadoAlquilerPorHoras.liberado')
          .get();

      return snapshot.docs.map((doc) => AlquilerPorHoras.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error al obtener alquileres del usuario: $e');
      return [];
    }
  }

  /// Libera una plaza (solo el propietario del alquiler puede hacerlo)
  /// Calcula el precio final según tiempo usado y actualiza estado
  static Future<void> releaseRental(String rentalId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final rental = await _firestore.collection('alquileres').doc(rentalId).get();
      if (!rental.exists) {
        throw Exception('Alquiler no encontrado');
      }

      final alquiler = AlquilerPorHoras.fromFirestore(rental);
      
      // Verificar que el usuario es el propietario del alquiler
      if (alquiler.idArrendatario != user.uid) {
        throw Exception('No tienes permiso para liberar este alquiler');
      }

      // Calcular precio final basado en tiempo realmente usado
      final tiempoUsado = alquiler.calcularTiempoUsado();
      final precioFinal = alquiler.calcularPrecioFinal();

      // Actualizar documento con estado liberado
      await _firestore.collection('alquileres').doc(rentalId).update({
        'estado': EstadoAlquilerPorHoras.liberado.toString(),
        'tiempoUsado': tiempoUsado,
        'precioCalculado': precioFinal,
        'fechaLiberacion': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al liberar alquiler: $e');
      rethrow;
    }
  }

  /// Verifica si el usuario actual es el propietario de un alquiler
  static Future<bool> isRentalOwner(String rentalId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final rental = await _firestore.collection('alquileres').doc(rentalId).get();
      if (!rental.exists) return false;

      final alquiler = AlquilerPorHoras.fromFirestore(rental);
      return alquiler.idArrendatario == user.uid;
    } catch (e) {
      print('Error al verificar propiedad: $e');
      return false;
    }
  }

  /// Obtiene el ID del usuario actual
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Stream para monitorear un alquiler específico en tiempo real
  static Stream<AlquilerPorHoras?> watchRental(String rentalId) {
    return _firestore
        .collection('alquileres')
        .doc(rentalId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return AlquilerPorHoras.fromFirestore(snapshot);
          }
          return null;
        });
  }

  /// Stream para monitorear el alquiler activo de una plaza en tiempo real
  /// Útil para mostrar a todos los usuarios el estado del alquiler de una plaza
  static Stream<AlquilerPorHoras?> watchPlazaRental(int plazaId) {
    return _firestore
        .collection('alquileres')
        .where('idPlaza', isEqualTo: plazaId)
        .where('tipo', isEqualTo: 2)
        .where('estado', isNotEqualTo: EstadoAlquilerPorHoras.liberado.toString())
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return AlquilerPorHoras.fromFirestore(snapshot.docs.first);
        });
  }

  /// Stream para monitorear alquileres activos del usuario
  static Stream<List<AlquilerPorHoras>> watchUserActiveRentals() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('alquileres')
        .where('idArrendatario', isEqualTo: user.uid)
        .where('tipo', isEqualTo: 2)
        .where('estado', isNotEqualTo: 'EstadoAlquilerPorHoras.liberado')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => AlquilerPorHoras.fromFirestore(doc)).toList();
        });
  }
}
