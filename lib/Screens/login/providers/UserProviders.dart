import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class UserLoginState extends StateNotifier<AsyncValue<User?>> {

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final List<String> _scopes = ['email', 'profile'];
  bool _isLoggingOut = false; // Flag para controlar el logout

  UserLoginState() : super(AsyncData(FirebaseAuth.instance.currentUser ?? null)) {
    _init();
  }

  Future<User?> loginMailUser (String mail, String password) async {
    _isLoggingOut = false; // Resetear flag al intentar login
    // set the loading state
    state = const AsyncLoading();
    // sign in and update the state (data or error)
    state = await AsyncValue.guard(() async {
      final userCrendential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: password);
      final user = userCrendential.user;
      // Almacenar último usuario
      if (user != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lastUserEmail', user.email ?? '');
          await prefs.setString('lastUserDisplayName', user.displayName ?? '');
          await prefs.setString('lastUserPhoto', user.photoURL ?? '');
        } catch (e) {
          // no bloquear el login por fallo en prefs
          print('Error saving last user: $e');
        }
      }
      return user;
    });

    // Devolver el usuario resultante (o null)
    return state.value;
  }

  void _init() {
    // Escuchar cambios de FirebaseAuth
    FirebaseAuth.instance.authStateChanges().listen((user) {
      // No actualizar si estamos en proceso de logout
      if (!_isLoggingOut) {
        state = AsyncData(user);
        // Guardar último usuario si aplica
        if (user != null) {
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('lastUserEmail', user.email ?? '');
            prefs.setString('lastUserDisplayName', user.displayName ?? '');
            prefs.setString('lastUserPhoto', user.photoURL ?? '');
          }).catchError((e) => print('Error saving last user on auth change: $e'));
        }
      }
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
    _isLoggingOut = false; // Resetear flag al intentar login
    if (kIsWeb) {
      // En Web → usar Firebase directo
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } else {
      // En móvil → usar authenticate()
      await GoogleSignIn.instance.authenticate();
    }

  }

  Future<void> signOut() async {
    _isLoggingOut = true; // Marcar que estamos cerrando sesión
    
    try {
      // Primero actualizar el estado a null para evitar navegación automática
      state = const AsyncData(null);
      
      // NO limpiar SharedPreferences - mantener usuario recordado para mostrar en login
      // El usuario recordado permite que el LoginScreen muestre "¿No eres tú?"
      // pero NO causa entrada automática al home (eso lo controla AuthWrapper)
      
      // Cerrar sesión de Google (disconnect para eliminar tokens)
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        print("Error al desconectar Google: $e");
        // Intentar signOut si disconnect falla
        try {
          await _googleSignIn.signOut();
        } catch (e2) {
          print("Error al signOut Google: $e2");
        }
      }
      
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      
      print("✅ Sesión cerrada correctamente");
    } catch (e) {
      print("❌ Error al cerrar sesión: $e");
    }
    
    // Asegurar que el estado quede en null
    state = const AsyncData(null);
  }
}

final loginUserProvider = StateNotifierProvider<
    UserLoginState, AsyncValue<User?>>((ref) {
  return UserLoginState();
});