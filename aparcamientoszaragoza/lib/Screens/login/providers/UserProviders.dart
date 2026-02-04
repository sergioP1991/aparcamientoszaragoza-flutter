import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class UserLoginState extends StateNotifier<AsyncValue<User?>> {

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final List<String> _scopes = ['email', 'profile'];

  UserLoginState() : super(AsyncData(FirebaseAuth.instance.currentUser ?? null)) {
    _init();
  }

  Future<User?> loginMailUser (String mail, String password) async {
    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      final userCrendential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: password);
      return userCrendential.user;
    });
  }

  void _init() {
    // Escuchar cambios de FirebaseAuth
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = AsyncData(user);
    });

    // Escuchar eventos de GoogleSignIn
    _googleSignIn.authenticationEvents.listen((event) async {
      final user = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };

      if (user != null) {
        // Obtener autorización para los scopes
        final GoogleSignInClientAuthorization? authorization =
        await user.authorizationClient.authorizationForScopes(_scopes);

        if (authorization != null) {
          // Construir credenciales Firebase
          final credential = GoogleAuthProvider.credential(
            idToken: user.authentication.idToken,
            accessToken: authorization.accessToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);
        }
      } else {
        await FirebaseAuth.instance.signOut();
      }
    }).onError((error) {
      print("Error en autenticación Google: $error");
    });
  }

  Future<void> signIn() async {
    if (kIsWeb) {
      // En Web → usar Firebase directo
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } else {
      // En móvil → usar authenticate()
      await GoogleSignIn.instance.authenticate();
    }

  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}

final loginUserProvider = StateNotifierProvider<
    UserLoginState, AsyncValue<User?>>((ref) {
  return UserLoginState();
});