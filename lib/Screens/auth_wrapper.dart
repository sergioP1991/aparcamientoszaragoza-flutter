import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aparcamientoszaragoza/Screens/welcome_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart';

/// Pantalla que decide si mostrar el Welcome o ir directamente al Home
/// basándose en si hay usuario recordado
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

        // Si hay usuario recordado, ir al home
        if (snapshot.hasData && snapshot.data == true) {
          return HomePage();
        }

        // Si no hay usuario recordado, mostrar welcome
        return WelcomeScreen();
      },
    );
  }
}
