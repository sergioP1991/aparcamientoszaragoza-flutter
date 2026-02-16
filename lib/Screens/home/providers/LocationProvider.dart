import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';


import 'package:geolocator/geolocator.dart';

sealed class LocationState {
  const LocationState();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationData extends LocationState {
  final Position position;
  const LocationData(this.position);
}

class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);
}

final locationProvider =
StateNotifierProvider<LocationNotifier, LocationState>(
      (ref) => LocationNotifier(),
);

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationLoading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = const LocationError('El servicio de localización está desactivado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = const LocationError('Permiso de localización denegado');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = const LocationError(
          'Permiso denegado permanentemente. Actívalo desde ajustes',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = LocationData(position);
    } catch (e) {
      state = LocationError(e.toString());
    }
  }

  /// Para refrescar la localización manualmente
  Future<void> refresh() async {
    state = const LocationLoading();
    await _init();
  }
}
