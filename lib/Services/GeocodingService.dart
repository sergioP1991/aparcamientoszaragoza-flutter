import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Servicio para convertir direcciones en coordenadas GPS (geocoding)
class GeocodingService {
  // Usando la API de geocoding pública de OpenStreetMap (Nominatim)
  // No requiere API key
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  /// Obtiene coordenadas (lat, long) a partir de una dirección completa
  /// Retorna un Map con 'latitud' y 'longitud', o null si hay error
  static Future<Map<String, double>?> geocodeAddress({
    required String direccion,
    required String municipio,
    required String provincia,
    required String codigoPostal,
  }) async {
    try {
      // Construir dirección completa
      final fullAddress = '$direccion, $codigoPostal $municipio, $provincia, España';
      debugPrint('🌍 Geocoding: $fullAddress');

      // Llamar a Nominatim API
      final response = await http.get(
        Uri.parse(_nominatimUrl).replace(
          queryParameters: {
            'q': fullAddress,
            'format': 'json',
            'limit': '1',
            'countrycodes': 'es',  // España
          },
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        
        if (results.isNotEmpty) {
          final data = results[0];
          final double lat = double.parse(data['lat'] ?? '0');
          final double lon = double.parse(data['lon'] ?? '0');
          
          debugPrint('✅ Geocoding exitoso: ($lat, $lon)');
          return {
            'latitud': lat,
            'longitud': lon,
          };
        } else {
          debugPrint('⚠️ No se encontró dirección en Nominatim');
          return null;
        }
      } else {
        debugPrint('❌ Error de API Nominatim: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error al geocodificar: $e');
      return null;
    }
  }

  /// Versión inversa: obtiene dirección a partir de coordenadas
  static Future<String?> reverseGeocode({
    required double latitud,
    required double longitud,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(
          queryParameters: {
            'format': 'json',
            'lat': latitud.toString(),
            'lon': longitud.toString(),
            'zoom': '18',
            'addressdetails': '1',
          },
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['display_name'] ?? '';
        debugPrint('✅ Reverse geocoding: $address');
        return address;
      } else {
        debugPrint('❌ Error reverse geocoding: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error en reverse geocoding: $e');
      return null;
    }
  }
}
