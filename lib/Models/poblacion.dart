class Poblacion {
  final String ccom;
  final String cpro;
  final String cmun;
  final String cmum;
  final String cpob;
  final String nombreCorto;
  final String nombreOficial;
  final String entidadColectiva;

  Poblacion({
    required this.ccom,
    required this.cpro,
    required this.cmun,
    required this.cmum,
    required this.cpob,
    required this.nombreCorto,
    required this.nombreOficial,
    required this.entidadColectiva,
  });

  factory Poblacion.fromJson(Map<String, dynamic> json) {
    return Poblacion(
      ccom: json['CCOM'] as String,
      cpro: json['CPRO'] as String,
      cmun: json['CMUN'] as String,
      cmum: json['CMUM'] as String,
      cpob: json['CPOB'] as String,
      nombreCorto: json['NENTSIC'] as String,
      nombreOficial: json['NENTSI50'] as String,
      entidadColectiva: json['NENTCO'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CCOM': ccom,
      'CPRO': cpro,
      'CMUN': cmun,
      'CMUM': cmum,
      'CPOB': cpob,
      'NENTSIC': nombreCorto,
      'NENTSI50': nombreOficial,
      'NENTCO': entidadColectiva,
    };
  }

  static Poblacion? getByNombre(
      List<Poblacion> poblaciones,
      String nombre,
      ) {
    try {
      return poblaciones.firstWhere(
            (p) => p.nombreOficial.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
