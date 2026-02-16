class Nucleo {
  final String ccom;
  final String cpro;
  final String cmum;
  final String cmun;
  final String nombreEntidad;
  final String codigoUnidad;
  final String codigoNucleo;
  final String nombre;
  final String nombre50;

  Nucleo({
    required this.ccom,
    required this.cpro,
    required this.cmum,
    required this.cmun,
    required this.nombreEntidad,
    required this.codigoUnidad,
    required this.codigoNucleo,
    required this.nombre,
    required this.nombre50,
  });

  factory Nucleo.fromJson(Map<String, dynamic> json) {
    return Nucleo(
      ccom: json['CCOM']?.toString() ?? '',
      cpro: json['CPRO']?.toString() ?? '',
      cmum: json['CMUM']?.toString() ?? '',
      cmun: json['CMUN']?.toString() ?? '',
      nombreEntidad: json['NENTSIC']?.toString() ?? '',
      codigoUnidad: json['CUN']?.toString() ?? '',
      codigoNucleo: json['CNUC']?.toString() ?? '',
      nombre: json['NNUCLE']?.toString() ?? '',
      nombre50: json['NNUCLE50']?.toString() ?? '',
    );
  }

  static Nucleo? getByNombre(
      List<Nucleo> nucleos,
      String nombre,
      ) {
    try {
      return nucleos.firstWhere(
            (n) => n.nombre50.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
