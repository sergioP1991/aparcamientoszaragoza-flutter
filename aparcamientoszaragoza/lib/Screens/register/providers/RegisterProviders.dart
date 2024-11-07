import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sms_autodetect/sms_autodetect.dart';

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

      return userCredential;
    });
    return null;
  }
}

final registerUserProvider = StateNotifierProvider<
    UserRegisterState, AsyncValue<UserCredential?>>((ref) {
  return UserRegisterState();
});

