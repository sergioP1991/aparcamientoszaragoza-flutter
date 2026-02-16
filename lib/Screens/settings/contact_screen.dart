import 'package:aparcamientoszaragoza/Screens/settings/compose_email_screen.dart';
import 'package:aparcamientoszaragoza/Screens/settings/providers/settings_provider.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends ConsumerWidget {
  static const routeName = '/contact';

  const ContactScreen({super.key});

  // Datos de contacto
  static const String _phoneNumber = '+34976123456';
  static const String _email = 'soporte@aparcamientoszaragoza.es';
  static const String _whatsappNumber = '+34976123456';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isDark = settings.theme == 'dark';

    final bgColor = isDark ? const Color(0xFF05080F) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final subtitleColor = isDark ? Colors.white60 : Colors.grey;

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
          l10n.contactUs,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.support_agent,
                      size: 64,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¿Cómo podemos ayudarte?',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige cómo prefieres contactarnos',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // Opciones de contacto
            _buildContactOption(
              context: context,
              icon: Icons.chat_bubble_outline,
              title: 'Chat en vivo',
              subtitle: 'Habla con un agente ahora',
              description: 'Disponible 24/7',
              color: const Color(0xFF4CAF50),
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              onTap: () => _openChat(context),
            ),

            const SizedBox(height: 16),

            _buildContactOption(
              context: context,
              icon: Icons.phone_outlined,
              title: 'Llamar por teléfono',
              subtitle: '976 123 456',
              description: 'Lun-Dom: 8:00 - 22:00',
              color: const Color(0xFF2196F3),
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              onTap: () => _makePhoneCall(),
            ),

            const SizedBox(height: 16),

            _buildContactOption(
              context: context,
              icon: Icons.email_outlined,
              title: 'Enviar email',
              subtitle: 'Escríbenos tu consulta',
              description: 'Respuesta en 24-48h',
              color: const Color(0xFFFF9800),
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              onTap: () => Navigator.pushNamed(context, ComposeEmailScreen.routeName),
            ),

            const SizedBox(height: 16),

            _buildContactOption(
              context: context,
              icon: Icons.message_outlined,
              title: 'WhatsApp',
              subtitle: 'Escríbenos por WhatsApp',
              description: 'Respuesta rápida',
              color: const Color(0xFF25D366),
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              onTap: () => _openWhatsApp(),
            ),

            const SizedBox(height: 40),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Información útil',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on_outlined, 'Zaragoza, España', subtitleColor),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, 'Soporte: 8:00 - 22:00', subtitleColor),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Lunes a Domingo', subtitleColor),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: Colors.white10) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark ? Colors.white30 : Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 14),
        ),
      ],
    );
  }

  // Abrir chat (simula apertura de chat)
  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChatBottomSheet(),
    );
  }

  // Hacer llamada telefónica
  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  // Enviar email
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _email,
      query: 'subject=Consulta desde la app&body=Hola, necesito ayuda con...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // Abrir WhatsApp
  Future<void> _openWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$_whatsappNumber?text=Hola, necesito ayuda con la app de aparcamientos');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }
}

// Widget del chat en vivo
class _ChatBottomSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends ConsumerState<_ChatBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: '¡Hola! 👋 Soy el asistente virtual de Aparcamientos Zaragoza. ¿En qué puedo ayudarte hoy?',
      isAgent: true,
      time: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: _messageController.text,
        isAgent: false,
        time: DateTime.now(),
      ));
    });

    _messageController.clear();

    // Simular respuesta del agente
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Gracias por tu mensaje. Un agente se pondrá en contacto contigo en breve. Mientras tanto, ¿hay algo más en lo que pueda ayudarte?',
            isAgent: true,
            time: DateTime.now(),
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.theme == 'dark';
    final bgColor = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent, color: Color(0xFF4CAF50), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chat en vivo',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'En línea',
                            style: TextStyle(
                              color: const Color(0xFF4CAF50),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(color: isDark ? Colors.white10 : Colors.grey[200], height: 1),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isDark, textColor);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B2E) : Colors.grey[50],
              border: Border(
                top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, bool isDark, Color textColor) {
    return Align(
      alignment: message.isAgent ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isAgent
              ? (isDark ? const Color(0xFF161B2E) : Colors.grey[100])
              : AppColors.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isAgent ? 4 : 16),
            bottomRight: Radius.circular(message.isAgent ? 16 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isAgent ? textColor : Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: message.isAgent
                    ? (isDark ? Colors.white38 : Colors.grey)
                    : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isAgent;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isAgent,
    required this.time,
  });
}
