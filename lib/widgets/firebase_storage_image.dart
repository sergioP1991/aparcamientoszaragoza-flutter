import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/Services/FirebaseImageService.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';

/// Widget para mostrar imágenes de Firebase Storage SIN problemas de CORS
/// 
/// Descarga imágenes como bytes en lugar de usar Image.network()
/// Esto evita CORS completamente.
/// 
/// Si falla la descarga de Firebase (timeout, sin auth, archivo no existe, etc.),
/// automáticamente muestra la imagen de aparcamientos por defecto (como en la lista de plazas)
/// e incluye un icono de alerta rojo si está habilitado.
/// 
/// Uso:
/// ```dart
/// FirebaseStorageImage(
///   plazaId: '123',
///   index: 0,
///   height: 200,
///   width: 200,
///   showWarningOnError: true, // Muestra icono de alerta rojo en esquina
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
  late AnimationController _fadeAnimation;
  late Future<Uint8List?> _imageFuture;

  /// Intenta cargar de Firebase, si falla cae a PlazaImageService fallback
  Future<Uint8List?> _loadImageWithFallback() async {
    try {
      // Intenta cargar de Firebase
      final bytes = await FirebaseImageService.getImageBytes(
        widget.plazaId,
        widget.index,
      );
      
      if (bytes != null) {
        debugPrint('✅ [FirebaseStorageImage] Firebase cargó imagen exitosamente');
        return bytes;
      }
      
      // Si Firebase retorna null, retorna null para que el builder sepa usar fallback
      debugPrint('⚠️ [FirebaseStorageImage] Firebase retornó null, usando fallback visual');
      return null;
    } catch (e) {
      debugPrint('❌ [FirebaseStorageImage] Error con Firebase: $e, usando fallback visual');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeAnimation = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    // Crear el future UNA SOLA VEZ en initState
    debugPrint('===============================================');
    debugPrint('✅ [FirebaseStorageImage] Widget iniciado');
    debugPrint('   plazaId: ${widget.plazaId}');
    debugPrint('   index: ${widget.index}');
    debugPrint('   height: ${widget.height}, width: ${widget.width}');
    debugPrint('===============================================');
    
    // Usar nueva función con fallback
    _imageFuture = _loadImageWithFallback();
    
    // Precachear próxima
    Future.delayed(Duration.zero, () {
      FirebaseImageService.precacheImage(
        widget.plazaId,
        widget.index + 1,
      );
    });
  }

  @override
  void didUpdateWidget(FirebaseStorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el widget, reinicializar el future
    if (oldWidget.plazaId != widget.plazaId ||
        oldWidget.index != widget.index) {
      _fadeAnimation.reset();
      _imageFuture = _loadImageWithFallback();
    }
  }

  @override
  void dispose() {
    _fadeAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        // Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('⏳ FirebaseStorageImage: Esperando descarga');
          return _buildLoading();
        }

        // Completado pero sin datos (error)
        if (!snapshot.hasData || snapshot.data == null) {
          debugPrint('❌ FirebaseStorageImage: Sin datos o datos nulos. Error: ${snapshot.error}');
          return _buildError();
        }

        // Error explícito
        if (snapshot.hasError) {
          debugPrint('❌ FirebaseStorageImage: Error en FutureBuilder: ${snapshot.error}');
          return _buildError();
        }

        // ✅ ÉXITO - Mostrar imagen con bytes descargados
        debugPrint('✅ FirebaseStorageImage: Imagen descargada (${snapshot.data!.length} bytes). Mostrando...');
        
        final image = Image.memory(
          snapshot.data!,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Error renderizando Image.memory: $error');
            return _buildError();
          },
        );

        final displayWidget = ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: image,
          ),
        );

        // Trigger animación una sola vez cuando se alcanza este punto
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_fadeAnimation.status == AnimationStatus.dismissed) {
            debugPrint('🎬 Iniciando animación de fade-in');
            _fadeAnimation.forward();
          }
        });

        return displayWidget;
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

    // Obtener plazaId como int para acceder a la imagen de fallback
    int plazaId = int.tryParse(widget.plazaId) ?? 0;
    String fallbackAsset = PlazaImageService.getFallbackAsset(plazaId);

    // Cargar imagen de fallback (como en la lista de plazas)
    final child = ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Image.asset(
        fallbackAsset,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          // Si ni siquiera el fallback local funciona, mostrar icono gris
          return Container(
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
        },
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
}
