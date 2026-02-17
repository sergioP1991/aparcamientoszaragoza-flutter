/// Servicio para generar URLs de imágenes únicas y variadas para cada plaza
class PlazaImageService {
  /// Lista de proveedores de imágenes con diferentes estilos
  static const List<String> _imageProviders = [
    'picsum.photos',      // Fotos random
    'unsplash.com',       // Fotos de calidad
    'loremflickr.com',    // Imágenes tematizadas
  ];

  /// Genera una URL de imagen única basada en el ID de plaza
  /// Asegura variedad usando diferentes proveedores
  static String getImageUrl(int plazaId, {int width = 400, int height = 300}) {
    // Usar diferente proveedor según el ID para variedad
    final providerIndex = plazaId % _imageProviders.length;
    
    switch (providerIndex) {
      case 0:
        // picsum.photos - amplia variedad, siempre diferente
        return 'https://picsum.photos/seed/garage_$plazaId/$width/$height?random=${plazaId * 12345}';
      
      case 1:
        // loremflickr - imágenes tematizadas por palabra clave
        final keywords = ['parking', 'garage', 'car', 'vehicle', 'street', 'city'];
        final keyword = keywords[plazaId % keywords.length];
        return 'https://loremflickr.com/$width/$height/$keyword?random=${plazaId * 12345}';
      
      case 2:
        // Alternativa: usar diferentes seeds de picsum
        return 'https://picsum.photos/seed/park_${plazaId}_space/$width/$height?random=${plazaId * 67890}';
      
      default:
        // Fallback a picsum por defecto
        return 'https://picsum.photos/seed/garage_$plazaId/$width/$height';
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
