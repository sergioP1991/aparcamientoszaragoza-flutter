import 'package:aparcamientoszaragoza/Models/garaje.dart';
import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sms_autodetect/sms_autodetect.dart';

part 'UserProviders.g.dart';

class UserLoginState extends StateNotifier<AsyncValue<UserCredential?>> {
  UserLoginState() : super(const AsyncData(null));

  Future<UserCredential?> loginMailUser (String mail, String password) async {

    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      final userCrendential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: password);
      return userCrendential;
    });
  }

  Future<UserCredential?> loginGoogle() async {

    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {

      const webClientId = "342617603309-126hj08escgutrlq6pvjeqtj1rsvm7md.apps.googleusercontent.com";
      final GoogleSignIn googleSignIn = await GoogleSignIn(
        clientId:webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
      return user;

    });

    return null;
  }
}

final loginUserProvider = StateNotifierProvider<
    UserLoginState, AsyncValue<UserCredential?>>((ref) {
  return UserLoginState();
});


//final streamProviderTitle = StreamProvider((ref) => async * {FirebaseRemoteConfig.instance.onConfigUpdated});

@Riverpod(keepAlive: true)
Stream<User?> fetchAuthUser(FetchUserRef ref) async* {
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) async* {
    if (user == null) {
      yield(user);
      print('User is currently signed out!');
    } else {
      yield(user);
      print('User is signed in!');
    }
  });
}

@Riverpod(keepAlive: true)
Stream<User?> fetchUser(FetchUserRef ref) async* {
  FirebaseAuth.instance
      .userChanges()
      .listen((User? user) async* {
    if (user == null) {
      yield(user);
      print('User is currently signed out!');
    } else {
      yield(user);
      print('User is signed in!');
    }
  });
}

@Riverpod(keepAlive: true)
Stream<User?> fetchIdToken(FetchIdTokenRef ref) async* {
  FirebaseAuth.instance
      .idTokenChanges()
      .listen((User? user) async* {
    if (user == null) {
      yield(user);
      print('User is currently signed out!');
    } else {
      yield(user);
      print('User is signed in!');
    }
  });
}