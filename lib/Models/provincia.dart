class Provincia {
  final String ccom;
  final String cpro;
  final String nombre;
  final String nombreAlternativo;

  Provincia({
    required this.ccom,
    required this.cpro,
    required this.nombre,
    required this.nombreAlternativo,
  });

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(
      ccom: json['CCOM']?.toString() ?? '',
      cpro: json['CPRO']?.toString() ?? '',
      nombre: json['PRO']?.toString() ?? '',
      nombreAlternativo: json['ALTERNATIVO_PRO']?.toString() ?? '',
    );
  }

  static Provincia? getByNombre(
      List<Provincia> provincias,
      String nombre,
      ) {
    try {
      return provincias.firstWhere(
            (p) => p.nombre.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
