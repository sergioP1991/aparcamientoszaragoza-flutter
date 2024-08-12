import 'package:cloud_firestore/cloud_firestore.dart';

class Garaje{

  String? nombre;
  String? direccion; // Necesitamos indicar que admite valores nulos, ya que al instanciar no le damos un valor por defecto
  double? ancho;// ? ancho;
  double? largo;
  double? latitud;
  double? longitud;
  bool moto;
  bool alquilada;

  Garaje( this.nombre,
          this.direccion,
          this.ancho,
          this.largo,
          this.latitud,
          this.longitud,
          this.moto,
          this.alquilada);

  @override
  String toString() {
    return 'Garaje{nombre: $nombre, direccion: $direccion, ancho: $ancho, largo: $largo, latitud: $latitud, longitud: $longitud, moto: $moto, alquilada: $alquilada}';
  }

  factory Garaje.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Garaje(
        snapshot.data()!['nombre'],
        snapshot.data()!['direccion'],
        snapshot.data()!['ancho'],
        snapshot.data()!['largo'],
        snapshot.data()!['latitud'],
        snapshot.data()!['longitud'],
        false,
        true
    );
  }

}