class CodigoPostal {
  final String ccom;
  final String cpro;
  final String cmum;
  final String cmun;
  final String cnuc;
  final String cun;
  final String codigoPostal;

  CodigoPostal({
    required this.ccom,
    required this.cpro,
    required this.cmum,
    required this.cmun,
    required this.cnuc,
    required this.cun,
    required this.codigoPostal,
  });

  factory CodigoPostal.fromJson(Map<String, dynamic> json) {
    return CodigoPostal(
      ccom: json['CCOM']?.toString() ?? '',
      cpro: json['CPRO']?.toString() ?? '',
      cmum: json['CMUM']?.toString() ?? '',
      cmun: json['CMUN']?.toString() ?? '',
      cnuc: json['CNUC']?.toString() ?? '',
      cun: json['CUN']?.toString() ?? '',
      codigoPostal: json['CPOS']?.toString() ?? '',
    );
  }

  static CodigoPostal? getByCodigo(
      List<CodigoPostal> codigos,
      String codigoPostal,
      ) {
    try {
      return codigos.firstWhere(
            (c) => c.codigoPostal == codigoPostal,
      );
    } catch (_) {
      return null;
    }
  }
}
