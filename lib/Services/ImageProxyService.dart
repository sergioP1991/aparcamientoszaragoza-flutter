import 'package:flutter/foundation.dart';

/// Servicio para evitar problemas de CORS con Firebase Storage
/// Usa una Cloud Function proxy para servir imágenes en web
class ImageProxyService {
  // URL base de la Cloud Function (reemplazar con tu región y proyecto)
  static const String _cloudFunctionUrl = 'https://us-central1-aparcamientodisponible.cloudfunctions.net/serveImage';

  /// Convierte una URL de Firebase Storage en una URL proxy sin CORS
  /// En web: usa Cloud Function proxy
  /// En mobile: retorna la URL original de Firebase Storage
  static String getProxyUrl(String originalUrl) {
    if (!kIsWeb) {
      // Mobile: retorna la URL original de Firebase Storage (sin problemas CORS)
      return originalUrl;
    }

    // Web: intenta extraer plazaId e índice de imagen de la URL
    // URL original: https://firebasestorage.../garajes%2F1234%2Fimagen_0.jpg?...
    try {
      // Extraer plazaId e índice del path
      final uri = Uri.parse(originalUrl);
      final path = uri.path;
      
      // Path típico: /v0/b/bucket/o/garajes%2F1234%2Fimagen_0.jpg
      if (path.contains('garajes%2F')) {
        final parts = path.split('garajes%2F')[1];
        final match = RegExp(r'^(\d+)%2Fimagen_(\d+)').firstMatch(parts);
        
        if (match != null) {
          final plazaId = match.group(1);
          final index = match.group(2);
          
          // Retornar URL proxy
          return '$_cloudFunctionUrl?plazaId=$plazaId&index=$index';
        }
      }
    } catch (e) {
      debugPrint('❌ Error parseando URL para proxy: $e');
    }

    // Fallback: retornar URL original si no se puede parsear
    return originalUrl;
  }

  /// Obtiene la URL proxy para una imagen específica
  /// En web: genera URL proxy directa
  /// En mobile: genera URL Firebase Storage directa
  static String getImageUrl({
    required int plazaId,
    required int index,
  }) {
    if (!kIsWeb) {
      // Mobile: generar URL directa de Firebase Storage
      // token se genera con Firebase Security Rules
      return 'https://firebasestorage.googleapis.com/v0/b/aparcamientodisponible.appspot.com/o/garajes%2F$plazaId%2Fimagen_$index.jpg?alt=media';
    }

    // Web: usar Cloud Function proxy
    return '$_cloudFunctionUrl?plazaId=$plazaId&index=$index';
  }
}
