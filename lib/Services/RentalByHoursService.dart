import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
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
      debugPrint('💾 [RENTAL_SERVICE] Guardando alquiler: $data');
      
      final docRef = await _firestore.collection('alquileres').add(data);
      debugPrint('✅ [RENTAL_SERVICE] Alquiler creado con ID: ${docRef.id}');
      debugPrint('📍 [RENTAL_SERVICE] PlazaId: $plazaId, Tipo: 2, Estado: ${alquiler.estado}');
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
      // 🔴 VALIDACIÓN INICIAL: rentalId no puede ser null o inválido
      if (rentalId.isEmpty || rentalId == 'NULL') {
        throw Exception('❌ Error crítico: rentalId inválido: "$rentalId". El documento se creó sin capturar su ID.');
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('🔑 [RENTAL_SERVICE] releaseRental: Intentando liberar alquiler $rentalId');
      
      final rental = await _firestore.collection('alquileres').doc(rentalId).get();
      if (!rental.exists) {
        throw Exception('❌ DOCUMENTO NO ENCONTRADO: rentalId="$rentalId"\n'
          'Esto significa que el documento se guardó pero sin el ID correcto en el modelo.\n'
          'Causa probable: AlquilerPorHoras.fromFirestore() NO capturó snapshot.id correctamente.');
      }

      final alquiler = AlquilerPorHoras.fromFirestore(rental);
      
      debugPrint('📋 [RENTAL_SERVICE] Alquiler encontrado: plaza=${alquiler.idPlaza}, arrendatario=${alquiler.idArrendatario}');
      
      // Verificar que el usuario es el propietario del alquiler
      if (alquiler.idArrendatario != user.uid) {
        throw Exception('No tienes permiso para liberar este alquiler');
      }

      // Calcular precio final basado en tiempo realmente usado
      final tiempoUsado = alquiler.calcularTiempoUsado();
      final precioFinal = alquiler.calcularPrecioFinal();

      debugPrint('💰 [RENTAL_SERVICE] Tiempo usado: $tiempoUsado min, Precio final: €$precioFinal');

      // Actualizar documento con estado liberado
      debugPrint('🔧 [RENTAL_SERVICE] Guardando estado como: ${EstadoAlquilerPorHoras.liberado.name}');
      await _firestore.collection('alquileres').doc(rentalId).update({
        'estado': EstadoAlquilerPorHoras.liberado.name, // Guardar SOLO el nombre: "liberado"
        'tiempoUsado': tiempoUsado,
        'precioCalculado': precioFinal,
        'fechaLiberacion': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ [RENTAL_SERVICE] Alquiler liberado exitosamente. ID: $rentalId, Plaza: ${alquiler.idPlaza}');
    } catch (e) {
      debugPrint('❌ [RENTAL_SERVICE] Error al liberar alquiler: $e');
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
      debugPrint('🔧 [RENTAL_SERVICE_ADMIN] Guardando estado como: ${EstadoAlquilerPorHoras.liberado.name}');
      await _firestore.collection('alquileres').doc(rentalId).update({
        'estado': EstadoAlquilerPorHoras.liberado.name, // Guardar SOLO el nombre: "liberado"
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
    debugPrint('🔍 [WATCH_RENTALS] Usuario: ${user?.uid ?? "NO AUTENTICADO"}');
    
    if (user == null) {
      debugPrint('❌ [WATCH_RENTALS] Usuario no autenticado');
      return Stream.value([]);
    }

    return _firestore
        .collection('alquileres')
        .where('idArrendatario', isEqualTo: user.uid)
        .where('tipo', isEqualTo: 2)
        .where('estado', isNotEqualTo: EstadoAlquilerPorHoras.liberado.name) // 🔴 FILTRO EN FIRESTORE: Excluir liberados
        .snapshots()
        .map((snapshot) {
          debugPrint('📊 [WATCH_RENTALS] Total documentos encontrados (NO liberados): ${snapshot.docs.length}');
          
          final rentals = snapshot.docs
              .map((doc) {
                try {
                  debugPrint('📝 [WATCH_RENTALS] Procesando doc: ${doc.id}');
                  final rental = AlquilerPorHoras.fromFirestore(doc);
                  debugPrint('   ✅ [WATCH_RENTALS] documentId="${rental.documentId}" (esperado: "${doc.id}")');
                  debugPrint('   🔄 [WATCH_RENTALS] Estado: ${rental.estado}');
                  
                  // 🔴 VALIDACIÓN CRÍTICA: Asegurar que documentId se capturó correctamente
                  if (rental.documentId == null || rental.documentId != doc.id) {
                    debugPrint('   ⚠️ [WATCH_RENTALS] ADVERTENCIA: documentId no coincide con doc.id');
                    debugPrint('      Capturado: "${rental.documentId}", Esperado: "${doc.id}"');
                  }
                  
                  // El filtro de Firestore ya excluyó los liberados, así que incluir todos
                  debugPrint('   ✅ Alquiler activo incluido');
                  return rental;
                } catch (e) {
                  debugPrint('❌ [WATCH_RENTALS] Error parse: $e');
                  return null;
                }
              })
              .whereType<AlquilerPorHoras>()
              .toList();
            
            debugPrint('📈 [WATCH_RENTALS] Total alquileres activos enviados: ${rentals.length}');
            return rentals;
          });
  }

  /// Obtiene la información de una plaza (dirección) basándose en el ID
  static Future<String?> getPlazaAddress(int plazaId) async {
    try {
      final doc = await _firestore.collection('garaje').doc(plazaId.toString()).get();
      if (doc.exists) {
        return doc.data()?['direccion'] as String?;
      }
      return null;
    } catch (e) {
      print('Error al obtener dirección de plaza: $e');
      return null;
    }
  }

  /// Crea una multa si el alquiler está vencido y pasó el margen
  /// Se llama cuando el usuario intenta liberar un alquiler vencido
  static Future<bool> createPenaltyIfExpired(String rentalId) async {
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
      
      // Verificar que es propietario
      if (alquiler.idArrendatario != user.uid) {
        throw Exception('No tienes permiso');
      }

      // Verificar si pasó el vencimiento + margen
      final ahora = DateTime.now();
      final fechaVencimiento = alquiler.fechaVencimiento;
      final margenMinutos = 5;
      final fechaMargenExcedido = fechaVencimiento.add(Duration(minutes: margenMinutos));

      if (ahora.isAfter(fechaMargenExcedido)) {
        print('⚠️ Alquiler vencido y pasó margen. Creando multa...');
        
        // Calcular penalty amount (€10 fijo)
        const penaltyAmount = 10.0;
        
        // Crear documento de multa
        await _firestore.collection('multas').add({
          'idPlaza': alquiler.idPlaza,
          'idArrendatario': user.uid,
          'idAlquilerPorHoras': rentalId,
          'monto': penaltyAmount,
          'razon': 'exceso_margen',
          'fechaCreacion': Timestamp.now(),
          'fechaPago': null,
          'estado': 'pendiente',
          'paymentIntentId': null,
        });

        print('✅ Multa creada por €$penaltyAmount');
        return true;
      }

      print('✅ Sin multa (dentro del margen)');
      return false;
    } catch (e) {
      print('❌ Error al crear multa: $e');
      rethrow;
    }
  }

  /// Verifica si el usuario tiene multas pendientes
  static Future<bool> userHasPendingPenalties() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final query = await _firestore
          .collection('multas')
          .where('idArrendatario', isEqualTo: user.uid)
          .where('estado', isEqualTo: 'pendiente')
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar multas: $e');
      return false;
    }
  }
}
