import 'municipio.dart';

class MunicipiosResponse {
  final int currentPage;
  final String updateDate;
  final int size;
  final List<Municipio> data;

  MunicipiosResponse({
    required this.currentPage,
    required this.updateDate,
    required this.size,
    required this.data,
  });

  factory MunicipiosResponse.fromJson(Map<String, dynamic> json) {
    return MunicipiosResponse(
      currentPage: json['current_page'],
      updateDate: json['update_date'],
      size: json['size'],
      data: (json['data'] as List)
          .map((e) => Municipio.fromJson(e))
          .toList(),
    );
  }
}
