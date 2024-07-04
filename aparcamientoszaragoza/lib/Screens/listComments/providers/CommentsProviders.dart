
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../Models/comment.dart';
import '../../../Models/garaje.dart';
import '../../../Values/app_models.dart';

part 'CommentsProviders.g.dart';

@riverpod
Future<List<Comment>> fetchComments(FetchCommentsRef ref) async {
  await Future.delayed(const Duration(seconds: 7));
  //return Future.error("Lista no disponible");
  return AppModels.defaultComments;
}