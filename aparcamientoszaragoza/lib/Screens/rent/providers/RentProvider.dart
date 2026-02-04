import 'package:aparcamientoszaragoza/Models/history.dart';
import 'package:aparcamientoszaragoza/Services/activity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../Models/alquiler.dart';

class RentState extends StateNotifier<AsyncValue<Alquiler?>> {
  RentState() : super(const AsyncData(null));

  Future<void> newRentProvider(Alquiler alquiler) async {
    try {
      await FirebaseFirestore.instance.collection('alquileres').add(alquiler.objectToMap());
      
      if (alquiler.idArrendatario != null) {
        await ActivityService.recordEvent(History(
          fecha: DateTime.now(),
          tipo: TipoEvento.alquiler,
          descripcion: "Alquiler de plaza de parking iniciado",
          userId: alquiler.idArrendatario,
          meta: "Plaza ID: ${alquiler.idPlaza}",
        ));
      }
      
      print('alquiler realizado con éxito');
    } catch (e) {
      print('Error al alquilar: $e');
    }
  }

}

final rentProvider = StateNotifierProvider<
    RentState, AsyncValue<Alquiler?>>((ref) {
  return RentState();
});
