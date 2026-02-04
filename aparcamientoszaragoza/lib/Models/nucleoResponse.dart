import 'nucleo.dart';

class NucleosResponse {
  final int currentPage;
  final String updateDate;
  final int size;
  final List<Nucleo> data;

  NucleosResponse({
    required this.currentPage,
    required this.updateDate,
    required this.size,
    required this.data,
  });

  factory NucleosResponse.fromJson(Map<String, dynamic> json) {
    return NucleosResponse(
      currentPage: json['current_page'] ?? 0,
      updateDate: json['update_date']?.toString() ?? '',
      size: json['size'] ?? 0,
      data: (json['data'] as List)
          .map((e) => Nucleo.fromJson(e))
          .toList(),
    );
  }
}
