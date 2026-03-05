import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aparcamientoszaragoza/Screens/welcome_screen.dart';
import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';
import 'package:aparcamientoszaragoza/Services/ReAuthService.dart';

/// Pantalla que decide qué mostrar basándose en el estado de autenticación de Firebase
/// - Home: Si ya hay una sesión activa en Firebase Auth (usuario logueado)
/// - Login: Si no hay sesión pero hay usuario recordado (para poder cambiar o continuar)
/// - Welcome: Si no hay sesión ni usuario recordado
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<Widget> _authState;

  @override
  void initState() {
    super.initState();
    _authState = _checkAuthState();
  }

  /// ✅ Verificar el estado de autenticación esperando a que FirebaseAuth restaure la sesión
  /// En web, FirebaseAuth necesita tiempo para restaurar la sesión desde localStorage
  /// Orden de verificación:
  /// 1. ¿Hay sesión activa en Firebase Auth? → Home
  /// 2. ¿Hay usuario recordado CON session token válido? → Auto-login sin pedir contraseña
  /// 3. ¿Hay usuario recordado SIN sesión token válido? → Login (para poder cambiar)
  /// 4. Nada de lo anterior? → Welcome
  Future<Widget> _checkAuthState() async {
    try {
      // 🔑 CRÍTICO para web: usar authStateChanges() para esperar a que Firebase restaure la sesión
      // En web, currentUser puede ser null inicialmente mientras se restaura desde localStorage
      // Usamos .first con timeout para dar tiempo a Firebase (pero no esperar infinito)
      User? authUser;
      
      try {
        authUser = await FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () => FirebaseAuth.instance.currentUser,
            );
      } catch (e) {
        // Si existe error en el stream, usar currentUser como fallback
        authUser = FirebaseAuth.instance.currentUser;
      }
      
      if (authUser != null && authUser.email != null) {
        // ✅ Hay sesión activa en Firebase - ir al Home directamente
        SecurityService.secureLog(
          'Usuario autenticado encontrado: ${authUser.email}. Navegando al Home.',
          level: 'DEBUG'
        );
        return HomePage();
      }
      
      // Si no hay sesión en Firebase, verificar si hay usuario recordado + session token válido
      final prefs = await SharedPreferences.getInstance();
      final lastUserEmail = prefs.getString('lastUserEmail');
      
      if (lastUserEmail != null && lastUserEmail.isNotEmpty) {
        // Verificar si tiene session token válido
        final reAuthService = ReAuthService();
        final hasValidToken = await reAuthService.hasValidSessionToken(lastUserEmail);
        
        if (hasValidToken) {
          // ✅ Hay usuario recordado CON session token válido → intenta auto-login
          SecurityService.secureLog(
            'Session token válido encontrado para: $lastUserEmail. Intentando auto-login.',
            level: 'DEBUG'
          );
          
          // Obtener credenciales encriptadas para auto-login
          final cachedEmail = await SecurityService.getSecureData('cached_email');
          final cachedPassword = await SecurityService.getSecureData('cached_password');
          
          if (cachedEmail != null && cachedPassword != null) {
            // ✅ Intentar auto-login con credenciales encriptadas
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: cachedEmail,
                password: cachedPassword,
              );
              SecurityService.secureLog(
                'Auto-login exitoso para: $cachedEmail',
                level: 'DEBUG'
              );
              return HomePage();
            } catch (e) {
              // Auto-login falló (ej: contraseña cambió) → mostrar LoginPage
              SecurityService.secureLog(
                'Auto-login falló: ${e.runtimeType}. Mostrando LoginPage.',
                level: 'WARNING'
              );
              return LoginPage();
            }
          }
        } else {
          // Hay usuario recordado PERO sin session token válido (token expiró)
          // → Mostrar LoginPage para pedir credenciales de nuevo
          SecurityService.secureLog(
            'Session token expirado o no existe para: $lastUserEmail. Mostrar LoginPage.',
            level: 'DEBUG'
          );
        }
        
        // Hay usuario recordado → mostrar LoginPage
        SecurityService.secureLog(
          'Usuario recordado encontrado: $lastUserEmail. Mostrar LoginPage.',
          level: 'DEBUG'
        );
        return LoginPage();
      }
      
      // No hay sesión ni usuario recordado - mostrar Welcome
      SecurityService.secureLog(
        'No hay sesión de usuario activa. Mostrando WelcomeScreen.',
        level: 'DEBUG'
      );
      return WelcomeScreen();
    } catch (e) {
      // En caso de error, mostrar WelcomeScreen como fallback seguro
      SecurityService.secureLog(
        'Error verificando estado de autenticación: $e',
        level: 'ERROR'
      );
      return WelcomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
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
