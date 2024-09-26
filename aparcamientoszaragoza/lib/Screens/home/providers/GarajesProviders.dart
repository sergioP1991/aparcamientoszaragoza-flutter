
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../Models/garaje.dart';
import '../../../Values/app_models.dart';

part 'GarajesProviders.g.dart';

final List<Garaje> garajesList = List<Garaje>.empty();

@Riverpod(keepAlive: true)
final garajeListProvider = StateProvider<List<Garaje>>((ref) {
  return garajesList;
});

@Riverpod(keepAlive: true)
Future<List<Garaje>> fetchGaraje(FetchGarajeRef ref) async {

  final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('garaje').get();

  List<Garaje> listResult = snapshot.docs.map<Garaje>((doc) => Garaje.fromFirestore(doc)).toList();
  ref.read(garajeListProvider.notifier).state = listResult;

  return listResult;

}