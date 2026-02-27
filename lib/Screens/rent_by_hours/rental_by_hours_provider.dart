import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Models/alquiler_por_horas.dart';
import 'package:aparcamientoszaragoza/Services/RentalByHoursService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider para crear un nuevo alquiler por horas
final createRentalProvider = FutureProvider.family<String?, CreateRentalParams>((ref, params) async {
  final docId = await RentalByHoursService.createRental(
    plazaId: params.plazaId,
    durationMinutes: params.durationMinutes,
    pricePerMinute: params.pricePerMinute,
  );
  return docId;
});

// Provider para obtener alquileres activos del usuario
final userActiveRentalsProvider = StreamProvider<List<AlquilerPorHoras>>((ref) {
  return RentalByHoursService.watchUserActiveRentals();
});

// Provider para obtener un alquiler específico
final getRentalProvider = FutureProvider.family<AlquilerPorHoras?, String>((ref, rentalId) async {
  final doc = await FirebaseFirestore.instance.collection('alquileres').doc(rentalId).get();
  if (doc.exists) {
    return AlquilerPorHoras.fromFirestore(doc);
  }
  return null;
});

class CreateRentalParams {
  final int plazaId;
  final int durationMinutes;
  final double pricePerMinute;

  CreateRentalParams({
    required this.plazaId,
    required this.durationMinutes,
    required this.pricePerMinute,
  });
}
