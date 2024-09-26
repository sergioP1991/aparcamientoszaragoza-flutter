import 'package:aparcamientoszaragoza/Screens/login/providers/UserProviders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'RegisterProviders.g.dart';

@Riverpod(keepAlive: true)
Future<UserCredential?> fetchRegisterUser(FetchRegisterUserRef ref,
      String mail,
      String password) async {
  UserCredential userCredential;
  try {
    userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: mail,
      password: password
    );

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }
  return null;
}
