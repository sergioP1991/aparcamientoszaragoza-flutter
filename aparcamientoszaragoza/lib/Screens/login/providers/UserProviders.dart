import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'UserProviders.g.dart';

final UserCredential? user = null;
final int requestUser = 0;

final String? token = null;

@Riverpod(keepAlive: true)
UserCredential? userState (UserStateRef ref)=> user;

@Riverpod(keepAlive: true)
final reqUserProvider = StateProvider<int>((ref) {
  return requestUser;
});

@Riverpod(keepAlive: true)
Future<UserCredential?> signInWithGoogle(SignInWithGoogleRef ref) async {
  try {
    const webClientId = "342617603309-126hj08escgutrlq6pvjeqtj1rsvm7md.apps.googleusercontent.com";
    final GoogleSignIn googleSignIn = await GoogleSignIn(
        clientId:webClientId,
    );

    final googleUser = await googleSignIn!.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
    return user;
    //ref.read(userProvider.notifier).state = user;
  } on Exception catch (e) {
    // TODO
    print('exception->$e');
    return null;
  }
}

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
