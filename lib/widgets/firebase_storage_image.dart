import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/Services/FirebaseImageService.dart';

/// Widget para mostrar imágenes de Firebase Storage SIN problemas de CORS
/// 
/// Descarga imágenes como bytes en lugar de usar Image.network()
/// Esto evita CORS completamente.
/// 
/// Uso:
/// ```dart
/// FirebaseStorageImage(
///   plazaId: '123',
///   index: 0,
///   height: 200,
///   width: 200,
/// )
/// ```
class FirebaseStorageImage extends StatefulWidget {
  final String plazaId;
  final int index;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final bool showWarningOnError;

  const FirebaseStorageImage({
    Key? key,
    required this.plazaId,
    required this.index,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.loadingWidget,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.showWarningOnError = false,
  }) : super(key: key);

  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage>
    with SingleTickerProviderStateMixin {
  late Future<void> _loadImage;
  late AnimationController _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeAnimation = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _loadImage = _loadImageData();
  }

  Future<void> _loadImageData() async {
    try {
      final bytes = await FirebaseImageService.getImageBytes(
        widget.plazaId,
        widget.index,
      );
      
      if (bytes != null && mounted) {
        // Precachear proxima imagen mientras se muestra esta
        _precacheNext();
        _fadeAnimation.forward();
      }
    } catch (e) {
      debugPrint('Error cargando imagen: $e');
      rethrow;
    }
  }

  void _precacheNext() {
    FirebaseImageService.precacheImage(
      widget.plazaId,
      widget.index + 1,
    );
  }

  @override
  void didUpdateWidget(FirebaseStorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plazaId != widget.plazaId ||
        oldWidget.index != widget.index) {
      _fadeAnimation.reset();
      _loadImage = _loadImageData();
    }
  }

  @override
  void dispose() {
    _fadeAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadImage,
      builder: (context, snapshot) {
        // Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        // Error
        if (snapshot.hasError) {
          return _buildError();
        }

        // Éxito - Mostrar imagen
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildImage();
        }

        return _buildLoading();
      },
    );
  }

  Widget _buildLoading() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildError() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    final child = Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );

    // Con warning icon si está habilitado
    if (widget.showWarningOnError) {
      return Stack(
        children: [
          child,
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }

  Widget _buildImage() {
    return FutureBuilder<void>(
      future: _loadImage,
      builder: (context, snapshot) {
        // Mientras carga, mostrar placeholder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        // Si error, mostrar error widget
        if (snapshot.hasError) {
          return _buildError();
        }

        // Mostrar imagen descargada
        return FutureBuilder<Uint8List?>(
          future: FirebaseImageService.getImageBytes(
            widget.plazaId,
            widget.index,
          ),
          builder: (context, imageSnapshot) {
            if (imageSnapshot.hasData && imageSnapshot.data != null) {
              final image = Image.memory(
                imageSnapshot.data!,
                fit: widget.fit,
                height: widget.height,
                width: widget.width,
              );

              final widget = ClipRRect(
                borderRadius: this.widget.borderRadius ?? BorderRadius.zero,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: image,
                ),
              );

              return widget;
            }

            return _buildError();
          },
        );
      },
    );
  }
}
