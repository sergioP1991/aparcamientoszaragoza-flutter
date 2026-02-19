import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';

class UserLoginState extends StateNotifier<AsyncValue<User?>> {

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final List<String> _scopes = ['email', 'profile'];
  bool _isLoggingOut = false; // Flag para controlar el logout

  UserLoginState() : super(AsyncData(FirebaseAuth.instance.currentUser ?? null)) {
    _init();
  }

  /// ✅ Login seguro con validación y rate limiting
  Future<User?> loginMailUser(String mail, String password) async {
    _isLoggingOut = false;
    
    // ✅ Validación de entrada
    if (!SecurityService.isValidEmail(mail)) {
      state = AsyncError('Email inválido', StackTrace.current);
      return null;
    }
    
    // ✅ Rate limiting para prevenir brute force
    final canAttempt = await SecurityService.checkRateLimiting(mail);
    if (!canAttempt) {
      state = AsyncError('Demasiados intentos. Intenta más tarde.', StackTrace.current);
      return null;
    }
    
    state = const AsyncLoading();
    
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );
      final user = userCredential.user;
      
      if (user != null) {
        // ✅ Almacenar datos de forma segura
        await _saveUserSecurely(user);
        
        // ✅ Resetear intentos fallidos tras login exitoso
        await SecurityService.resetLoginAttempts(mail);
        
        state = AsyncData(user);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // ✅ No loguear información sensible
      SecurityService.secureLog('Login failed: ${e.code}', level: 'ERROR');
      state = AsyncError(e.message ?? 'Error en login', StackTrace.current);
      return null;
    } catch (e) {
      state = AsyncError('Error inesperado', StackTrace.current);
      return null;
    }
  }

  void _init() {
    // Escuchar cambios de FirebaseAuth
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!_isLoggingOut) {
        state = AsyncData(user);
        // ✅ Almacenar datos de forma segura
        if (user != null) {
          _saveUserSecurely(user);
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
        try {
          // Obtener autorización para los scopes
          final GoogleSignInClientAuthorization? authorization =
              await user.authorizationClient.authorizationForScopes(_scopes);

          if (authorization != null) {
            // Construir credenciales Firebase
            final credential = GoogleAuthProvider.credential(
              idToken: user.authentication.idToken,
              accessToken: authorization.accessToken,
            );

            final result = await FirebaseAuth.instance.signInWithCredential(credential);
            
            // ✅ Guardar datos de forma segura
            if (result.user != null) {
              await _saveUserSecurely(result.user!);
            }
          }
        } catch (e) {
          SecurityService.secureLog('Google auth error: ${e.runtimeType}', level: 'ERROR');
        }
      } else {
        await FirebaseAuth.instance.signOut();
      }
    }).onError((error) {
      SecurityService.secureLog('Google auth stream error: ${error.runtimeType}', level: 'ERROR');
    });
  }

  /// ✅ Google Sign-In
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

  /// ✅ Guardar datos de usuario para recordar (email, displayName, photo)
  /// Nota: Estos datos son públicos, no sensibles, por lo que SharedPreferences es seguro
  Future<void> _saveUserSecurely(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastUserEmail', user.email ?? '');
      await prefs.setString('lastUserDisplayName', user.displayName ?? '');
      await prefs.setString('lastUserPhoto', user.photoURL ?? '');
      SecurityService.secureLog('User data saved for remember me', level: 'DEBUG');
    } catch (e) {
      SecurityService.secureLog('Error saving user data: ${e.runtimeType}', level: 'ERROR');
    }
  }

  Future<void> signOut() async {
    _isLoggingOut = true; // Marcar que estamos cerrando sesión
    
    try {
      // Primero actualizar el estado a null para evitar navegación automática
      state = const AsyncData(null);
      
      // ✅ Limpiar datos sensibles del almacenamiento seguro
      await SecurityService.clearAllSecureData();
      
      // NO limpiar SharedPreferences - mantener usuario recordado para mostrar en login
      // El usuario recordado permite que el LoginScreen muestre "¿No eres tú?"
      // pero NO causa entrada automática al home (eso lo controla AuthWrapper)
      
      // Cerrar sesión de Google (disconnect para eliminar tokens)
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        SecurityService.secureLog('Error disconnecting Google: ${e.runtimeType}', level: 'ERROR');
        // Intentar signOut si disconnect falla
        try {
          await _googleSignIn.signOut();
        } catch (e2) {
          SecurityService.secureLog('Error in signOut fallback: ${e2.runtimeType}', level: 'ERROR');
        }
      }
      
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      
      SecurityService.secureLog('Session closed successfully', level: 'DEBUG');
    } catch (e) {
      SecurityService.secureLog('Error signing out: ${e.runtimeType}', level: 'ERROR');
    }
    
    // Asegurar que el estado quede en null
    state = const AsyncData(null);
  }
}

final loginUserProvider = StateNotifierProvider<
    UserLoginState, AsyncValue<User?>>((ref) {
  return UserLoginState();
});