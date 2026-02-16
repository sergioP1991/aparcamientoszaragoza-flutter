import 'poblacion.dart';

class PoblacionesResponse {
  final int currentPage;
  final String updateDate;
  final int size;
  final List<Poblacion> data;

  PoblacionesResponse({
    required this.currentPage,
    required this.updateDate,
    required this.size,
    required this.data,
  });

  factory PoblacionesResponse.fromJson(Map<String, dynamic> json) {
    return PoblacionesResponse(
      currentPage: json['current_page'],
      updateDate: json['update_date'],
      size: json['size'],
      data: (json['data'] as List)
          .map((e) => Poblacion.fromJson(e))
          .toList(),
    );
  }
}
