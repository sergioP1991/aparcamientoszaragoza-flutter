import 'comunidad.dart';

class ComunidadesResponse {
  final int currentPage;
  final String updateDate;
  final int size;
  final List<Comunidad> data;

  ComunidadesResponse({
    required this.currentPage,
    required this.updateDate,
    required this.size,
    required this.data,
  });

  factory ComunidadesResponse.fromJson(Map<String, dynamic> json) {
    return ComunidadesResponse(
      currentPage: json['current_page'],
      updateDate: json['update_date'],
      size: json['size'],
      data: (json['data'] as List)
          .map((e) => Comunidad.fromJson(e))
          .toList(),
    );
  }
}
