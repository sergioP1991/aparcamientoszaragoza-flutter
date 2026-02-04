import 'package:flutter/material.dart';

/// Pantalla sencilla con un único campo de texto para introducir
/// un correo electrónico y validación del mismo.
///
/// Uso: en tu `main.dart` puedes poner `home: EmailScreen()` dentro de
/// `MaterialApp` para probarla.

class FormetPasswordScreen extends StatefulWidget {

  static const routeName = '/password-page';

  const FormetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<FormetPasswordScreen> createState() => _FormetPasswordScreenState();
}

class _FormetPasswordScreenState extends State<FormetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  // Expresión regular sencilla para validar emails comunes.
  // No es 100% RFC-complete pero cubre la mayoría de casos prácticos.
  final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+\\$",
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Introduce un correo electrónico';
    if (!_emailRegExp.hasMatch(v)) return 'Introduce un correo válido';
    return null;
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo válido: ${_emailController.text.trim()}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor corrige los errores')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introducir correo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: _validateEmail,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
            ),

            const SizedBox(height: 20),

            // Botón que activa la validación. Puedes quitarlo si quieres
            // validar sólo al salir del campo.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Resetear contraseña'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
