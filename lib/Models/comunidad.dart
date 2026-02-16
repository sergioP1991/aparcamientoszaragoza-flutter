class Comunidad {
  final String ccom;
  final String nombre;

  Comunidad({
    required this.ccom,
    required this.nombre,
  });

  factory Comunidad.fromJson(Map<String, dynamic> json) {
    return Comunidad(
      ccom: json['CCOM'] as String,
      nombre: json['COM'] as String,
    );
  }

  static Comunidad? getByNombre(
      List<Comunidad> comunidades,
      String nombre,
      ) {
    try {
      return comunidades.firstWhere(
            (c) => c.nombre.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
