import 'package:aparcamientoszaragoza/Models/normal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../Models/alquiler.dart';

class RentState extends StateNotifier<AsyncValue<Alquiler?>> {
  RentState(super.state);

  Future<void> newRentProvider(Alquiler alquiler) async {
    try {
        await FirebaseFirestore.instance.collection('alquileres').add(alquiler.registrarFirebase());
        print('alquiler reallizado con éxito');
    } catch (e) {
      print('Error al alquilar: $e');
    }
  }
}
