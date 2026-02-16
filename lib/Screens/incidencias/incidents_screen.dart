import 'package:aparcamientoszaragoza/Components/app_text_form_field.dart';
import 'package:aparcamientoszaragoza/Screens/incidencias/providers/IncidentsProviders.dart';
import 'package:aparcamientoszaragoza/Values/app_regex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';

class IncidentsPage extends ConsumerStatefulWidget {

  static const routeName = '/incidencias';

  @override
  _IncidenciasState createState() => _IncidenciasState();
}

class _IncidenciasState extends ConsumerState<IncidentsPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titulo;

  List<String> _tiposIncidencia = ['','Tipo1', 'Tipo2', 'Tipo3']; // Lista de opciones
  String? _tipoIncidenciaSeleccionada; // Variable para almacenar la opción seleccionada

  Position? _currentPosition;
  String _locationErrorMessage = '';

  final ValueNotifier<bool> urlImag = ValueNotifier(false);

  late final TextEditingController descripcion;
  late final TextEditingController urlPhoto;

  final ValueNotifier<bool> urlImage = ValueNotifier(false);

  void initializeControllers() {
    titulo = TextEditingController()..addListener(controllerListener);
    descripcion = TextEditingController()..addListener(controllerListener);
    urlPhoto = TextEditingController()
      ..addListener(controllerUrlImageListener);
  }

  void disposeControllers() {
    titulo.dispose();
    descripcion.dispose();
  }

  void controllerListener() {

  }

  void controllerUrlImageListener() {
    final urlImageProfile = urlPhoto.text;

    if (urlImageProfile.isEmpty) {
      urlImage.value = false;
      return;
    }

    if (AppRegex.urlProfileImageRegex.hasMatch(urlImageProfile)) {
      urlImage.value = true;
    } else {
      urlImage.value = false;
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    initializeControllers();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.incidentsTitle)),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppTextFormField(
                autofocus: true,
                labelText: l10n.fullNameLabel,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _formKey.currentState?.validate(),
                controller: titulo,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: l10n.incidentTypeLabel),
                value: _tipoIncidenciaSeleccionada,
                items: _tiposIncidencia.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoIncidenciaSeleccionada = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.selectLocationTypeRequired;
                  }
                  return null;
                },
              ),
              AppTextFormField(
                labelText: l10n.descriptionSection,
                controller: descripcion,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              Divider(
                color: Colors.grey, // Puedes cambiar el color de la línea
                thickness: 6,      // Puedes cambiar el grosor de la línea
                indent: 6,        // Espacio al inicio de la línea
                endIndent: 6,     // Espacio al final de la línea
              ),TextFormField(
                controller: urlPhoto,
                keyboardType: TextInputType.url,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: l10n.incidentImageUrlLabel,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.requiredField;
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath || (uri.scheme != 'http' && uri.scheme != 'https')) {
                    return l10n.emailInvalidRegister; // Reusing a valid-check label if I have one for generic URL, or better use something else.
                  }
                  return null;
                },
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    if (_currentPosition != null)
                      Text(
                        l10n.latLongIndicator(_currentPosition!.latitude.toStringAsFixed(2), _currentPosition!.longitude.toStringAsFixed(2)),
                        style: const TextStyle(fontSize: 18),
                      )
                    else
                      Text(
                        _locationErrorMessage.isNotEmpty ? _locationErrorMessage : l10n.obtainingLocation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _getLocation,
                      child: Text(l10n.reloadLocationAction),
                    ),
                    Divider(
                      color: Colors.grey, // Puedes cambiar el color de la línea
                      thickness: 6,      // Puedes cambiar el grosor de la línea
                      indent: 6,        // Espacio al inicio de la línea
                      endIndent: 6,     // Espacio al final de la línea
                    ),
                    Divider(
                      color: Colors.grey, // Puedes cambiar el color de la línea
                      thickness: 6,      // Puedes cambiar el grosor de la línea
                      indent: 6,        // Espacio al inicio de la línea
                      endIndent: 6,     // Espacio al final de la línea
                    ),
                    ElevatedButton(
                      onPressed: () => {
                          ref .read(incidentProvider.notifier).newIncidence(
                              _currentPosition,
                              _tipoIncidenciaSeleccionada.toString(),
                              descripcion.text, urlPhoto.text
                          ),
                      },
                      child: Text(l10n.sendIncidentAction),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      final Position? position = await _getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _locationErrorMessage = '';
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _currentPosition = null;
        _locationErrorMessage = e.toString();
      });
      print('Error al obtener la ubicación: $e');
    }
  }
  Future<Position?> _getCurrentLocation() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final l10n = AppLocalizations.of(context)!;
    if (!serviceEnabled) {
      return Future.error(l10n.locationServicesDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(l10n.locationPermissionsDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(l10n.locationPermissionsPermanentlyDenied);
    }

    return await Geolocator.getCurrentPosition();
  }

}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
