import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aparcamientoszaragoza/Screens/welcome_screen.dart';
import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';

/// Pantalla que decide si mostrar el Welcome o el Login
/// - Welcome: Si no hay usuario recordado
/// - Login: Si hay usuario recordado (permite cambiar de usuario o continuar)
/// - NO va automáticamente al Home (el login/firebase auth lo maneja)
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _hasRememberedUser;

  @override
  void initState() {
    super.initState();
    _hasRememberedUser = _checkRememberedUser();
  }

  Future<bool> _checkRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUserEmail = prefs.getString('lastUserEmail');
    return lastUserEmail != null && lastUserEmail.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasRememberedUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si hay usuario recordado, ir a login (para poder cambiar o continuar)
        // NO ir automáticamente al home (eso lo maneja Firebase auth)
        if (snapshot.hasData && snapshot.data == true) {
          return LoginPage();
        }

        // Si no hay usuario recordado, mostrar welcome
        return WelcomeScreen();
      },
    );
  }
}
