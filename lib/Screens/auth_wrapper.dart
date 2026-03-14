import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aparcamientoszaragoza/Screens/welcome_screen.dart';
import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';
import 'package:aparcamientoszaragoza/Services/ReAuthService.dart';
import 'package:aparcamientoszaragoza/Screens/login/providers/UserProviders.dart';

/// Pantalla que decide qué mostrar basándose en el estado de autenticación de Firebase
/// - Home: Si ya hay una sesión activa en Firebase Auth (usuario logueado)
/// - Login: Si no hay sesión pero hay usuario recordado (para poder cambiar o continuar)
/// - Welcome: Si no hay sesión ni usuario recordado
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  late Future<Widget> _authState;

  @override
  void initState() {
    super.initState();
    _authState = _checkAuthState();
  }

  @override
  void didUpdateWidget(AuthWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check auth state if widget updated
    _authState = _checkAuthState();
  }

  /// ✅ Verificar el estado de autenticación esperando a que FirebaseAuth restaure la sesión
  /// En web, FirebaseAuth necesita tiempo para restaurar la sesión desde localStorage
  /// Orden de verificación:
  /// 1. ¿Hay sesión activa en Firebase Auth? → Home (PRIORITARIO)
  /// 2. ¿Hay usuario recordado? → Login (para recordar usuario + opción de cambio)
  /// 3. Nada de lo anterior? → Welcome
  /// 
  /// 🔑 IMPORTANTE: Firebase Auth persiste automáticamente en dispositivos/navegadores
  /// No borramos SharedPreferences al cerrar app, solo en logout explícito
  Future<Widget> _checkAuthState() async {
    try {
      SecurityService.secureLog('🔐 [AUTH WRAPPER] Starting auth state check...', level: 'DEBUG');
      
      // 🔑 CRÍTICO para web: usar authStateChanges() para esperar a que Firebase restaure la sesión
      // En web, currentUser puede ser null inicialmente mientras se restaura desde localStorage
      // Usamos .first con timeout para dar tiempo a Firebase (pero no esperar infinito)
      User? authUser;
      
      try {
        SecurityService.secureLog('⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session...', level: 'DEBUG');
        
        authUser = await FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(
              const Duration(seconds: 8), // Aumentado a 8 segundos para web
              onTimeout: () {
                SecurityService.secureLog('⏱️ [AUTH WRAPPER] Firebase restore timeout reached', level: 'DEBUG');
                return FirebaseAuth.instance.currentUser;
              },
            );
      } catch (e) {
        // Si existe error en el stream, usar currentUser como fallback
        SecurityService.secureLog('⚠️ [AUTH WRAPPER] Error waiting for authStateChanges: ${e.runtimeType}', level: 'ERROR');
        authUser = FirebaseAuth.instance.currentUser;
      }
      
      if (authUser != null && authUser.email != null) {
        // ✅ CASO 1: Hay sesión activa en Firebase → ir al Home directamente
        // Esto es lo normal: app se cierra y reabre, Firebase restauró la sesión automáticamente
        SecurityService.secureLog(
          '✅ [AUTH WRAPPER] CASE 1: Active Firebase session found for ${authUser.email} → Showing Home',
          level: 'DEBUG'
        );
        return HomePage();
      }
      
      SecurityService.secureLog('ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences...', level: 'DEBUG');
      
      // Si no hay sesión en Firebase, verificar si hay usuario recordado
      final prefs = await SharedPreferences.getInstance();
      final lastUserEmail = prefs.getString('lastUserEmail');
      final lastUserDisplayName = prefs.getString('lastUserDisplayName');
      final lastUserPhoto = prefs.getString('lastUserPhoto');
      
      SecurityService.secureLog(
        '📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=$lastUserEmail, displayName=$lastUserDisplayName, photo=$lastUserPhoto',
        level: 'DEBUG'
      );
      
      if (lastUserEmail != null && lastUserEmail.isNotEmpty) {
        // ✅ CASO 2: Hay usuario recordado → mostrar LoginPage
        // Esto ocurre cuando:
        // - Usuario hizo logout explícito (pero "recordar" fue marcado)
        // - Usuario login pero luego cerró sesión en Firebase
        // - Session token expiró (después de 7 días)
        SecurityService.secureLog(
          '✅ [AUTH WRAPPER] CASE 2: Remembered user found: $lastUserEmail → Showing LoginPage',
          level: 'DEBUG'
        );
        return LoginPage();
      }
      
      // CASO 3: No hay sesión ni usuario recordado - mostrar Welcome
      SecurityService.secureLog(
        '🌟 [AUTH WRAPPER] CASE 3: No active session and no remembered user → Showing WelcomeScreen',
        level: 'DEBUG'
      );
      return WelcomeScreen();
    } catch (e) {
      // En caso de error, mostrar WelcomeScreen como fallback seguro
      SecurityService.secureLog(
        '❌ [AUTH WRAPPER] Unexpected error during auth check: $e',
        level: 'ERROR'
      );
      return WelcomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CRÍTICO FIX: Watch para que AuthWrapper se reconstruya cuando logout ocurra
    // El loginUserProvider cambio cuando logout ocurre (de AsyncData<User> a AsyncData<null>)
    // Esto trigger una reconstrucción completa del AuthWrapper
    ref.listen(loginUserProvider, (previous, next) {
      SecurityService.secureLog(
        '🔐 [AUTH WRAPPER] loginUserProvider changed: ${previous?.toString() ?? "null"} → ${next.toString()}',
        level: 'DEBUG'
      );
      
      // Cuando logout ocurre (next es AsyncData<null>), recalcular el estado de auth
      if (next is AsyncData && next.value == null) {
        SecurityService.secureLog(
          '🔐 [AUTH WRAPPER] LOGOUT DETECTED! Recalculating auth state...',
          level: 'DEBUG'
        );
        
        // 🔑 IMPORTANTE: Agregar pequeño delay para que SharedPreferences se estabilice
        // En Flutter Web, localStorage puede no estar sincronizado inmediatamente después del logout
        // Este delay permite que los datos se escriban correctamente antes de releer
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            SecurityService.secureLog(
              '⏳ [AUTH WRAPPER] Delay elapsed, now rechecking auth state...',
              level: 'DEBUG'
            );
            setState(() {
              _authState = _checkAuthState();
            });
          }
        });
      }
    });

    return FutureBuilder<Widget>(
      future: _authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Retornar la pantalla decidida
        return snapshot.data ?? WelcomeScreen();
      },
    );
  }
}
