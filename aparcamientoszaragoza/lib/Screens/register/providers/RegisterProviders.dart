import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'RegisterProviders.g.dart';

class UserRegisterState extends StateNotifier<AsyncValue<UserCredential?>> {
  UserRegisterState() : super(const AsyncData(null));

  Future<UserCredential?> register(String mail, String password ) async {

    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mail,
        password: password
      );
    });
    return null;
  }
}

final registerUserProvider = StateNotifierProvider<
    UserRegisterState, AsyncValue<UserCredential?>>((ref) {
  return UserRegisterState();
});

@Riverpod(keepAlive: true)
Future<UserCredential?> fetchRegisterUser(FetchRegisterUserRef ref,
                                          String? mail,
                                          String? password) async {

  UserCredential userCredential;

  if (mail == null || password == null) {
    return null;
  }

  try {
    userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: mail,
      password: password
    );

    return userCredential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
      return Future.error(e);
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
      return Future.error(e);
    }
  } catch (e) {
    print(e);
    return Future.error(e);
  }
  return null;
}
