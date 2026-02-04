import 'package:aparcamientoszaragoza/Screens/forgetPassword/ForgetPassword_screen.dart';
import 'package:aparcamientoszaragoza/Screens/home/home_screen.dart' as home;
import 'package:aparcamientoszaragoza/Screens/login/providers/UserProviders.dart';
import 'package:aparcamientoszaragoza/Screens/register/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../Common_widgets/gradient_background.dart';
import '../../Components/app_text_form_field.dart';
import '../../Resources/resources.dart';
import '../../Values/app_regex.dart';
import '../../Values/app_strings.dart';
import '../../Values/app_theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const routeName = '/login-page';

  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {

  var todosAlquilados = false;

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  void initializeControllers() {
    usernameController = TextEditingController()
      ..addListener(controllerListener);
    passwordController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    usernameController.dispose();
    passwordController.dispose();
  }

  void controllerListener() {
    final email = usernameController.text;
    final password = passwordController.text;

    if (email.isEmpty && password.isEmpty) return;

    if (AppRegex.usernameRegex.hasMatch(email) &&
        AppRegex.passwordRegex.hasMatch(password)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  Widget countFree(int alquiladas, int total, AppLocalizations l10n) {
    return Row(
      children: <Widget>[
        const Icon(Icons.directions_car_sharp, color: Colors.blueGrey),
        Text(
          "${alquiladas} ${l10n.occupiedLabel} ${l10n.ofLabel} ${total}", 
          style: AppTheme.bodySmall
        ),
        if (alquiladas == total)
          Text("\t\t ${l10n.fullLabel}", style: AppTheme.bodyTextRed)
        else
          Text("\t\t ${l10n.availableLabel}", style: AppTheme.bodyTextGreen),
      ]
    );
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  var countRentParking = 0;
  var countAllPraking = 0;
  var lastUpdate ="";
  var priceValue = "";

  @override
  Widget build(BuildContext context) {
    AsyncValue<User?> user = ref.watch(loginUserProvider);

    final l10n = AppLocalizations.of(context)!;
    // Listen for state changes (Success/Error)
    ref.listen(loginUserProvider, (previous, next) {
        if (next.error != null) {
             QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: l10n.errorTitle,
                text: '${l10n.loginError} ${next.error?.toString()}',
              );
        } else if (next.value != null && next.value?.email != null) {
             QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                title: l10n.loginWelcomeTitle,
                text: '${l10n.loginSuccess} ${next.value?.email?.toString()}',
              );
             usernameController.clear();
             passwordController.clear();
             SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushNamed(home.HomePage.routeName);
             });
        }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF070914),
      body: Stack(
        children: [
           // 1. Background Image at Top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset(
              'assets/garaje1.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Dark Overlay Gradient for the fade out effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.2),
                  const Color(0xFF070914).withOpacity(0.8),
                  const Color(0xFF070914),
                ],
                stops: const [0.0, 0.2, 0.4, 0.55],
              ),
            ),
          ),
          
          // 3. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 48, 
                      height: 48,
                      decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.1),
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.white.withOpacity(0.2))
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  
                  SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                  
                  // Header
                  Text(
                    l10n.loginWelcomeTitle,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        Text(
                          l10n.emailLabel,
                          style: const TextStyle(
                             color: Colors.white60, 
                             fontWeight: FontWeight.w600,
                             fontSize: 12,
                             letterSpacing: 1.0
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1E2235).withOpacity(0.8),
                            hintText: l10n.emailHint,
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: const Color(0xFF2962FF)),
                            ),
                          ),
                          onChanged: (_) => _formKey.currentState?.validate(),
                          validator: (value) {
                             if (value == null || value.isEmpty) return l10n.emailRequired;
                             if (!AppRegex.emailRegex.hasMatch(value)) return l10n.invalidEmail;
                             return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.passwordLabel,
                              style: const TextStyle(
                                 color: Colors.white60, 
                                 fontWeight: FontWeight.w600, 
                                 fontSize: 12,
                                 letterSpacing: 1.0
                              ),
                            ),
                            GestureDetector(
                               onTap: () => Navigator.of(context).pushNamed(ForgetPasswordScreen.routeName),
                               child: Text(
                                  l10n.forgotPassword,
                                  style: const TextStyle(
                                      color: Color(0xFF448AFF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12
                                  ),
                               ),
                            )
                          ],
                        ),
                         const SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: passwordNotifier,
                          builder: (_, passwordObscure, __) {
                            return TextFormField(
                              controller: passwordController,
                              obscureText: passwordObscure,
                              style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF1E2235).withOpacity(0.8),
                                  hintText: l10n.passwordHint,
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.white.withOpacity(0.5)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    passwordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  onPressed: () => passwordNotifier.value = !passwordNotifier.value,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF2962FF)),
                                ),
                              ),
                               onChanged: (_) => _formKey.currentState?.validate(),
                               validator: (value) {
                                 if (value == null || value.isEmpty) return l10n.passwordRequired;
                                 return null;
                               },
                            );
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Login Button
                        ValueListenableBuilder(
                          valueListenable: fieldValidNotifier,
                           builder: (_, isValid, __) {
                             return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: !todosAlquilados ? () {
                                    if (_formKey.currentState!.validate()) {
                                       ref.read(loginUserProvider.notifier).loginMailUser(
                                          usernameController.text.trim(),
                                          passwordController.text.trim(),
                                       );
                                    }
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2962FF), // Brand Blue
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.loginButton,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                    ],
                                  ),
                                ),
                             );
                           }
                        ),
                        
                        const SizedBox(height: 32),
                        
                         // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                l10n.continueWith,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                             onPressed: () {
                               ref.read(loginUserProvider.notifier).signIn();
                             },
                             style: OutlinedButton.styleFrom(
                               backgroundColor: const Color(0xFF1E2235).withOpacity(0.8),
                               side: BorderSide(color: Colors.white.withOpacity(0.1)),
                               shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)
                               )
                             ),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 SvgPicture.asset(Vectors.google, width: 24),
                                 const SizedBox(width: 12),
                                 Text(
                                   l10n.googleLogin,
                                   style: const TextStyle(
                                     fontSize: 16,
                                     color: Colors.white,
                                     fontWeight: FontWeight.w600
                                   ),
                                 ),
                               ],
                             ),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Register Link
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(RegisterPage.routeName),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.white60, fontSize: 15),
                                children: [
                                  TextSpan(text: l10n.noAccount),
                                  TextSpan(
                                    text: l10n.registerAction,
                                    style: const TextStyle(
                                      color: const Color(0xFF448AFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}