import 'package:aparcamientoszaragoza/Models/incidencias.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class IncidentsRegisterState extends StateNotifier<AsyncValue<Incidencias?>> {
  IncidentsRegisterState() : super(const AsyncData(null));

  Future<Incidencias?> newIncidence(Position? lugar, String titulo, String descripcion, String imagen) async {
    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      try {
        await FirebaseFirestore.instance.collection('incidencias').add({
          'descripcion': descripcion,
          'fecha': DateTime.now(),
          'geoposicion': GeoPoint(lugar!.latitude,lugar!.longitude),
          'photo': imagen,
          'titulo': titulo,
        });
        print('incidencia registrada con éxito');
      } catch (e) {
        print('Error al registrar la incidencia: $e');
      }
    });

    return null;
  }
}

@riverpod
final incidentProvider = StateNotifierProvider<
    IncidentsRegisterState, AsyncValue<Incidencias?>>((ref) {
  return IncidentsRegisterState();
});
