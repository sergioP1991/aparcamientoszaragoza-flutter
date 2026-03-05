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

      if (durationMinutes <= 0) {
        throw Exception('Duración debe ser mayor a 0');
      }

      final fechaInicio = DateTime.now();
      final fechaVencimiento = fechaInicio.add(Duration(minutes: durationMinutes));

      final alquiler = AlquilerPorHoras(
        idPlaza: plazaId,
        idArrendatario: user.uid,
        fechaInicio: fechaInicio,
        fechaVencimiento: fechaVencimiento,
        duracionContratada: durationMinutes,
        precioMinuto: pricePerMinute.clamp(0.0, double.infinity),
        estado: EstadoAlquilerPorHoras.activo,
      );

      final data = alquiler.objectToMap();
      print('💾 Guardando alquiler: $data');
      
      final docRef = await _firestore.collection('alquileres').add(data);
      print('✅ Alquiler creado con ID: ${docRef.id}');
      print('📍 PlazaId: $plazaId, Tipo: 2, Estado: ${alquiler.estado}');
      return docRef.id;
    } catch (e) {
      print('❌ Error al crear alquiler por horas: $e');
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
          .get();

      // Filtrar localmente los alquileres activos (no liberados ni vencidos)
      final activeDocs = snapshot.docs
          .where((doc) {
            final estado = doc['estado'] as String?;
            if (estado == null) return true; // Incluir si no hay estado definido
            return !estado.contains('liberado') && !estado.contains('vencido');
          })
          .toList();

      if (activeDocs.isEmpty) return null;
      return AlquilerPorHoras.fromFirestore(activeDocs.first);
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
          .get();

      // Filtrar localmente los alquileres activos (no liberados)
      final activeRentals = snapshot.docs
          .where((doc) {
            final estado = doc['estado'] as String?;
            if (estado == null) return true;
            return !estado.contains('liberado');
          })
          .map((doc) => AlquilerPorHoras.fromFirestore(doc))
          .toList();

      return activeRentals;
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

  /// 🔓 Admin Release: Libera un alquiler SIN verificar propiedad (solo para admin)
  /// No hay validación de usuario - se usa en herramientas administrativas
  static Future<void> releaseRentalAsAdmin(String rentalId) async {
    try {
      final rental = await _firestore.collection('alquileres').doc(rentalId).get();
      if (!rental.exists) {
        print('⚠️ Alquiler no encontrado: $rentalId');
        return; // No existe, saltamos
      }

      final alquiler = AlquilerPorHoras.fromFirestore(rental);
      
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
      
      print('✅ Alquiler liberado (admin): $rentalId');
    } catch (e) {
      print('❌ Error al liberar alquiler (admin): $e');
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
    print('🔍 watchPlazaRental iniciado para plaza: $plazaId');
    return _firestore
        .collection('alquileres')
        .where('idPlaza', isEqualTo: plazaId)
        .where('tipo', isEqualTo: 2)
        .snapshots()
        .map((snapshot) {
          print('📊 Snapshot para plaza $plazaId: ${snapshot.docs.length} documentos');
          
          if (snapshot.docs.isEmpty) {
            print('❌ No hay alquileres para plaza $plazaId');
            return null;
          }
          
          // Mostrar cada documento para debugging
          for (var doc in snapshot.docs) {
            print('📄 Doc: tipo=${doc['tipo']}, estado=${doc['estado']}, idPlaza=${doc['idPlaza']}');
          }
          
          // Filtrar documentos activos (no liberados)
          final activeDocs = snapshot.docs.where((doc) {
            final estado = doc['estado'] as String?;
            final isActive = estado != null && 
                   !estado.contains('liberado') &&
                   !estado.contains('vencido');
            print('🔎 Filtrando: estado=$estado, isActive=$isActive');
            return isActive;
          }).toList();
          
          if (activeDocs.isEmpty) {
            print('❌ No hay alquileres activos para plaza $plazaId');
            return null;
          }
          
          try {
            final rental = AlquilerPorHoras.fromFirestore(activeDocs.first);
            print('✅ Alquiler activo encontrado para plaza $plazaId: ${rental.toString()}');
            return rental;
          } catch (e) {
            print('❌ Error al parsear alquiler: $e');
            return null;
          }
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
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  final rental = AlquilerPorHoras.fromFirestore(doc);
                  // Solo incluir alquileres que no estén liberados
                  if (!rental.estado.toString().contains('liberado')) {
                    return rental;
                  }
                } catch (e) {
                  print('Error al parsear alquiler del usuario: $e');
                }
                return null;
              })
              .whereType<AlquilerPorHoras>()
              .toList();
        });
  }
}
