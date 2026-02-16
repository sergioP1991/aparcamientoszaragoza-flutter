import 'package:aparcamientoszaragoza/Models/history.dart';
import 'package:aparcamientoszaragoza/Services/activity_service.dart';
import 'package:aparcamientoszaragoza/Screens/home/providers/HomeProviders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Models/comment.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

// StateNotifier
class CommentsNotifier extends StateNotifier<String?> {
  final Ref ref;

  CommentsNotifier(this.ref) : super(null);

  Future<void> addComment(int idPlaza, Comment? comment) async {
    try {
      state = "LOAD";
      await FirebaseFirestore.instance.collection('comments').add(
          comment!.objectToMap());

      final query = await FirebaseFirestore.instance
          .collection('garaje')
          .where('idPlaza', isEqualTo: idPlaza)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final garajeDoc = query.docs.first.reference;

        await garajeDoc.update({
          'comments': FieldValue.arrayUnion([comment.objectToMap()]),
        });

        await ActivityService.recordEvent(History(
          fecha: DateTime.now(),
          tipo: TipoEvento.nuevo_comentario,
          descripcion: "Nuevo comentario añadido",
          userId: comment.idUsuario,
          meta: "Plaza ID: $idPlaza - Rating: ${comment.ranking}⭐",
        ));

        ref.refresh(fetchHomeProvider(allGarages: true));
        state = "Añadido comentario";
      } else {
        state = "No se encontró el garaje";
      }
    } catch (e) {
      debugPrint("❌ Error al guardar comentario: $e");
      state = "Error al guardar comentario";
    }
  }

  Future<void> deleteComment(int idPlaza, Comment? comment) async {
    try {
      state = "LOAD";
      final query = await FirebaseFirestore.instance
          .collection('garaje')
          .where('idPlaza', isEqualTo: idPlaza)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;

        await docRef.update({
          'comments': FieldValue.arrayRemove([comment?.objectToMap()])
        });

        await ActivityService.recordEvent(History(
          fecha: DateTime.now(),
          tipo: TipoEvento.nuevo_comentario,
          descripcion: "Comentario eliminado",
          userId: comment?.idUsuario,
          meta: "Plaza ID: $idPlaza",
        ));

        ref.refresh(fetchHomeProvider(allGarages: true));
        state = "Comentario eliminado correctamente";
      } else {
        state = "Plaza o garaje no encontrado";
      }
    } catch (e) {
      debugPrint("❌ Error al actualizar comenntarios: $e");
      state = "Error al actualizar comentarios";
    }
  }

  Future<void> updateComment(int idPlaza, Comment oldComment, Comment newComment) async {
    try {
      state = "LOAD";
      
      final query = await FirebaseFirestore.instance
          .collection('garaje')
          .where('idPlaza', isEqualTo: idPlaza)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;

        // Perform both operations in the same update if possible to avoid double refresh
        await docRef.update({
          'comments': FieldValue.arrayRemove([oldComment.objectToMap()])
        });
        await docRef.update({
          'comments': FieldValue.arrayUnion([newComment.objectToMap()])
        });

        await ActivityService.recordEvent(History(
          fecha: DateTime.now(),
          tipo: TipoEvento.nuevo_comentario,
          descripcion: "Comentario actualizado",
          userId: newComment.idUsuario,
          meta: "Plaza ID: $idPlaza",
        ));

        ref.refresh(fetchHomeProvider(allGarages: true));
        state = "Reseña actualizada correctamente";
      } else {
        state = "No se encontró la plaza para actualizar";
      }
    } catch (e) {
      debugPrint("❌ Error al actualizar comentario: $e");
      state = "Error al actualizar la reseña";
    }
  }

  void clearState() {
    state = null;
  }
}

final commentsProvider =
StateNotifierProvider<CommentsNotifier, String?>((ref) {
  return CommentsNotifier(ref);
});