import 'package:aparcamientoszaragoza/Models/favorite.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/Timeline/timeline_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/Screens/rent/rent_screen.dart' hide Text;
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/widgets/Buttons.dart';
import 'package:aparcamientoszaragoza/widgets/Spaces.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class DetailsGarajePage extends ConsumerWidget {
  static const routeName = '/details-garage';

  const DetailsGarajePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                _buildImageSection(context, ref, plaza, user, isFavorite),
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
                      _buildAvailabilityBanner(plaza, l10n),
                      const SizedBox(height: 25),
                      _buildDescription(plaza, l10n),
                      const SizedBox(height: 25),
                      _buildActionButtons(context, l10n),
                      const SizedBox(height: 25),
                      _buildLocationPreview(context, plaza, l10n),
                      const SizedBox(height: 25),
                      _buildCommentsButton(context, idPlaza, l10n),
                      const SizedBox(height: 120), // Space for the floating rent button
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

  Widget _buildImageSection(BuildContext context, WidgetRef ref, Garaje plaza, User? user, bool isFavorite) {
    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (plaza.imagen != null && plaza.imagen!.isNotEmpty)
                  ? (plaza.imagen!.startsWith('assets/') 
                      ? AssetImage(plaza.imagen!)
                      : NetworkImage(plaza.imagen!) as ImageProvider)
                  : const AssetImage('assets/garaje2.jpeg'),
              fit: BoxFit.cover,
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
        ),
        SafeArea(
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
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 30, height: 4, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 5),
              Container(width: 8, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 5),
              Container(width: 8, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            ],
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

  Widget _buildAvailabilityBanner(Garaje plaza, AppLocalizations l10n) {
    bool isAvailable = plaza.alquiler == null;
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
        _buildInfoBtn(l10n.schedulesAction),
        const SizedBox(width: 12),
        _buildInfoBtn(l10n.rulesAction),
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
              onPressed: () {},
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

