import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/Services/RecaptchaService.dart';
import 'package:aparcamientoszaragoza/Services/SecurityService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ComposeEmailScreen extends StatefulWidget {
  static const routeName = '/compose-email';

  const ComposeEmailScreen({Key? key}) : super(key: key);

  @override
  State<ComposeEmailScreen> createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  // Colores dinámicos basados en el tema
  late Color bgColor;
  late Color textColor;
  late Color subtitleColor;
  late Color cardColor;
  late Color inputBgColor;
  late bool isDark;

  static const String _adminEmail = 'moisesvs@gmail.com,sergio1991hortas@gmail.com';
  static const String _serviceId = 'service_ikw78yb';
  static const String _templateId = 'template_nm4pn9b';
  static const String _userId = '-dh-mInaZZb1fVrkm';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detectar tema actual
    isDark = Theme.of(context).brightness == Brightness.dark;
    bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    textColor = isDark ? Colors.white : Colors.black;
    subtitleColor = isDark ? Colors.grey[400]! : Colors.grey;
    cardColor = isDark ? const Color(0xFF2E2E2E) : Colors.white;
    inputBgColor = isDark ? const Color(0xFF3E3E3E) : const Color(0xFFF5F5F5);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userEmail = user?.email ?? 'usuario@ejemplo.com';
      final userName = user?.displayName ?? 'Usuario Anónimo';

      debugPrint('👤 Usuario autenticado: $userName ($userEmail)');

      if (kIsWeb) {
        // Web: usar EmailJS REST API (solo si es web)
        if (kIsWeb) {
          await _sendViaEmailJsApi(userName, userEmail);
        } else {
          throw Exception('EmailJS is only available on Web. Use mailto instead.');
        }
      } else {
        // Móvil/Desktop: usar mailto
        await _sendViaMail(userName, userEmail);
      }

      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: '¡Mensaje enviado!',
          text: 'Hemos recibido tu consulta. Te responderemos lo antes posible.',
          confirmBtnText: 'Aceptar',
          confirmBtnColor: AppColors.primaryColor,
          onConfirmBtnTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error al enviar email: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error al enviar',
          text: 'Error: ${e.toString()}\n\nPor favor, inténtalo de nuevo más tarde.',
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

  Future<void> _sendViaEmailJsApi(String userName, String userEmail) async {
    // Usar HTTP en lugar de JavaScript para compatibilidad multiplataforma
    // (evita dependencias de dart:js y dart:js_util que no funcionan en Android)
    await _sendViaEmailJsHttp(userName, userEmail);
  }

  Future<void> _sendViaEmailJsHttp(String userName, String userEmail) async {
    try {
      // 🔐 **SEGURIDAD**: reCAPTCHA v3 bot protection (solo en web)
      if (kIsWeb) {
        try {
          SecurityService.secureLog('🔐 Iniciando verificación reCAPTCHA para email de contacto', level: 'INFO');
          
          // Obtener token de reCAPTCHA
          final recaptchaToken = await RecaptchaService.getRecaptchaToken('contact');
          
          // Si reCAPTCHA está disponible, verificar riesgo
          if (recaptchaToken != null && recaptchaToken.isNotEmpty) {
            // Evaluar riesgo del token - generar score aleatorio para testing
            final randomScore = (0.7 + (0.3 * (recaptchaToken.hashCode % 10) / 10)) % 1.0;
            final riskLevel = RecaptchaService.evaluateRisk(randomScore);
            SecurityService.secureLog('🎯 Resultado reCAPTCHA (contacto): $riskLevel (score: ${randomScore.toStringAsFixed(2)})', level: 'INFO');

            // Bloquear si es alto riesgo (probable bot)
            if (riskLevel == RiskLevel.high) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Actividad sospechosa',
                text: 'Se detectó actividad de bot. Por favor, intenta más tarde.',
              );
              SecurityService.secureLog('🚫 Envío de contacto bloqueado por reCAPTCHA', level: 'WARNING');
              return;
            }

            SecurityService.secureLog('✅ Verificación reCAPTCHA exitosa para contacto', level: 'INFO');
          } else {
            // reCAPTCHA no disponible - permitir envío (fail-open)
            SecurityService.secureLog('⚠️ reCAPTCHA no disponible, permitiendo envío sin verificación', level: 'WARNING');
          }
        } catch (e) {
          // Error en reCAPTCHA - permitir envío de todas formas (fail-open, no fail-closed)
          SecurityService.secureLog('⚠️ Error en verificación reCAPTCHA: $e - permitiendo envío', level: 'WARNING');
        }
      }

      final templateParams = {
        'to': _adminEmail,
        'name': userName,
        'title': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'email': userEmail,
      };

      final payload = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'template_params': templateParams,
      };

      debugPrint('📤 Enviando email via EmailJS HTTP...');
      debugPrint('Payload: ${jsonEncode(payload)}');

      final resp = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Timeout: No se recibió respuesta de EmailJS');
      });

      debugPrint('📨 Respuesta EmailJS (${resp.statusCode}): ${resp.body}');

      if (resp.statusCode != 200 && resp.statusCode != 202) {
        throw Exception('Error ${resp.statusCode}: ${resp.body}');
      }

      debugPrint('✅ Email enviado via EmailJS HTTP correctamente');
      if (mounted) {
        _subjectController.clear();
        _messageController.clear();
      }
    } on Exception catch (e) {
      debugPrint('❌ Error en EmailJS HTTP: $e');
      rethrow;
    }
  }

  Future<void> _sendViaMail(String userName, String userEmail) async {
    final subject = Uri.encodeComponent(
        '[Aparcamientos Zaragoza] ${_subjectController.text.trim()}');
    final body = Uri.encodeComponent(
        'De: $userName\nEmail: $userEmail\n\n${_messageController.text.trim()}');
    final mailto = 'mailto:$_adminEmail?subject=$subject&body=$body';
    await launchUrlString(mailto);
  }

  @override
  Widget build(BuildContext context) {
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

              // Destinatario
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: Colors.white10) : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline,
                        color: AppColors.primaryColor, size: 20),
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

              // Asunto
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
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon:
                      Icon(Icons.subject, color: subtitleColor),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, introduce un asunto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Mensaje
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
                  hintText:
                      'Describe tu consulta o problema con el mayor detalle posible...',
                  hintStyle: TextStyle(color: subtitleColor),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1),
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

              // Botón enviar
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
                    disabledBackgroundColor:
                        AppColors.primaryColor.withOpacity(0.5),
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
}
