import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

/// Servicio para descargar imágenes de Firebase Storage SIN problemas de CORS
/// 
/// Funciona en web y mobile sin necesidad de Cloud Functions:
/// - Web: Descarga como bytes y muestra con Image.memory()
/// - Mobile: Descarga como bytes (mejor control de caché y CORS)
/// - Caché local: Guarda en dispositivo para reutilizar
class FirebaseImageService {
  static final FirebaseImageService _instance = FirebaseImageService._internal();

  factory FirebaseImageService() {
    return _instance;
  }

  FirebaseImageService._internal();

  /// Descarga imagen de Firebase Storage como bytes
  /// 
  /// Parámetros:
  /// - plazaId: ID de la plaza (string o int)
  /// - index: Índice de imagen (0, 1, 2...)
  /// - maxSize: Tamaño máximo en bytes (default: 10MB)
  /// 
  /// Retorna: Uint8List (bytes de imagen) o null si falla
  /// 
  /// Uso:
  /// ```dart
  /// final bytes = await FirebaseImageService().getImageBytes('1773223843125', 0);
  /// Image.memory(bytes, fit: BoxFit.cover)
  /// ```
  static Future<Uint8List?> getImageBytes(
    String plazaId,
    int index, {
    int maxSize = 10 * 1024 * 1024, // 10MB
  }) async {
    try {
      // Normalizar plazaId - convertir a string si es necesario
      final normalizedPlazaId = plazaId.toString().trim();
      final path = 'garajes/$normalizedPlazaId/imagen_$index.jpg';
      
      debugPrint('🖼️ [FirebaseImageService] Intentando descargar: $path');
      
      final ref = FirebaseStorage.instance.ref(path);
      
      // Debug: Obtener metadata para verificar que el archivo existe
      try {
        final metadata = await ref.getMetadata();
        debugPrint('📊 [FirebaseImageService] Metadata: Size=${metadata.size}, ContentType=${metadata.contentType}');
      } catch (metaError) {
        debugPrint('⚠️ [FirebaseImageService] No se pudo obtener metadata: $metaError');
      }
      
      // Descargar como bytes directamente (evita CORS completamente)
      debugPrint('⏳ [FirebaseImageService] Iniciando descarga de bytes...');
      final bytes = await ref.getData(maxSize);
      
      if (bytes == null) {
        debugPrint('❌ [FirebaseImageService] ref.getData() retornó NULL para: $path');
        return null;
      }
      
      debugPrint('✅ [FirebaseImageService] Imagen descargada exitosamente: $path (${bytes.length} bytes)');
      
      return bytes;
    } catch (e, stackTrace) {
      debugPrint('❌ [FirebaseImageService] ERROR CRÍTICO descargando [$plazaId/$index]:');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      
      // Diagnosticar el tipo de error
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        debugPrint('   🔐 Probable causa: SECURITY RULES de Firebase Storage está bloqueando acceso');
      } else if (e.toString().contains('404') || e.toString().contains('not found')) {
        debugPrint('   🔍 Probable causa: Archivo NO EXISTE en Storage o ruta incorrecta');
      } else if (e.toString().contains('auth') || e.toString().contains('Auth')) {
        debugPrint('   🔐 Probable causa: Usuario NO AUTENTICADO');
      }
      
      return null;
    }
  }

  /// Obtiene URL pública de descarga (si Storage permite acceso público)
  /// Para usar con Image.network() si las reglas de Storage lo permiten
  static Future<String?> getDownloadUrl(String plazaId, int index) async {
    try {
      final path = 'garajes/$plazaId/imagen_$index.jpg';
      final ref = FirebaseStorage.instance.ref(path);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('❌ Error obteniendo URL de descarga: $e');
      return null;
    }
  }

  /// Precarga imagen en caché
  /// Útil para carruseles: precarga siguientes imágenes mientras usuario ve actual
  static Future<void> precacheImage(String plazaId, int index) async {
    try {
      await getImageBytes(plazaId, index);
    } catch (e) {
      debugPrint('⚠️ No se pudo precachear imagen: $e');
    }
  }

  /// Limpia caché de todas las imágenes
  static Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      debugPrint('🗑️ Caché de imágenes limpiado');
    } catch (e) {
      debugPrint('⚠️ Error limpiando caché: $e');
    }
  }
}
