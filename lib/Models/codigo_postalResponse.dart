
import 'codigo_postal.dart';

class CodigosPostalesResponse {
  final int currentPage;
  final String updateDate;
  final int size;
  final List<CodigoPostalApp> data;

  CodigosPostalesResponse({
    required this.currentPage,
    required this.updateDate,
    required this.size,
    required this.data,
  });

  factory CodigosPostalesResponse.fromJson(Map<String, dynamic> json) {
    return CodigosPostalesResponse(
      currentPage: json['current_page'] ?? 0,
      updateDate: json['update_date']?.toString() ?? '',
      size: json['size'] ?? 0,
      data: (json['data'] as List)
          .map((e) => CodigoPostalApp.fromJson(e))
          .toList(),
    );
  }
}
