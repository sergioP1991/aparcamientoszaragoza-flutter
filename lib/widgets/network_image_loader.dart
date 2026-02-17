import 'package:flutter/material.dart';

/// Widget que carga imágenes de red con mejor manejo de errores
class NetworkImageLoader extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final String? fallbackAsset;

  const NetworkImageLoader({
    Key? key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/garaje2.jpeg',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si es un asset local
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
      );
    }

    // Si la URL está vacía, mostrar fallback
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    // Si no es una URL válida, mostrar fallback
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      return _buildFallback();
    }

    // Cargar desde red
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error cargando imagen: $imageUrl');
        return _buildFallback();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallback() {
    if (fallbackAsset == null || fallbackAsset!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: const Icon(Icons.image_not_supported, color: Colors.white30),
      );
    }

    return Image.asset(
      fallbackAsset!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[800],
          child: const Icon(Icons.image_not_supported, color: Colors.white30),
        );
      },
    );
  }
}

