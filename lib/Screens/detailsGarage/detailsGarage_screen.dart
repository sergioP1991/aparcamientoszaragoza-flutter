import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';
import 'package:aparcamientoszaragoza/Services/PlazaImageService.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:aparcamientoszaragoza/Screens/timeline/timeline_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/rent/rent_screen.dart' hide Text;
import 'package:aparcamientoszaragoza/Screens/active_rentals/active_rentals_screen.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/widgets/Buttons.dart';
import 'package:aparcamientoszaragoza/widgets/Spaces.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int idPlaza = (ModalRoute.of(context)?.settings.arguments ?? 0) as int;
    final homeDataState = ref.watch(fetchHomeProvider(allGarages: true));
    final plaza = homeDataState.value?.getGarageById(idPlaza);
    final user = homeDataState.value?.user;

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
                      _buildAvailabilityBanner(plaza, user, l10n),
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
    final imageUrls = PlazaImageService.getCarouselUrls(plaza.idPlaza ?? 0, width: 600, height: 400, count: 5);
    
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
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrls[index]),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Usar fallback si hay error
                    },
                  ),
                ),
                child: Container(
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
            Text(
              l10n.pricePerHour(plaza.precio.toStringAsFixed(2).replaceAll('.', ',')),
              style: const TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.pricePerDay((plaza.precio * 8).toStringAsFixed(2).replaceAll('.', ',')), // Estimate
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

  Widget _buildAvailabilityBanner(Garaje plaza, User? user, AppLocalizations l10n) {
    bool isAvailable = plaza.alquiler == null;
    return StreamBuilder<AlquilerPorHoras?>(
      stream: RentalByHoursService.watchPlazaRental(plaza.idPlaza ?? 0),
      builder: (context, snapshot) {
        final activeRental = snapshot.data;
        final isUserRental = activeRental != null && activeRental.idArrendatario == user?.uid;
        
        if (isUserRental) {
          // Mostrar información del alquiler activo del usuario
          final timeRemaining = activeRental.tiempoRestante();
          final isExpired = activeRental.estaVencido();
          final minutesUsed = activeRental.calcularTiempoUsado();
          
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isExpired ? Colors.red : Colors.blue).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (isExpired ? Colors.red : Colors.blue).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isExpired ? Colors.red : Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isExpired ? Colors.red : Colors.blue).withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
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
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isExpired 
                              ? l10n.rentalExpired
                              : l10n.timeRemaining('$timeRemaining ' + (timeRemaining == 1 ? l10n.minute : l10n.minutes)),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(ActiveRentalsScreen.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        backgroundColor: Colors.blue.withOpacity(0.3),
                        foregroundColor: Colors.blue,
                      ),
                      icon: const Icon(Icons.directions_run, size: 16),
                      label: Text(l10n.manageRental),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
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
                        value: '€${activeRental.calcularPrecioFinal().toStringAsFixed(2)}',
                      ),
                    ],
                  ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.descriptionTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.garageDescription(
            plaza.direccion,
            plaza.largo.toString(),
            plaza.ancho.toString(),
            plaza.planta.toString(),
            plaza.vehicleType == VehicleType.moto ? l10n.suitableForMotos : l10n.suitableForCars,
          ),
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
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
              ? () => Navigator.of(context).pushNamed(RentPage.routeName, arguments: plaza.idPlaza)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            disabledBackgroundColor: Colors.grey.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: Colors.blue.withOpacity(0.4),
          ),
          child: Text(
            isAvailable ? l10n.rentNowAction : l10n.notAvailableAction,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

}

