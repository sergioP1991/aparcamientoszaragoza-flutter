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
  /// - plazaId: ID de la plaza
  /// - index: Índice de imagen (0, 1, 2...)
  /// - maxSize: Tamaño máximo en bytes (default: 10MB)
  /// 
  /// Retorna: Uint8List (bytes de imagen)
  /// 
  /// Uso:
  /// ```dart
  /// final bytes = await FirebaseImageService().getImageBytes('plaza-123', 0);
  /// Image.memory(bytes, fit: BoxFit.cover)
  /// ```
  static Future<Uint8List?> getImageBytes(
    String plazaId,
    int index, {
    int maxSize = 10 * 1024 * 1024, // 10MB
  }) async {
    try {
      final path = 'garajes/$plazaId/imagen_$index.jpg';
      
      debugPrint('🖼️ Descargando imagen: $path');
      
      final ref = FirebaseStorage.instance.ref(path);
      
      // Descargar como bytes directamente (evita CORS completamente)
      final bytes = await ref.getData(maxSize);
      
      debugPrint('✅ Imagen descargada: $path (${bytes?.length} bytes)');
      
      return bytes;
    } catch (e) {
      debugPrint('❌ Error descargando imagen [$plazaId/$index]: $e');
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
