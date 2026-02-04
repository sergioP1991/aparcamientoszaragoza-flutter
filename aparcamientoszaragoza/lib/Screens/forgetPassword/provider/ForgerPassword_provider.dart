import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Envía el correo de restablecimiento de contraseña.
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Por favor introduce un correo.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _successMessage =
      'Se ha enviado un correo para restablecer tu contraseña.';
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  @riverpod
  final incidentProvider = StateNotifierProvider<
      IncidentsRegisterState, AsyncValue<Incidencias?>>((ref) {
    return IncidentsRegisterState();
  });

}
