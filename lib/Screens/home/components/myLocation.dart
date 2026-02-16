import 'package:aparcamientoszaragoza/ModelsUI/homeData.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/LocationProvider.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/detailsGarage/detailsGarage_screen.dart';
import 'package:flutter/material.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

Widget bodyLocation(BuildContext context, WidgetRef ref, LocationState locationState, AsyncValue<HomeData?> homeData, [Function(int)? onGarageTap]) {
  return homeData.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.genericError(err.toString()))),
    data: (data) => MapView(
      locationState: locationState,
      garages: data?.listGarajes ?? [],
      currentUserId: data?.user?.uid,
      onTap: onGarageTap,
    ),
  );
}

class MapView extends StatefulWidget {
  final LocationState locationState;
  final List<Garaje> garages;
  final String? currentUserId;
  final Function(int)? onTap;

  const MapView({super.key, required this.locationState, required this.garages, this.currentUserId, this.onTap});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  Garaje? _selectedGarage;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  final String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = widget.garages.map((garage) {
      return Marker(
        markerId: MarkerId(garage.idPlaza.toString()),
        position: LatLng(garage.latitud, garage.longitud),
        icon: BitmapDescriptor.defaultMarkerWithHue(
           _selectedGarage?.idPlaza == garage.idPlaza 
               ? BitmapDescriptor.hueBlue 
               : BitmapDescriptor.hueAzure
        ),
        onTap: () {
          if (garage.propietario == widget.currentUserId) return; // Disable for owner
          
          print('DEBUG: Marker tapped for garage ${garage.idPlaza}');
          setState(() {
            _selectedGarage = garage;
          });
        },
      );
    }).toSet();

    if (widget.locationState is LocationData) {
      final loc = widget.locationState as LocationData;
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(loc.position.latitude, loc.position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );
    }


    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.locationState is LocationData
                ? LatLng((widget.locationState as LocationData).position.latitude,
                    (widget.locationState as LocationData).position.longitude)
                : const LatLng(41.6488, -0.8891),
            zoom: 14,
          ),
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: (controller) {
            _mapController = controller;
            _mapController?.setMapStyle(_darkMapStyle);
          },
          markers: markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onTap: (_) {
            setState(() {
              _selectedGarage = null;
            });
          },
          padding: const EdgeInsets.only(top: 140), 
        ),
        
        // Layer Button
        Positioned(
          bottom: 120,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.layers_outlined, color: Colors.white, size: 24),
          ),
        ),

        // Bottom Details Sheet
        if (_selectedGarage != null)
          SizedBox.expand(
            child: _buildDraggableSheet(),
          ),
      ],
    );
  }

  Widget _buildDraggableSheet() {
    print('DEBUG: Building sheet for ${_selectedGarage?.idPlaza}');
    return DraggableScrollableSheet(
      key: ValueKey(_selectedGarage?.idPlaza), // Force rebuild when garage changes
      controller: _sheetController,
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildBadge(AppLocalizations.of(context)!.availableLabel, AppColors.accentGreen),
                            const SizedBox(width: 8),
                            _buildRating("4.8"),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedGarage?.direccion ?? AppLocalizations.of(context)!.unknownAddress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white54, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${_selectedGarage?.direccion}, Zaragoza",
                                style: const TextStyle(color: Colors.white54, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${_selectedGarage?.precio.toStringAsFixed(2)}€",
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 4),
                              child: Text(
                                AppLocalizations.of(context)!.perHourLabel,
                                style: const TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (_selectedGarage?.imagen != null && _selectedGarage!.imagen!.isNotEmpty)
                        ? (_selectedGarage!.imagen!.startsWith('assets/')
                            ? Image.asset(
                                _selectedGarage!.imagen!,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                _selectedGarage!.imagen!,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/garaje2.jpeg',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ))
                        : Image.asset(
                            'assets/garaje2.jpeg',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions_outlined, size: 20),
                      label: Text(AppLocalizations.of(context)!.getDirectionsAction, style: const TextStyle(fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (widget.onTap != null && _selectedGarage != null) {
                          widget.onTap!(_selectedGarage!.idPlaza!);
                        } else if (_selectedGarage != null) {
                          Navigator.of(context).pushNamed(DetailsGarajePage.routeName, arguments: _selectedGarage!.idPlaza);
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(AppLocalizations.of(context)!.reserveNowAction, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.darkestBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRating(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.orange, size: 12),
          const SizedBox(width: 4),
          Text(
            "$rating (120)",
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}