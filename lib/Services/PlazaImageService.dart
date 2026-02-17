/// Servicio para generar URLs de imágenes únicas y variadas para cada plaza de garaje
class PlazaImageService {
  /// Lista de proveedores de imágenes especializados en garajes y plazas de aparcamiento
  static const List<String> _imageProviders = [
    'loremflickr_parking',      // Imágenes de parkings y plazas
    'loremflickr_garage',       // Imágenes de garajes
    'loremflickr_parking_lot',  // Imágenes de lotes de estacionamiento
  ];

  /// Genera una URL de imagen única basada en el ID de plaza
  /// Asegura que todas las imágenes sean de plazas de garaje y estacionamiento
  static String getImageUrl(int plazaId, {int width = 400, int height = 300}) {
    // Usar diferente proveedor según el ID para variedad
    final providerIndex = plazaId % _imageProviders.length;
    
    switch (providerIndex) {
      case 0:
        // loremflickr con keyword "parking" - plazas de estacionamiento
        return 'https://loremflickr.com/$width/$height/parking,garage?lock=${plazaId * 12345}';
      
      case 1:
        // loremflickr con keyword "garage" - garajes
        return 'https://loremflickr.com/$width/$height/garage,parking?lock=${plazaId * 23456}';
      
      case 2:
        // loremflickr con keyword "parking lot" - lotes de estacionamiento
        return 'https://loremflickr.com/$width/$height/parking,lot,space?lock=${plazaId * 34567}';
      
      default:
        // Fallback a parking
        return 'https://loremflickr.com/$width/$height/parking,garage?lock=${plazaId * 12345}';
    }
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

  /// Lista de imágenes alternativas como fallback
  static const List<String> fallbackAssets = [
    'assets/garaje1.jpeg',
    'assets/garaje2.jpeg',
    'assets/garaje3.jpeg',
    'assets/garaje4.jpeg',
    'assets/garaje5.jpeg',
  ];

  /// Obtiene una imagen de fallback diferente según el ID
  static String getFallbackAsset(int plazaId) {
    return fallbackAssets[plazaId % fallbackAssets.length];
  }
}
