import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


class ForgetPasswordState extends StateNotifier<AsyncValue<String?>> {
  ForgetPasswordState() : super(const AsyncData(null));

  Future<bool?> forgetPassword(String email) async {
    // set the loading state
    state = const AsyncLoading();

    if (email.isEmpty) {
      state = AsyncError("Por favor introduce un correo", StackTrace.empty);
      return false;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      state = const AsyncData('Se ha enviado un correo para restablecer tu contraseña.');
    } on FirebaseAuthException catch (e) {
      print(e.message);
      state =  AsyncError(e?.message ?? "", e?.stackTrace ?? StackTrace.empty);
    }
    return true;
  }
}

@riverpod
final forgetPasswordProvider = StateNotifierProvider<ForgetPasswordState, AsyncValue<String?>>((ref) {
  return ForgetPasswordState();
});

