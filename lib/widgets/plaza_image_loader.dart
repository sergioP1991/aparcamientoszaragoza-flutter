import 'package:flutter/material.dart';

/// Widget para cargar imágenes de plazas con manejo robusto de errores
/// Muestra imagen fallback + icono de warning si hay error de descarga
class PlazaImageLoader extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final bool showWarningOnError;

  const PlazaImageLoader({
    Key? key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    this.showWarningOnError = true,
  }) : super(key: key);

  @override
  State<PlazaImageLoader> createState() => _PlazaImageLoaderState();
}

class _PlazaImageLoaderState extends State<PlazaImageLoader> {
  bool _hasError = false;
  late ImageProvider _imageProvider;

  @override
  void initState() {
    super.initState();
    _imageProvider = NetworkImage(widget.imageUrl);
    _imageProvider.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener(
        (image, synchronousCall) {},
        onError: (dynamic exception, StackTrace? stackTrace) {
          setState(() => _hasError = true);
          debugPrint('❌ Error descargando imagen: ${widget.imageUrl}');
          debugPrint('📋 Error details: $exception');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen principal
        Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.grey[800],
          ),
          child: _hasError
              ? _buildDefaultImage()
              : Image(
                  image: _imageProvider,
                  fit: widget.fit,
                  height: widget.height,
                  width: widget.width,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback si falla la descarga
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _hasError = true);
                    });
                    return _buildDefaultImage();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
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

  /// Construye la imagen de fallback por defecto
  Widget _buildDefaultImage() {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        image: const DecorationImage(
          image: AssetImage('assets/garaje1.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Overlay semi-transparente para oscurecer la imagen de fondo
        color: Colors.black.withOpacity(0.15),
      ),
    );
  }
}

