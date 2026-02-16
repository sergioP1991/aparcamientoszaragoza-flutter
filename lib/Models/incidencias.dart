import 'package:cloud_firestore/cloud_firestore.dart';

class Incidencias {

  int? id;
  String? descripcion;
  DateTime? fecha;
  GeoPoint? geoposicion;
  String? foto;
  String? titulo;

  Incidencias(this.id, this.descripcion, this.fecha, this.geoposicion, this.foto, this.titulo);
}
