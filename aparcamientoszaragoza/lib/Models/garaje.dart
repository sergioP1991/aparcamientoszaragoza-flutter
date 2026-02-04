import 'package:aparcamientoszaragoza/Models/alquiler.dart';
import 'package:aparcamientoszaragoza/Models/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'favorite.dart';

enum VehicleType {
  moto,
  cochePequeno,
  cocheGrande,
  furgoneta,
}

class Garaje {

  int? idPlaza;
  String direccion;
  double latitud;
  double longitud;
  String CodigoPostal;
  String Provincia;
  double? ancho;
  double? largo;
  int planta;
  VehicleType vehicleType;
  Alquiler? alquiler;
  String propietario;
  bool rentIsNormal;
  int precio;
  bool esCubierto;
  List<Favorite>? favorita;
  List<Comment>? comments;
  String? imagen;
  String? docId;

  Garaje(
      this.idPlaza,
      this.direccion,
      this.CodigoPostal,
      this.Provincia,
      this.latitud,
      this.longitud,
      this.ancho,
      this.largo,
      this.planta,
      this.vehicleType,
      this.alquiler,
      this.propietario,
      this.rentIsNormal,
      this.precio,
      this.esCubierto,
      this.comments,
      {this.imagen, this.docId}
  );

  @override
  String toString() {
    String tipo;
    if (rentIsNormal)
      tipo = "normal";
    else
      tipo = "especial";

    String vehicleStr;
    switch(vehicleType) {
      case VehicleType.moto: vehicleStr = "Moto"; break;
      case VehicleType.cochePequeno: vehicleStr = "Coche pequeño"; break;
      case VehicleType.cocheGrande: vehicleStr = "Coche grande"; break;
      case VehicleType.furgoneta: vehicleStr = "Furgoneta"; break;
    }

    return '''
      --- Información del Garaje ---
      ID Plaza: $idPlaza
      Dirección: $direccion
      Ubicación (Lat, Long): ${latitud}, ${longitud}
      Codigo Postal : $CodigoPostal, Provincia: $Provincia
      Dimensiones: ${ancho?.toStringAsFixed(2) ?? 'N/A'}m x ${largo?.toStringAsFixed(2) ?? 'N/A'}m
      Se encuentra en la planta $planta
      Tipo de vehículo: $vehicleStr
      Estado: ${alquiler != null ? 'Alquilada' : 'Disponible'}
      Tipo alquiler : $tipo
      Precio : $precio
      Cubierta: ${esCubierto ? 'Sí' : 'No'}
      Imagen : ${imagen ?? 'N/A'}
      -----------------------------
    ''';
  }

  bool isFavorite(String? mail_user) {
    return this.favorita?.any((c) => c.userEmail.toString() == (mail_user?.toString() ?? "")) ?? false;
  }

  factory Garaje.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshotGarage) {
    final data = snapshotGarage.data()!;
    final commentsList = data.containsKey('comments')
        ? (data['comments'] as List<dynamic>? ?? [])
        : <dynamic>[];

    final comments = commentsList
        .map((c) => Comment.fromFirestore(Map<String, dynamic>.from(c)))
        .toList();

    VehicleType type = VehicleType.moto;
    if (data.containsKey('vehicleType')) {
      final vType = data['vehicleType'] as String;
      type = VehicleType.values.firstWhere(
        (e) => e.name == vType,
        orElse: () => VehicleType.moto,
      );
    } else if (data.containsKey('moto')) {
      // Fallback for old data
      type = data['moto'] == true ? VehicleType.moto : VehicleType.cochePequeno;
    }

    return Garaje(
        data['idPlaza'],
        data['direccion'],
        data['codigo_postal'],
        data['provincia'],
        data['latitud']?.toDouble() ?? 0.0,
        data['longitud']?.toDouble() ?? 0.0,
        data['ancho']?.toDouble(),
        data['largo']?.toDouble(),
        data['planta'],
        type,
        null,
        data['propietario'],
        data['rentIsNormal'],
        data['precio'],
        data['esCubierto'] ?? true,
        comments,
        imagen: data.containsKey('imagen') ? data['imagen'] : null,
        docId: snapshotGarage.id
    );
  }

  void addFavorites (List<Favorite> listFavorites) {
    this.favorita = listFavorites;
  }

  int countFavorites(){
    return favorita?.length ?? 0;
  }

}