import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Models/history.dart';
import 'package:aparcamientoszaragoza/Services/activity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class GarajeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Garaje> _garajes = [];
  List<Garaje> get garajes => _garajes;

  /// Añadir un garaje
  Future<void> addGaraje(Garaje garaje) async {
    try {
      final data = garaje.toFirestore();
      data['alquiler'] = null;
      data['comments'] = null;
      
      await _firestore.collection('garaje').add(data);

      await ActivityService.recordEvent(History(
        fecha: DateTime.now(),
        tipo: TipoEvento.registro_plaza,
        descripcion: "Nueva plaza de parking registrada",
        userId: garaje.propietario,
        meta: "${garaje.direccion}",
      ));
    } catch (e) {
      debugPrint("❌ Error al guardar garaje: $e");
    }
  }

  /// Actualizar garaje
  Future<void> updateGaraje(String idDoc, Garaje garaje) async {
    try {
      final data = garaje.toFirestore();
      data['alquiler'] = garaje.alquiler?.objectToMap();
      data['comments'] = [];
      
      await _firestore.collection('garaje').doc(idDoc).update(data);

      await ActivityService.recordEvent(History(
        fecha: DateTime.now(),
        tipo: TipoEvento.actualizacion_plaza,
        descripcion: "Plaza de parking modificada",
        userId: garaje.propietario,
        meta: "${garaje.direccion}",
      ));
    } catch (e) {
      debugPrint("❌ Error al actualizar garaje: $e");
    }
  }

  /// Eliminar garaje
  Future<void> deleteGaraje(String idDoc) async {
    try {
      await _firestore.collection('garaje').doc(idDoc).delete();
      await ActivityService.recordEvent(History(
        fecha: DateTime.now(),
        tipo: TipoEvento.eliminacion_plaza,
        descripcion: "Plaza de parking eliminada",
        userId: "System", // Could be current user
        meta: "DocID: $idDoc",
      ));
    } catch (e) {
      debugPrint("❌ Error al eliminar garaje: $e");
    }
  }

/*
  final garageProvider = StateNotifierProvider<GarajeProvider, AsyncValue<Garaje?>>((ref) {
    return GarajeProvider();
  });
*/
}
