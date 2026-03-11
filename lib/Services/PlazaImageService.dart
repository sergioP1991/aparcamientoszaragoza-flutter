import 'package:aparcamientoszaragoza/Models/garaje.dart';

/// Servicio para obtener URLs de imágenes de plazas desde Firebase Storage o fallback local
class PlazaImageService {
  /// Lista de imágenes locales de fallback
  static const List<String> _imageAssets = [
    'assets/garaje1.jpeg',
    'assets/garaje2.jpeg',
    'assets/garaje3.jpeg',
    'assets/garaje4.jpeg',
    'assets/garaje5.jpeg',
  ];

  /// Obtiene la primera imagen del Garaje (desde Firebase Storage) con fallback a assets
  static String getImageFromGaraje(Garaje garaje) {
    if (garaje.imagenes.isNotEmpty) {
      return garaje.imagenes.first;  // URL real de Firebase Storage
    }
    return _imageAssets[garaje.idPlaza ?? 0 % _imageAssets.length];
  }

  /// Obtiene todas las imágenes del Garaje para un carrusel
  static List<String> getCarouselUrlsFromGaraje(Garaje garaje) {
    if (garaje.imagenes.isNotEmpty) {
      return garaje.imagenes;  // URLs reales de Firebase Storage
    }
    // Fallback: usar assets locales
    return List.generate(5, (i) => _imageAssets[(garaje.idPlaza ?? 0 + i) % _imageAssets.length]);
  }

  /// Retorna una imagen local basada en el ID de plaza (sin intentar cargar remotas que pueden fallar)
  static String getImageUrl(int plazaId, {int width = 400, int height = 300}) {
    // Usar imagen local del asset
    return _imageAssets[plazaId % _imageAssets.length];
  }

  /// Genera múltiples URLs de imágenes para un carrusel (rotando entre los assets disponibles)
  static List<String> getCarouselUrls(int plazaId, {int width = 600, int height = 400, int count = 5}) {
    final List<String> urls = [];
    for (int i = 0; i < count; i++) {
      // Rotar entre las imágenes disponibles
      urls.add(_imageAssets[(plazaId + i) % _imageAssets.length]);
    }
    return urls;
  }

  /// Genera una URL pequeña (thumbnail) de imagen
  static String getThumbnailUrl(int plazaId) {
    return getImageUrl(plazaId, width: 120, height: 120);
  }

  /// Genera una URL mediana de imagen
  static String getMediumUrl(int plazaId) {
    return getImageUrl(plazaId, width: 300, height: 200);
  }

  /// Genera una URL grande de imagen
  static String getLargeUrl(int plazaId) {
    return getImageUrl(plazaId, width: 600, height: 400);
  }

  /// Obtiene una imagen de fallback diferente según el ID
  /// Retorna solo el nombre del archivo sin "assets/" (para usar con Image.asset())
  static String getFallbackAsset(int plazaId) {
    String fullPath = _imageAssets[plazaId % _imageAssets.length];
    // Remove "assets/" prefix since Image.asset() adds it automatically
    return fullPath.replaceFirst('assets/', '');
  }

  /// Obtiene la ruta completa del asset (con "assets/" prefix - para otros usos)
  static String getFallbackAssetPath(int plazaId) {
    return _imageAssets[plazaId % _imageAssets.length];
  }
}
