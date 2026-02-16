import 'package:aparcamientoszaragoza/Models/history.dart';
import 'package:aparcamientoszaragoza/Models/promocion.dart';
import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:aparcamientoszaragoza/Services/activity_service.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class UserRegisterState extends StateNotifier<AsyncValue<UserCredential?>> {
  UserRegisterState() : super(const AsyncData(null));

  Future<UserCredential?> register(UserRegister user) async {

    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.mail,
        password: user.password
      );

      userCredential.user?.sendEmailVerification();
      userCredential.user?.updateDisplayName(user.username);
      userCredential.user?.updatePhotoURL(user.urlProfile);

      await ActivityService.recordEvent(History(
        fecha: DateTime.now(),
        tipo: TipoEvento.registro_usuario,
        descripcion: "¡Bienvenido a Aparcamientos Zaragoza!",
        userId: userCredential.user?.uid,
        meta: "Registro completado con éxito",
      ));

      return userCredential;
    });
    return null;
  }
}

final registerUserProvider = StateNotifierProvider<
    UserRegisterState, AsyncValue<UserCredential?>>((ref) {
  return UserRegisterState();
});

class RegisterMailState extends StateNotifier<AsyncValue<bool>> {
  RegisterMailState() : super(const AsyncData(false));

  Future<bool> sendRegisterMail(String mail, String titulo, String? text) async {
    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      List<String> listado = mail.split(",");
      for(String mail in listado) {
        try {
          await FirebaseFirestore.instance.collection('mails').add({
            'contenido': text,
            'titulo': titulo,
            'mail': mail.trim(),
            "esHtml": true
          });
          print('Mail Enviado exitosamente');
        } catch (e) {
          print('Fallo al envio: $e');
        }
      }
      return true;
    });
    return true;
  }
}

final mailRegisterSendProvider = StateNotifierProvider<
    RegisterMailState, AsyncValue<bool>>((ref) {
  return RegisterMailState();
});

class CodePromotionState extends StateNotifier<AsyncValue<bool>> {
  final Ref ref;
  
  CodePromotionState(this.ref) : super(const AsyncData(false));

  Future<Promocion?> newPromocion(String? codigo, String? idUser, DateTime validate) async {
    // Check if user has promotions enabled
    final settings = ref.read(settingsProvider);
    if (!settings.offersPromotions) {
      print('User has promotions disabled - skipping promotion creation');
      state = const AsyncData(false);
      return null;
    }

    // set the loading state
    state = const AsyncLoading();

    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      try {
        await FirebaseFirestore.instance.collection('promociones').add({
          'codigo': codigo,
          'idUser': idUser,
          'usada': false,
          'tipoDescuento': '%',
          'cantidad' :  10,
          'validate' : Timestamp.fromDate(validate),
        });
        print('promocion registrada con éxito');
      } catch (e) {
        print('Error al registrar la promocion: $e');
      }

      return true;
    });
  }
}

final codePromotionProvider = StateNotifierProvider<
    CodePromotionState,
    AsyncValue<bool>>((ref) {
  return CodePromotionState(ref);
});
