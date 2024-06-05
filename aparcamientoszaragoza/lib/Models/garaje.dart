class Garaje{

  String? nombre;
  String? direccion; // Necesitamos indicar que admite valores nulos, ya que al instanciar no le damos un valor por defecto
  int? ancho;
  int? largo;
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
}