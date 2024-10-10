import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/GarajesProviders.dart';
import 'package:aparcamientoszaragoza/Screens/listComments/listComments_screen.dart';
import 'package:aparcamientoszaragoza/widgets/Buttons.dart';
import 'package:aparcamientoszaragoza/widgets/Spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../Values/app_colors.dart';

class DetailsGarajePage extends ConsumerWidget {

  static const routeName = '/details-garage';

  DetailsGarajePage({super.key});

  late CameraPosition _initialCameraPosition; // State variable for camera position

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indexPlaza = (ModalRoute
        .of(context)
        ?.settings
        .arguments ?? 0) as int;
    List<Garaje> garageList = ref.watch(garajeListProvider);
    Garaje? plaza = garageList[indexPlaza];

    _initialCameraPosition = CameraPosition(
      target: LatLng(plaza?.latitud ?? 0.0, plaza?.longitud ?? 0.0),
      // Handle potential null values
      zoom: 6.0, // Set zoom level
    );

    return Scaffold(
      //backgroundColor: AppColors.darkBlue,
      //body: _viewInfo(plaza),
        body: Stack( // Use Stack to position map below content
            children: [
              _buildMap(context, plaza),
              _viewInfo(context, plaza),
            ]
        )
    );
  }

  Widget _viewInfo(BuildContext context, Garaje? plaza) {
    return
      Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child:
          Padding(
            padding: const EdgeInsets.all(15.0),
            child:
            Wrap(
                children: [ Column(
                  children: [
                    _buildValue("Direccion", plaza?.direccion ?? ""),
                    spaceXXXXS(),
                    _buildValue("Latitud", plaza?.latitud.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Longitud", plaza?.longitud.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Moto", plaza?.moto.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Largo", plaza?.largo.toString() ?? ""),
                    spaceXXXXS(),
                    _buildValue("Ancho", plaza?.ancho.toString() ?? ""),
                    spaceXXXXS(),
                    ButtonBlueApp('Comentarios', onPressed: () =>
                        Navigator.of(context).pushNamed(
                            listCommentsPage.routeName)),
                    spaceXXS(),
                  ],
                )
                ]
            ),
          ));
  }

  Widget _buildValue(String key, String value) {
    return
      Row(children: [
        Text(key, style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Flexible(child: Container()),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis)
      ]);
  }

  Widget _buildMap(BuildContext context, Garaje? plaza) {
    return Scaffold( //Card
      body: Stack( // Use Stack to position map below content
        children: [
          Positioned( // Position map at the bottom
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: SizedBox(
              height: MediaQuery
                  .sizeOf(context)
                  .height, // Adjust map height as needed
              child: GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                markers: { // Add a marker for the plaza location
                  Marker(
                    markerId: const MarkerId('plaza_marker'),
                    position: LatLng(
                      plaza?.latitud ?? 0.0,
                      plaza?.longitud ?? 0.0,
                    ),
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}