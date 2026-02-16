import 'provincia.dart';

class ProvinciasResponse {
  final int currentPage;
  final String updateDate;
  final int size;
  final List<Provincia> data;

  ProvinciasResponse({
    required this.currentPage,
    required this.updateDate,
    required this.size,
    required this.data,
  });

  factory ProvinciasResponse.fromJson(Map<String, dynamic> json) {
    return ProvinciasResponse(
      currentPage: json['current_page'] ?? 0,
      updateDate: json['update_date']?.toString() ?? '',
      size: json['size'] ?? 0,
      data: (json['data'] as List)
          .map((e) => Provincia.fromJson(e))
          .toList(),
    );
  }
}
