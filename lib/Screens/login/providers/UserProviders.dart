import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';
import 'package:aparcamientoszaragoza/Services/ReAuthService.dart';

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
    SecurityService.secureLog('🔐 [USER PROVIDER] loginMailUser() called for: ${mail.substring(0, mail.length ~/ 2)}***', level: 'DEBUG');
    
    try {
      SecurityService.secureLog('🔐 [USER PROVIDER] Attempting Firebase Auth with email...', level: 'DEBUG');
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );
      final user = userCredential.user;
      
      if (user != null) {
        SecurityService.secureLog('✅ [USER PROVIDER] Firebase Auth successful, user UID: ${user.uid.substring(0, 8)}***', level: 'DEBUG');
        
        // ✅ Almacenar datos de forma segura + guardar credenciales encriptadas
        SecurityService.secureLog('💾 [USER PROVIDER] Calling _saveUserSecurely() to save remembered user...', level: 'DEBUG');
        await _saveUserSecurely(user, mail, password);
        SecurityService.secureLog('✅ [USER PROVIDER] User data saved successfully', level: 'DEBUG');
        
        // ✅ Resetear intentos fallidos tras login exitoso
        await SecurityService.resetLoginAttempts(mail);
        SecurityService.secureLog('✅ [USER PROVIDER] Login attempts reset', level: 'DEBUG');
        
        state = AsyncData(user);
        SecurityService.secureLog('🎉 [USER PROVIDER] Login complete, state updated to AsyncData', level: 'DEBUG');
      } else {
        SecurityService.secureLog('❌ [USER PROVIDER] Firebase Auth returned null user', level: 'ERROR');
        state = AsyncError('Auth error: user is null', StackTrace.current);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // ✅ No loguear información sensible
      SecurityService.secureLog('❌ [USER PROVIDER] FirebaseAuthException: code=${e.code}', level: 'ERROR');
      state = AsyncError(e.message ?? 'Error en login', StackTrace.current);
      return null;
    } catch (e) {
      SecurityService.secureLog('❌ [USER PROVIDER] Unexpected error: ${e.runtimeType}', level: 'ERROR');
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
  /// + Guardar credenciales encriptadas para auto-login
  /// + Generar session token para auto-login en siguientes X días
  /// Nota: Estos datos son públicos, no sensibles, por lo que SharedPreferences es seguro
  Future<void> _saveUserSecurely(User user, [String? email, String? password]) async {
    try {
      SecurityService.secureLog('💾 [LOGIN] Saving user data to SharedPreferences...', level: 'DEBUG');
      SecurityService.secureLog('📋 [LOGIN] Starting with user: email=${user.email}, displayName=${user.displayName}, photoURL=${user.photoURL}', level: 'DEBUG');
      
      final prefs = await SharedPreferences.getInstance();
      SecurityService.secureLog('✅ [LOGIN] SharedPreferences instance obtained', level: 'DEBUG');
      
      // ✅ Guardar email
      SecurityService.secureLog('💾 [LOGIN] Step 1: Saving email...', level: 'DEBUG');
      await prefs.setString('lastUserEmail', user.email ?? '');
      SecurityService.secureLog('✅ [LOGIN] Email saved: "${user.email ?? ''}"', level: 'DEBUG');
      
      // ✅ Guardar displayName
      SecurityService.secureLog('💾 [LOGIN] Step 2: Saving displayName...', level: 'DEBUG');
      await prefs.setString('lastUserDisplayName', user.displayName ?? '');
      SecurityService.secureLog('✅ [LOGIN] DisplayName saved: "${user.displayName ?? ''}"', level: 'DEBUG');
      
      // ✅ Guardar photo
      SecurityService.secureLog('💾 [LOGIN] Step 3: Saving photoURL...', level: 'DEBUG');
      await prefs.setString('lastUserPhoto', user.photoURL ?? '');
      SecurityService.secureLog('✅ [LOGIN] Photo saved: "${user.photoURL ?? ''}"', level: 'DEBUG');
      
      SecurityService.secureLog(
        '✅ [LOGIN] All SharedPreferences keys saved successfully',
        level: 'DEBUG'
      );
      
      // ✅ Verify the data was actually saved (CRITICAL FOR DEBUGGING)
      SecurityService.secureLog('🔍 [LOGIN] Starting verification of saved data...', level: 'DEBUG');
      final savedEmail = prefs.getString('lastUserEmail') ?? '';
      final savedDisplayName = prefs.getString('lastUserDisplayName') ?? '';
      final savedPhoto = prefs.getString('lastUserPhoto') ?? '';
      
      SecurityService.secureLog(
        '🔍 [LOGIN] Saved lastUserEmail: "$savedEmail" (length=${savedEmail.length})',
        level: 'DEBUG'
      );
      SecurityService.secureLog(
        '🔍 [LOGIN] Saved lastUserDisplayName: "$savedDisplayName" (length=${savedDisplayName.length})',
        level: 'DEBUG'
      );
      SecurityService.secureLog(
        '🔍 [LOGIN] Saved lastUserPhoto: "$savedPhoto" (length=${savedPhoto.length})',
        level: 'DEBUG'
      );
      
      // ✅ CRITICAL CHECK: Si algo está vacío cuando no debería, loguear error
      if (user.email != null && user.email!.isNotEmpty && savedEmail.isEmpty) {
        SecurityService.secureLog(
          '❌ [LOGIN] CRITICAL: Email was not saved! Original: "${user.email}", Saved: "$savedEmail"',
          level: 'ERROR'
        );
      }
      
      SecurityService.secureLog(
        '🔍 [LOGIN] Verification complete - Saved and read back: email=$savedEmail, displayName=$savedDisplayName, photo=${savedPhoto.isEmpty ? 'empty' : 'loaded'}',
        level: 'DEBUG'
      );
      
      // ✅ Guardar credenciales encriptadas en SecureStorage para permitir auto-login
      if (email != null && password != null) {
        SecurityService.secureLog('💾 [LOGIN] Saving encrypted credentials to SecureStorage...', level: 'DEBUG');
        await SecurityService.saveSecureData('cached_email', email);
        await SecurityService.saveSecureData('cached_password', password);
        SecurityService.secureLog('✅ [LOGIN] Saved encrypted credentials to SecureStorage', level: 'DEBUG');
      }
      
      // ✅ Generar session token para permitir auto-login en los próximos 7 días
      if (user.email != null) {
        SecurityService.secureLog('💾 [LOGIN] Generating session token...', level: 'DEBUG');
        final reAuthService = ReAuthService();
        await reAuthService.generateSessionToken(user.email!);
        SecurityService.secureLog('✅ [LOGIN] Session token generated for ${user.email}', level: 'DEBUG');
      }
      
      SecurityService.secureLog('🎉 [LOGIN] All user data saved successfully', level: 'DEBUG');
    } catch (e, stackTrace) {
      SecurityService.secureLog(
        '❌ [LOGIN] CRITICAL ERROR saving user data: ${e.runtimeType}\nMessage: $e\nStackTrace: $stackTrace',
        level: 'ERROR'
      );
    }
  }

  Future<void> signOut() async {
    _isLoggingOut = true; // Marcar que estamos cerrando sesión
    
    try {
      SecurityService.secureLog('🚪 [LOGOUT] Starting logout process...', level: 'DEBUG');
      
      // Primero actualizar el estado a null para evitar navegación automática
      state = const AsyncData(null);
      SecurityService.secureLog('✅ [LOGOUT] State set to null', level: 'DEBUG');
      
      // ✅ Limpiar datos sensibles del almacenamiento seguro
      await SecurityService.clearAllSecureData();
      SecurityService.secureLog('✅ [LOGOUT] Cleared encrypted data from SecureStorage', level: 'DEBUG');
      
      // ✅ Invalidar session token para forzar re-login en siguiente acceso
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('lastUserEmail');
      if (email != null) {
        final reAuthService = ReAuthService();
        await reAuthService.invalidateSessionToken(email);
        SecurityService.secureLog('✅ [LOGOUT] Session token invalidated for: $email', level: 'DEBUG');
      }
      
      // NO limpiar SharedPreferences - mantener usuario recordado para mostrar en login
      // El usuario recordado permite que LoginScreen muestre "¿No eres tú?"
      // pero el session token invalidado fuerza re-entrada de contraseña
      SecurityService.secureLog('✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)', level: 'DEBUG');
      
      // Cerrar sesión de Google (disconnect para eliminar tokens)
      try {
        await _googleSignIn.disconnect();
        SecurityService.secureLog('✅ [LOGOUT] Google SignIn disconnected', level: 'DEBUG');
      } catch (e) {
        SecurityService.secureLog('⚠️ [LOGOUT] Error disconnecting Google: ${e.runtimeType}', level: 'ERROR');
        // Intentar signOut si disconnect falla
        try {
          await _googleSignIn.signOut();
          SecurityService.secureLog('✅ [LOGOUT] Google SignIn fallback signOut succeeded', level: 'DEBUG');
        } catch (e2) {
          SecurityService.secureLog('⚠️ [LOGOUT] Error in signOut fallback: ${e2.runtimeType}', level: 'ERROR');
        }
      }
      
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      SecurityService.secureLog('✅ [LOGOUT] Firebase session closed', level: 'DEBUG');
      
      SecurityService.secureLog('🎉 [LOGOUT] Session closed successfully', level: 'DEBUG');
    } catch (e) {
      SecurityService.secureLog('❌ [LOGOUT] Error signing out: ${e.runtimeType} - $e', level: 'ERROR');
    }
    
    // Asegurar que el estado quede en null
    state = const AsyncData(null);
  }
}

final loginUserProvider = StateNotifierProvider<
    UserLoginState, AsyncValue<User?>>((ref) {
  return UserLoginState();
});