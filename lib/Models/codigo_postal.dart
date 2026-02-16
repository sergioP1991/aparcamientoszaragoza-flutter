class CodigoPostalApp {
  final String ccom;
  final String cpro;
  final String cmum;
  final String cmun;
  final String cnuc;
  final String cun;
  final String codigoPostal;

  CodigoPostalApp({
    required this.ccom,
    required this.cpro,
    required this.cmum,
    required this.cmun,
    required this.cnuc,
    required this.cun,
    required this.codigoPostal,
  });

  factory CodigoPostalApp.fromJson(Map<String, dynamic> json) {
    return CodigoPostalApp(
      ccom: json['CCOM']?.toString() ?? '',
      cpro: json['CPRO']?.toString() ?? '',
      cmum: json['CMUM']?.toString() ?? '',
      cmun: json['CMUN']?.toString() ?? '',
      cnuc: json['CNUC']?.toString() ?? '',
      cun: json['CUN']?.toString() ?? '',
      codigoPostal: json['CPOS']?.toString() ?? '',
    );
  }

  static CodigoPostalApp? getByCodigo(
      List<CodigoPostalApp> codigos,
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
