import 'package:flutter/material.dart';

/// Widget que carga imágenes de red con mejor manejo de errores
/// Muestra imagen fallback + icono de warning si hay error de descarga
class NetworkImageLoader extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final String? fallbackAsset;
  final bool showWarningOnError;

  const NetworkImageLoader({
    Key? key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/garaje2.jpeg',
    this.showWarningOnError = true,
  }) : super(key: key);

  @override
  State<NetworkImageLoader> createState() => _NetworkImageLoaderState();
}

class _NetworkImageLoaderState extends State<NetworkImageLoader> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // Si es un asset local
    if (widget.imageUrl.startsWith('assets/')) {
      return _buildAssetImage();
    }

    // Si la URL está vacía, mostrar fallback
    if (widget.imageUrl.isEmpty) {
      return _buildFallback();
    }

    // Si no es una URL válida, mostrar fallback
    if (!widget.imageUrl.startsWith('http://') && !widget.imageUrl.startsWith('https://')) {
      return _buildFallback();
    }

    // Cargar desde red
    return Stack(
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[800],
          child: _hasError
              ? _buildFallback()
              : Image.network(
                  widget.imageUrl,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                  errorBuilder: (context, error, stackTrace) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _hasError = true);
                    });
                    debugPrint('❌ Error cargando imagen: ${widget.imageUrl}');
                    debugPrint('📋 Error details: $error');
                    return _buildFallback();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  },
                ),
        ),
        // Icono de warning en la esquina superior derecha si hay error
        if (_hasError && widget.showWarningOnError)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  /// Carga una imagen desde assets locales  
  Widget _buildAssetImage() {
    return Image.asset(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback();
      },
    );
  }

  /// Construye la imagen de fallback por defecto
  Widget _buildFallback() {
    if (widget.fallbackAsset == null || widget.fallbackAsset!.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[800],
        child: const Icon(Icons.image_not_supported, color: Colors.white30),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        image: DecorationImage(
          image: AssetImage(widget.fallbackAsset!),
          fit: widget.fit,
        ),
      ),
      child: Container(
        // Overlay semi-transparente para oscurecer la imagen de fondo
        color: Colors.black.withOpacity(0.15),
      ),
    );
  }
}

