import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickalert/quickalert.dart';

class ComposeEmailScreen extends ConsumerStatefulWidget {
  static const routeName = '/compose-email';

  const ComposeEmailScreen({super.key});

  @override
  ConsumerState<ComposeEmailScreen> createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends ConsumerState<ComposeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  // Emails de los administradores
  static const List<String> _adminEmails = [
    'sergio1991hortas@gmail.com',
    'moisesvs@gmail.com',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isDark = settings.theme == 'dark';

    final bgColor = isDark ? const Color(0xFF05080F) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final subtitleColor = isDark ? Colors.white60 : Colors.grey;
    final inputBgColor = isDark ? const Color(0xFF1E2337) : const Color(0xFFF0F2F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enviar email',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        size: 48,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Escríbenos tu consulta',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Te responderemos en 24-48 horas',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Destinatario (solo informativo)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: Colors.white10) : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Para: ',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Soporte Aparcamientos Zaragoza',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Campo de asunto
              Text(
                'Asunto',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Ej: Problema con mi reserva',
                  hintStyle: TextStyle(color: subtitleColor),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(Icons.subject, color: subtitleColor),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, introduce un asunto';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Campo de mensaje
              Text(
                'Mensaje',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                style: TextStyle(color: textColor),
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Describe tu consulta o problema con el mayor detalle posible...',
                  hintStyle: TextStyle(color: subtitleColor),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, escribe tu mensaje';
                  }
                  if (value.trim().length < 10) {
                    return 'El mensaje debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Botón de enviar
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Enviar mensaje',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu mensaje será enviado a nuestro equipo de soporte. Recibirás una respuesta en el correo asociado a tu cuenta.',
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'No registrado';
      final userName = user?.displayName ?? 'Usuario';

      // Llamar a la Cloud Function sendSupportEmail
      final callable = FirebaseFunctions.instance.httpsCallable('sendSupportEmail');
      
      final result = await callable.call({
        'to': _adminEmails,
        'replyTo': userEmail,
        'subject': '[Aparcamientos Zaragoza] ${_subjectController.text.trim()}',
        'text': '''
Nueva consulta de soporte

De: $userName
Email: $userEmail
Asunto: ${_subjectController.text.trim()}

Mensaje:
${_messageController.text.trim()}

---
Este mensaje fue enviado desde la app Aparcamientos Zaragoza
        ''',
        'html': '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background-color: #1a73e8; padding: 20px; text-align: center;">
              <h1 style="color: white; margin: 0;">Aparcamientos Zaragoza</h1>
            </div>
            <div style="padding: 30px; background-color: #f9f9f9;">
              <h2 style="color: #333; margin-top: 0;">Nueva consulta de soporte</h2>
              
              <div style="background-color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                <p style="margin: 0 0 10px;"><strong>De:</strong> $userName</p>
                <p style="margin: 0 0 10px;"><strong>Email:</strong> $userEmail</p>
                <p style="margin: 0;"><strong>Asunto:</strong> ${_subjectController.text.trim()}</p>
              </div>
              
              <div style="background-color: white; padding: 20px; border-radius: 8px;">
                <p style="margin: 0 0 10px;"><strong>Mensaje:</strong></p>
                <p style="margin: 0; white-space: pre-wrap;">${_messageController.text.trim()}</p>
              </div>
            </div>
            <div style="background-color: #333; padding: 15px; text-align: center;">
              <p style="color: #999; margin: 0; font-size: 12px;">
                Este mensaje fue enviado desde la app Aparcamientos Zaragoza
              </p>
            </div>
          </div>
        ''',
        'userId': user?.uid ?? 'anonymous',
        'userEmail': userEmail,
      });

      debugPrint('✅ Email enviado via Cloud Function: ${result.data}');

      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Mensaje enviado!',
          text: 'Hemos recibido tu consulta. Te responderemos lo antes posible.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: AppColors.primaryColor,
          onConfirmBtnTap: () {
            Navigator.pop(context); // Cerrar alerta
            Navigator.pop(context); // Volver a pantalla anterior
          },
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ Error Cloud Function: ${e.code} - ${e.message}');
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'No se pudo enviar el mensaje: ${e.message}',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('❌ Error al enviar email: $e');
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'No se pudo enviar el mensaje. Por favor, inténtalo de nuevo.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}
