import 'package:aparcamientoszaragoza/Screens/forgetPassword/provider/ForgerPassword_provider.dart';
import 'package:aparcamientoszaragoza/Values/app_colors.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  static const routeName = '/password-page';

  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState
    extends ConsumerState<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$",
  );

  bool _isLogged = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _isLogged = true;
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    final l10n = AppLocalizations.of(context)!;
    if (v.isEmpty) return l10n.emailRequiredRegister;
    if (!_emailRegExp.hasMatch(v)) return l10n.emailInvalidRegister;
    return null;
  }

  void _submitEmail() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      ref
          .read(forgetPasswordProvider.notifier)
          .forgetPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<String?> user = ref.watch(forgetPasswordProvider);
    
    if (user.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSendingEmail)),
        );
        ref.invalidate(forgetPasswordProvider);
      });
    } else if (user.hasValue && user.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primaryColor),
                const SizedBox(width: 10),
                Text(l10n.emailSentTitle, style: const TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              l10n.emailSentMessage,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.pop(context); // Volver a la pantalla anterior (Login)
                },
                child: Text(
                  l10n.understoodAction,
                  style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
        ref.invalidate(forgetPasswordProvider);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.darkestBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Header - Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Central Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryColor.withOpacity(0.2), width: 2),
                            color: AppColors.primaryColor.withOpacity(0.05),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 60,
                            color: AppColors.primaryColor,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        Text(
                          AppLocalizations.of(context)!.forgotPasswordTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          _isLogged 
                            ? AppLocalizations.of(context)!.forgotPasswordSubtitleLogged
                            : AppLocalizations.of(context)!.forgotPasswordSubtitleNotLogged,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.emailLabel,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Input Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: _isLogged,
                          style: TextStyle(color: _isLogged ? Colors.white60 : Colors.white),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.emailHintForget,
                            hintStyle: const TextStyle(color: Colors.white30),
                            prefixIcon: Icon(
                              _isLogged ? Icons.lock_outline : Icons.email_outlined, 
                              color: Colors.white70, 
                              size: 20
                            ),
                            filled: true,
                            fillColor: const Color(0xff1A202E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: _isLogged ? Colors.white.withOpacity(0.1) : AppColors.primaryColor),
                            ),
                          ),
                          validator: _validateEmail,
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.sendRecoveryLink,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.send_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.needMoreHelp,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Support action
                    },
                    child: Text(
                      AppLocalizations.of(context)!.contactSupport,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

