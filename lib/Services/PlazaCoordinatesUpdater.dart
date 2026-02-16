import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Utilidad para actualizar las coordenadas de las plazas de aparcamiento en Zaragoza
/// 
/// USO:
/// ```
/// await PlazaCoordinatesUpdater.updateAllPlazas();
/// ```
class PlazaCoordinatesUpdater {
  static const Map<String, Map<String, double>> plazasCoordinadas = {
    // Zona Centro (Casco Histórico)
    'Pilar': {'latitud': 41.6551, 'longitud': -0.8896},
    'Coso': {'latitud': 41.6525, 'longitud': -0.8901},
    'Alfonso': {'latitud': 41.6508, 'longitud': -0.8885},
    'España': {'latitud': 41.6445, 'longitud': -0.8945},
    'Puente': {'latitud': 41.6579, 'longitud': -0.8852},
    
    // Zona Conde Aranda
    'Conde Aranda': {'latitud': 41.6488, 'longitud': -0.8891},
    'Mayor': {'latitud': 41.6495, 'longitud': -0.8910},
    'Espada': {'latitud': 41.6510, 'longitud': -0.8860},
    
    // Zona Actur / Campus
    'Campus': {'latitud': 41.6810, 'longitud': -0.6890},
    'Actur': {'latitud': 41.6795, 'longitud': -0.7120},
    
    // Zona Almozara
    'Almozara': {'latitud': 41.6720, 'longitud': -0.8420},
    'Gutiérrez': {'latitud': 41.6745, 'longitud': -0.8390},
    
    // Zona Delicias
    'Estación': {'latitud': 41.6433, 'longitud': -0.8810},
    'Delicias': {'latitud': 41.6420, 'longitud': -0.8750},
    
    // Park & Ride
    'Valdespartera': {'latitud': 41.5890, 'longitud': -0.8920},
    'Chimenea': {'latitud': 41.7020, 'longitud': -0.8650},
    
    // Expo
    'Expo': {'latitud': 41.6340, 'longitud': -0.8420},
    
    // San José
    'San José': {'latitud': 41.6380, 'longitud': -0.9050},
    
    // Nuevas direcciones detectadas en Firestore
    'Plaza 1 direccion Moises': {'latitud': 41.6450, 'longitud': -0.8920},
    'direccion3': {'latitud': 41.6600, 'longitud': -0.8850},
    'Plaza2': {'latitud': 41.6550, 'longitud': -0.8900},
    'Direccion Sergio': {'latitud': 41.6480, 'longitud': -0.8870},
    'direccion7': {'latitud': 41.6520, 'longitud': -0.8930},
    'direccion': {'latitud': 41.6470, 'longitud': -0.8880},
    'nueva': {'latitud': 41.6490, 'longitud': -0.8910},
    'Calle Ibon de Catieras': {'latitud': 41.6320, 'longitud': -0.9040},
  };

  /// Actualiza todas las coordenadas de las plazas en Firestore
  static Future<Map<String, int>> updateAllPlazas({
    required Function(String)? onProgress,
  }) async {
    try {
      final db = FirebaseFirestore.instance;
      final garajeRef = db.collection('garaje');
      final snapshot = await garajeRef.get();

      int updated = 0;
      int notFound = 0;
      int errors = 0;

      for (final doc in snapshot.docs) {
        try {
          final garaje = doc.data();
          final direccion = (garaje['direccion'] as String?) ?? '';

          // Buscar coincidencia con coordenadas
          final coordenadas = _findCoordinates(direccion);

          if (coordenadas != null) {
            await garajeRef.doc(doc.id).update({
              'latitud': coordenadas['latitud'],
              'longitud': coordenadas['longitud'],
            });

            updated++;
            onProgress?.call('✅ $direccion: ${coordenadas['latitud']}, ${coordenadas['longitud']}');
          } else {
            notFound++;
            onProgress?.call('⚠️ No encontrada: $direccion');
          }
        } catch (e) {
          errors++;
          onProgress?.call('❌ Error en documento: $e');
        }
      }

      onProgress?.call(
          '\n📊 Resumen:\n✅ Actualizadas: $updated\n⚠️ No encontradas: $notFound\n❌ Errores: $errors');

      return {
        'updated': updated,
        'notFound': notFound,
        'errors': errors,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      onProgress?.call('❌ Error general: $e');
      rethrow;
    }
  }

  /// Busca coordenadas basado en la dirección
  static Map<String, double>? _findCoordinates(String direccion) {
    final direccionLower = direccion.toLowerCase();

    for (final entrada in plazasCoordinadas.entries) {
      if (direccionLower.contains(entrada.key.toLowerCase()) ||
          entrada.key.toLowerCase().contains(direccionLower)) {
        return {
          'latitud': entrada.value['latitud']!,
          'longitud': entrada.value['longitud']!,
        };
      }
    }

    return null;
  }

  /// Obtiene estadísticas de coordenadas inválidas
  static Future<List<Map<String, dynamic>>> getInvalidCoordinates() async {
    try {
      final db = FirebaseFirestore.instance;
      final snapshot = await db.collection('garaje').get();

      final invalid = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final latitud = data['latitud'] as double?;
        final longitud = data['longitud'] as double?;
        final direccion = data['direccion'] as String?;

        // Considerar inválidas si son 0.0, null, o fuera del rango de Zaragoza
        if (latitud == null ||
            longitud == null ||
            latitud == 0.0 ||
            longitud == 0.0 ||
            latitud < 41.0 ||
            latitud > 42.0 ||
            longitud < -1.5 ||
            longitud > -0.5) {
          invalid.add({
            'id': doc.id,
            'direccion': direccion,
            'latitud': latitud,
            'longitud': longitud,
          });
        }
      }

      return invalid;
    } catch (e) {
      debugPrint('Error obteniendo coordenadas inválidas: $e');
      return [];
    }
  }
}
