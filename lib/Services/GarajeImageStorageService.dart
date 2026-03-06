import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para gestionar la carga de múltiples imágenes de plazas a Firebase Storage
class GarajeImageStorageService {
  static final _storage = FirebaseStorage.instance;

  /// Sube una única imagen a Firebase Storage
  /// Retorna la URL de descarga pública
  static Future<String?> uploadImage({
    required String plazaId,
    required dynamic imageSource,  // XFile o File
    int imageIndex = 0,
  }) async {
    try {
      // Crear referencia de storage: garajes/{plazaId}/imagen_{imageIndex}.jpg
      final fileName = 'imagen_$imageIndex.jpg';
      final ref = _storage.ref('garajes/$plazaId/$fileName');

      // Subir archivo
      if (kIsWeb) {
        // En web, imageSource es XFile
        if (imageSource is XFile) {
          final bytes = await imageSource.readAsBytes();
          final task = await ref.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final url = await task.ref.getDownloadURL();
          debugPrint('✅ Imagen subida (web): $url');
          return url;
        }
      } else {
        // En mobile, imageSource es File o XFile
        File file;
        if (imageSource is XFile) {
          file = File(imageSource.path);
        } else {
          file = imageSource as File;
        }

        if (!await file.exists()) {
          debugPrint('❌ Archivo no existe: ${file.path}');
          return null;
        }

        final task = await ref.putFile(file);
        final url = await task.ref.getDownloadURL();
        debugPrint('✅ Imagen subida (mobile): $url');
        return url;
      }
    } catch (e) {
      debugPrint('❌ Error al subir imagen: $e');
      return null;
    }
    return null;
  }

  /// Sube múltiples imágenes y retorna lista de URLs
  static Future<List<String>> uploadMultipleImages({
    required String plazaId,
    required List<dynamic> imageSources,  // List<XFile> o List<File>
  }) async {
    final urls = <String>[];

    for (int i = 0; i < imageSources.length; i++) {
      final url = await uploadImage(
        plazaId: plazaId,
        imageSource: imageSources[i],
        imageIndex: i,
      );
      if (url != null) {
        urls.add(url);
      }
    }

    debugPrint('📸 Uploaded ${urls.length}/${imageSources.length} images');
    return urls;
  }

  /// Elimina una imagen de Firebase Storage
  static Future<bool> deleteImage({
    required String plazaId,
    required int imageIndex,
  }) async {
    try {
      final fileName = 'imagen_$imageIndex.jpg';
      final ref = _storage.ref('garajes/$plazaId/$fileName');
      await ref.delete();
      debugPrint('✅ Imagen eliminada: garajes/$plazaId/$fileName');
      return true;
    } catch (e) {
      debugPrint('❌ Error al eliminar imagen: $e');
      return false;
    }
  }

  /// Elimina todas las imágenes de una plaza
  static Future<void> deleteAllImages(String plazaId) async {
    try {
      final ref = _storage.ref('garajes/$plazaId');
      final result = await ref.listAll();
      for (var item in result.items) {
        await item.delete();
      }
      debugPrint('✅ Todas las imágenes de $plazaId eliminadas');
    } catch (e) {
      debugPrint('❌ Error al eliminar imágenes: $e');
    }
  }
}
