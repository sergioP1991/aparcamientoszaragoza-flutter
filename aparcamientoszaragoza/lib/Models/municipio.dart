class Municipio {
  final String ccom;
  final String cpro;
  final String cmun;
  final String cmum;
  final String nombre;
  final String nombreAlternativo;
  final int? entidadesColectivas;
  final int poblaciones;
  final String nuts2;
  final String nuts3;
  final String mir;

  Municipio({
    required this.ccom,
    required this.cpro,
    required this.cmun,
    required this.cmum,
    required this.nombre,
    required this.nombreAlternativo,
    required this.entidadesColectivas,
    required this.poblaciones,
    required this.nuts2,
    required this.nuts3,
    required this.mir,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      ccom: json['CCOM'] as String,
      cpro: json['CPRO'] as String,
      cmun: json['CMUN'] as String,
      cmum: json['CMUM'] as String,
      nombre: json['DMUN50'] as String,
      nombreAlternativo: json['ALTERNATIVO_DMUN50'] as String,
      entidadesColectivas: json['N_ENTIDADES_COLECTIVAS'] as int?,
      poblaciones: json['N_POBLACIONES'] as int,
      nuts2: json['NUTS2'] as String,
      nuts3: json['NUTS3'] as String,
      mir: json['MIR'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CCOM': ccom,
      'CPRO': cpro,
      'CMUN': cmun,
      'CMUM': cmum,
      'DMUN50': nombre,
      'ALTERNATIVO_DMUN50': nombreAlternativo,
      'N_ENTIDADES_COLECTIVAS': entidadesColectivas,
      'N_POBLACIONES': poblaciones,
      'NUTS2': nuts2,
      'NUTS3': nuts3,
      'MIR': mir,
    };
  }

  static Municipio? getByNombre(
      List<Municipio> municipios,
      String nombre,
      ) {
    try {
      return municipios.firstWhere(
            (m) => m.nombre.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
