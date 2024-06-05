
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../Models/garaje.dart';
import '../../../Values/app_models.dart';

part 'GarajesProviders.g.dart';

@riverpod
Future<List<Garaje>> fetchGaraje(FetchGarajeRef ref) async {
  await Future.delayed(const Duration(seconds: 7));
  //return Future.error("Lista no disponible");
  return AppModels.defaultGarajes;
}