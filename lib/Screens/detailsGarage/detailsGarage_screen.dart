import 'dart:async';

import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Services/PlazaDescriptionService.dart';
import 'package:aparcamientoszaragoza/widgets/firebase_storage_image.dart';
import 'package:aparcamientoszaragoza/Screens/timeline/timeline_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/rent/rent_screen.dart' hide Text;
import 'package:aparcamientoszaragoza/Screens/rent_by_hours/rent_by_hours_screen.dart';
import 'package:aparcamientoszaragoza/Screens/active_rentals/active_rentals_screen.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/widgets/Buttons.dart';
import 'package:aparcamientoszaragoza/widgets/Spaces.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsGarajePage extends ConsumerStatefulWidget {
  static const routeName = '/details-garage';

  const DetailsGarajePage({super.key});

  @override
  ConsumerState<DetailsGarajePage> createState() => _DetailsGaragePageState();
}

class _DetailsGaragePageState extends ConsumerState<DetailsGarajePage> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  late Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Timer que actualiza el widget cada segundo para refrescar el tiempo restante
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int idPlaza = (ModalRoute.of(context)?.settings.arguments ?? 0) as int;
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));
    final plaza = homeDataState.value?.getGarageById(idPlaza);
    final user = homeDataState.value?.user;

    debugPrint('🔍 DetailScreen DEBUG - idPlaza: $idPlaza');
    if (plaza != null) {
      debugPrint('🔍 DetailScreen DEBUG - plaza.imagenes: ${plaza.imagenes.length} imágenes');
      for (int i = 0; i < plaza.imagenes.length; i++) {
        debugPrint('   [$i] ${plaza.imagenes[i]}');
      }
    } else {
      debugPrint('🔍 DetailScreen DEBUG - Plaza NO ENCONTRADA en home provider');
    }

    if (plaza == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isFavorite = plaza.isFavorite(user?.email);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(context, ref, plaza, user, isFavorite),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderInfo(plaza, l10n),
                      const SizedBox(height: 20),
                      _buildTags(plaza, l10n),
                      if (plaza.propietario == user?.uid) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, color: Colors.black, size: 20),
                              SizedBox(width: 8),
                              Text(
                                l10n.ownerBanner,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 25),
                      _buildAvailabilityBanner(plaza, idPlaza, user, l10n),
                      const SizedBox(height: 25),
                      _buildDescription(plaza, l10n),
                      const SizedBox(height: 25),
                      _buildActionButtons(context, l10n),
                      const SizedBox(height: 25),
                      _buildLocationPreview(context, plaza, l10n),
                      const SizedBox(height: 25),
                      _buildCommentsButton(context, idPlaza, l10n),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFloatingRentButton(context, plaza, l10n),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, WidgetRef ref, Garaje plaza, User? user, bool isFavorite) {
    // Usar imágenes subidas si existen, si no, generar con PlazaImageService
    debugPrint('🖼️ Carousel - plaza.imagenes.length: ${plaza.imagenes.length}');
    
    final List<String> imageUrls = plaza.imagenes.isNotEmpty
        ? plaza.imagenes
        : PlazaImageService.getCarouselUrls(plaza.idPlaza ?? 0, width: 600, height: 400, count: 5);
    
    debugPrint('🖼️ Carousel - imageUrls.length: ${imageUrls.length}');
    if (plaza.imagenes.isEmpty) {
      debugPrint('🖼️ Carousel - Usando FALLBACK (PlazaImageService)');
    } else {
      debugPrint('🖼️ Carousel - Usando URLs de FIREBASE');
    }
    
    return Stack(
      children: [
        // PageView para el carrusel
        SizedBox(
          height: 350,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = imageUrls[index];
              
              return Stack(
                children: [
                  // Si hay imágenes subidas en Firebase, descargar como bytes
                  // Si no, usar fallback de PlazaImageService
                  if (plaza.imagenes.isNotEmpty)
                    FirebaseStorageImage(
                      plazaId: plaza.idPlaza.toString(),
                      index: index,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      showWarningOnError: true,
                    )
                  else
                    // Fallback: imagen de PlazaImageService (demo/genérica)
                    Image.network(
                      imageUrl,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // Mostrar imagen por defecto con icono de alerta
                        return Stack(
                          children: [
                            // Imagen por defecto
                            Container(
                              height: 350,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                            ),
                            // Icono de alerta en esquina superior derecha
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  // Gradiente overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          AppColors.darkestBlue,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Botones superiores: Back y Favorite
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                  _buildCircleButton(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: isFavorite ? Colors.red : Colors.white,
                    onPressed: () {
                      if (user != null) {
                        ref.read(homeProvider.notifier).stateFavorite(
                          Favorite(user.email ?? "", plaza.idPlaza.toString()),
                          !isFavorite,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Botones laterales para navegación del carrusel (CARRUSEL)
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCarouselArrowButton(
                  Icons.chevron_left,
                  onPressed: () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  enabled: _currentImageIndex > 0,
                ),
                _buildCarouselArrowButton(
                  Icons.chevron_right,
                  onPressed: () {
                    if (_currentImageIndex < imageUrls.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  enabled: _currentImageIndex < imageUrls.length - 1,
                ),
              ],
            ),
          ),
        ),

        // Indicadores de página en la parte inferior
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index ? Colors.blue : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, {required VoidCallback onPressed, Color iconColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCarouselArrowButton(IconData icon, {required VoidCallback onPressed, required bool enabled}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: enabled 
          ? Colors.blue.withOpacity(0.8)
          : Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: enabled ? [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white30,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(Garaje plaza, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plaza.direccion,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    l10n.spainIndicator(plaza.Provincia),
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Mostrar precio según tipo de alquiler
            if (plaza.rentIsNormal)
              // Alquiler mensual
              Text(
                '€${plaza.precio.toStringAsFixed(2).replaceAll('.', ',')} /mes',
                style: const TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold),
              )
            else
              // Alquiler por horas
              Text(
                l10n.pricePerHour(plaza.precio.toStringAsFixed(2).replaceAll('.', ',')),
                style: const TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            // Mostrar estimado por día
            Text(
              plaza.rentIsNormal 
                ? l10n.pricePerDay((plaza.precio / 30).toStringAsFixed(2).replaceAll('.', ',')) // Estimado: precio mensual / 30
                : l10n.pricePerDay((plaza.precio * 8).toStringAsFixed(2).replaceAll('.', ',')), // Estimado: precio hora * 8
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags(Garaje plaza, AppLocalizations l10n) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildTag(Icons.home, l10n.covered),
        _buildTag(Icons.videocam, l10n.vigilada),
        _buildTag(Icons.accessible, l10n.accesible),
      ],
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBanner(Garaje plaza, int plazaId, User? user, AppLocalizations l10n) {
    bool isAvailable = plaza.alquiler == null;
    print('🔍 _buildAvailabilityBanner: plazaId=$plazaId, plaza.idPlaza=${plaza.idPlaza}, alquiler=${plaza.alquiler}');
    
    // Si hay un alquiler mensual (AlquilerNormal), mostrar UI con opción de liberar si es el propietario
    if (plaza.alquiler != null && plaza.alquiler is! AlquilerPorHoras) {
      final isOwner = plaza.alquiler?.idArrendatario == user?.uid;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alquiler Mensual Activo',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isOwner 
                          ? 'Tienes esta plaza alquilada por período mensual'
                          : 'Esta plaza está alquilada por un período mensual',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isOwner) ...[  
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => _releaseMonthlyRentalDialog(context, plaza, plaza.alquiler, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Liberar Alquiler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      );
    }
    
    // Para alquileres por horas, usar el StreamBuilder existente
    return StreamBuilder<AlquilerPorHoras?>(
      stream: RentalByHoursService.watchPlazaRental(plazaId),
      builder: (context, snapshot) {
        final activeRental = snapshot.data;
        final isUserRental = activeRental != null && activeRental.idArrendatario == user?.uid;
        
        if (isUserRental) {
          // Mostrar información del alquiler activo del usuario
          final timeRemaining = activeRental.tiempoRestante();
          final isExpired = activeRental.estaVencido();
          final minutesUsed = activeRental.calcularTiempoUsado();
          final precioFinal = activeRental.calcularPrecioFinal();
          
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isExpired ? Colors.red : Colors.blue).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (isExpired ? Colors.red : Colors.blue).withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: (isExpired ? Colors.red : Colors.blue).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con estado del alquiler
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isExpired ? Colors.red : Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isExpired ? Colors.red : Colors.blue).withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.activeRental,
                            style: TextStyle(
                              color: isExpired ? Colors.red : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Tiempo restante - formato mejorado
                          if (!isExpired)
                            Text(
                              '⏱️ Tiempo restante: ${timeRemaining}m',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Text(
                              l10n.rentalExpired,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Información detallada del alquiler
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRentalInfoCell(
                        icon: Icons.timer,
                        label: l10n.timeUsed,
                        value: '$minutesUsed ${l10n.min}',
                      ),
                      Container(width: 1, color: Colors.white10),
                      _buildRentalInfoCell(
                        icon: Icons.schedule,
                        label: l10n.duration,
                        value: '${activeRental.duracionContratada} ${l10n.min}',
                      ),
                      Container(width: 1, color: Colors.white10),
                      _buildRentalInfoCell(
                        icon: Icons.euro,
                        label: l10n.estimatedPrice,
                        value: '€${precioFinal.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                
                // Botones de acción
                Row(
                  children: [
                    // Botón para liberar el alquiler
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _releaseRentalDialog(context, activeRental, l10n),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Liberar Ahora'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón para ir a gestionar alquileres
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(ActiveRentalsScreen.routeName);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.details, size: 18),
                        label: const Text('Detalles'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        
        // Mostrar disponibilidad normal
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isAvailable ? Colors.green : Colors.orange).withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (isAvailable ? Colors.green : Colors.orange).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isAvailable ? Colors.green : Colors.orange).withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isAvailable ? l10n.availableNow : l10n.notAvailable,
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRentalInfoCell({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Garaje plaza, AppLocalizations l10n) {
    final realDescription = PlazaDescriptionService.generateDescription(plaza.direccion);
    final tarifInfo = PlazaDescriptionService.getTarifInfo(plaza.direccion);
    final recommendation = PlazaDescriptionService.getRecommendation(plaza.direccion);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Descripción principal realista
        Text(
          l10n.descriptionTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          realDescription,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 16),
        
        // Tarifa y especificaciones técnicas
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💰 ' + tarifInfo,
                style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                plaza.largo.toString() + 'm × ' + plaza.ancho.toString() + 'm • Planta ' + plaza.planta.toString() + ' • ' +
                (plaza.vehicleType == VehicleType.moto ? l10n.suitableForMotos : l10n.suitableForCars),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Recomendación
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('💡 ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  recommendation,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoBtn(l10n.schedulesAction),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoBtn(l10n.rulesAction),
        ),
      ],
    );
  }

  Widget _buildInfoBtn(String label) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLocationPreview(BuildContext context, Garaje plaza, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.locationTitle,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _openMapInBrowser(plaza),
              child: Text(l10n.openInMapAction, style: const TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 150,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(plaza.latitud, plaza.longitud),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('plaza'),
                  position: LatLng(plaza.latitud, plaza.longitud),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMapInBrowser(Garaje plaza) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${plaza.latitud},${plaza.longitud}';
    
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback a búsqueda por dirección si está disponible
        final String fallbackUrl =
            'https://www.google.com/maps/search/${Uri.encodeComponent(plaza.direccion)}';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      debugPrint('Error abriendo mapa: $e');
    }
  }

  Widget _buildCommentsButton(BuildContext context, int idPlaza, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pushNamed(ListCommentsPage.routeName, arguments: idPlaza),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Colors.white10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(l10n.viewCommentsAction, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFloatingRentButton(BuildContext context, Garaje plaza, AppLocalizations l10n) {
    bool isAvailable = plaza.alquiler == null;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: isAvailable 
              ? () => Navigator.of(context).pushNamed(
                    plaza.rentIsNormal 
                      ? RentPage.routeName  // Monthly rental: calendar picker
                      : RentByHoursScreen.routeName,  // Hourly rental: duration picker
                    arguments: plaza.idPlaza
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isAvailable ? Colors.blue : Colors.red.withOpacity(0.7),
            disabledBackgroundColor: Colors.red.withOpacity(0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isAvailable ? 8 : 4,
            shadowColor: (isAvailable ? Colors.blue : Colors.red).withOpacity(0.4),
          ),
          child: Text(
            isAvailable ? l10n.rentNowAction : l10n.notAvailableAction,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// Diálogo para confirmar la liberación del alquiler
  Future<void> _releaseRentalDialog(BuildContext context, AlquilerPorHoras rental, AppLocalizations l10n) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkestBlue,
        title: const Text(
          'Liberar alquiler',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Confirma liberar la plaza. Se cobrará según el tiempo usado.',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performReleaseRental(rental, l10n);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Liberar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Ejecuta la liberación del alquiler
  Future<void> _performReleaseRental(AlquilerPorHoras rental, AppLocalizations l10n) async {
    try {
      // Validar que tenemos el ID del documento
      if (rental.documentId == null || rental.documentId!.isEmpty) {
        throw Exception('Error: No se encontró el ID del alquiler');
      }

      debugPrint('🔑 [DETAILS_GARAGE] _performReleaseRental: Iniciando liberación de alquiler ${rental.documentId}');

      // Mostrar SnackBar de "liberando"
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Liberando plaza...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 10),
          ),
        );
      }

      debugPrint('🔑 [DETAILS_GARAGE] Llamando a RentalByHoursService.releaseRental()');
      await RentalByHoursService.releaseRental(rental.documentId!);
      debugPrint('✅ [DETAILS_GARAGE] RentalByHoursService.releaseRental() completado');

      // ⏳ Esperar 1200ms a que Firestore se sincronice (tiempo crítico)
      debugPrint('⏳ [DETAILS_GARAGE] Esperando 1200ms para sincronización de Firestore...');
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      debugPrint('🔄 [DETAILS_GARAGE] Refrescando providers...');
      ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
      ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: true));

      // ⏳ Esperar 300ms a que los providers se procesen
      debugPrint('⏳ [DETAILS_GARAGE] Esperando 300ms para procesamiento de providers...');
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Eliminar SnackBar anterior (liberando)
      ScaffoldMessenger.of(context).clearSnackBars();

      // Calcular información final para mostrar
      final tiempoUsado = rental.calcularTiempoUsado();
      final precioFinal = rental.calcularPrecioFinal();
      debugPrint('💰 [DETAILS_GARAGE] Tiempo usado: $tiempoUsado min, Precio final: €$precioFinal');

      // Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Alquiler liberado - Total: €${precioFinal.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      debugPrint('⏳ [DETAILS_GARAGE] Esperando 500ms para visual...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Forzar reconstrucción de la pantalla actual para actualizar el banner
      if (mounted) {
        debugPrint('🔄 [DETAILS_GARAGE] Llamando setState() para actualizar UI');
        setState(() {});
      }

      debugPrint('✅ [DETAILS_GARAGE] Liberación completada exitosamente');
    } catch (e) {
      debugPrint('❌ [DETAILS_GARAGE] Error al liberar alquiler: $e');

      if (mounted) {
        // Eliminar SnackBar anterior
        ScaffoldMessenger.of(context).clearSnackBars();

        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Diálogo para confirmar la liberación del alquiler mensual
  Future<void> _releaseMonthlyRentalDialog(BuildContext context, Garaje plaza, Alquiler? rental, AppLocalizations l10n) async {
    if (rental == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkestBlue,
        title: const Text(
          'Liberar alquiler mensual',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Confirma liberar esta plaza. Se eliminarán los datos del alquiler mensual.',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performReleaseMonthlyRental(plaza, rental, l10n);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Liberar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Ejecuta la liberación del alquiler mensual
  Future<void> _performReleaseMonthlyRental(Garaje plaza, Alquiler rental, AppLocalizations l10n) async {
    try {
      // Mostrar loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.darkestBlue,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Liberando alquiler mensual...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      }

      // Obtener referencia a Firestore
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      debugPrint('🔄 Buscando alquiler mensual: plazaId=${plaza.idPlaza}, userId=${user.uid}');
      
      // Eliminar el alquiler de la tabla alquileres
      // Buscar el documento del alquiler por plazaId, idArrendatario y tipo
      final rentalQuery = await firestore
          .collection('alquileres')
          .where('idPlaza', isEqualTo: plaza.idPlaza)
          .where('idArrendatario', isEqualTo: user.uid)
          .where('tipo', isEqualTo: 0)  // tipo 0 = AlquilerNormal (mensual)
          .get();

      debugPrint('📋 Documentos encontrados: ${rentalQuery.docs.length}');

      // Eliminar todos los documentos encontrados (normalmente solo 1)
      if (rentalQuery.docs.isEmpty) {
        throw Exception('No se encontró alquiler mensual para liberar');
      }

      for (var doc in rentalQuery.docs) {
        await firestore.collection('alquileres').doc(doc.id).delete();
        debugPrint('✅ Documento de alquiler eliminado: ${doc.id}');
      }

      // Actualizar el documento de la plaza (establecer alquiler a null)
      await firestore
          .collection('garajes')
          .doc(plaza.idPlaza.toString())
          .update({
            'alquiler': null,
            'alquilerId': null,
            'alquilerTipo': null,
          });
      
      debugPrint('✅ Campos de plaza actualizados');

      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        
        // Mostrar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Alquiler mensual liberado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Refrescar la lista de garages en home para actualizar estado
        await ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
        
        // Refrescar la vista local
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al liberar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('❌ Error al liberar alquiler mensual: $e');
    }
  }

}


