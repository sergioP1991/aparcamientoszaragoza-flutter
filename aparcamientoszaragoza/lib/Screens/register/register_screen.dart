import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:aparcamientoszaragoza/Screens/register/providers/RegisterProviders.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Common_widgets/gradient_background.dart';
import '../../Components/app_text_form_field.dart';
import '../../Utils/helpers/snackbar_helper.dart';
import '../../Values/app_constants.dart';
import '../../Values/app_regex.dart';
import '../../Values/app_strings.dart';
import '../../Values/app_theme.dart';

class RegisterPage extends ConsumerStatefulWidget {

  static const routeName = '/register-page';

  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController urlProfileController;


  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> confirmPasswordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  final ValueNotifier<bool> urlProfileNotifier = ValueNotifier(false);

  void initializeControllers() {
    nameController = TextEditingController()..addListener(controllerListener);
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()
      ..addListener(controllerListener);
    confirmPasswordController = TextEditingController()
      ..addListener(controllerListener);
    urlProfileController = TextEditingController()
      ..addListener(controllerUrlImageListener);
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void controllerListener() {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty &&
        email.isEmpty &&
        password.isEmpty &&
        confirmPassword.isEmpty) return;

    if (AppRegex.usernameRegex.hasMatch(email) &&
        AppRegex.passwordRegex.hasMatch(password) &&
        AppRegex.passwordRegex.hasMatch(confirmPassword)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  void controllerUrlImageListener() {
    final urlImageProfile = urlProfileController.text;

    if (urlImageProfile.isEmpty) {
      urlProfileNotifier.value = false;
      return;
    }

    if (AppRegex.urlProfileImageRegex.hasMatch(urlImageProfile)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
    return;
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    AsyncValue<UserCredential?> result = ref.watch(registerUserProvider);

    if (result.hasError) {
      SnackbarHelper.showSnackBar(isError: true, result.error.toString(),
      );
    } else if (result.value?.user != null) {
      var snackBar = const SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Registro completo!',
          message:
          'Registro completado correctamente!',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.success,
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar));


        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
    }

    return Scaffold(
      body: ListView(
        children: [
          GradientBackground(
            urlCircleImage:  "Imagen",
            children: const [
              Text(AppStrings.register, style: AppTheme.titleLarge),
              SizedBox(height: 6),
              Text(AppStrings.createYourAccount, style: AppTheme.bodySmall),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextFormField(
                    autofocus: true,
                    labelText: AppStrings.name,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterName
                          : value.length < 4
                              ? AppStrings.invalidName
                              : null;
                    },
                    controller: nameController,
                  ),
                  AppTextFormField(
                    labelText: AppStrings.email,
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterEmailAddress
                          : AppRegex.emailRegex.hasMatch(value)
                              ? null
                              : AppStrings.invalidEmailAddress;
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: passwordNotifier,
                    builder: (_, passwordObscure, __) {
                      return AppTextFormField(
                        obscureText: passwordObscure,
                        controller: passwordController,
                        labelText: AppStrings.password,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? AppStrings.pleaseEnterPassword
                              : AppRegex.passwordRegex.hasMatch(value)
                                  ? null
                                  : AppStrings.invalidPassword;
                        },
                        suffixIcon: Focus(
                          /// If false,
                          ///
                          /// disable focus for all of this node's descendants
                          descendantsAreFocusable: false,

                          /// If false,
                          ///
                          /// make this widget's descendants un-traversable.
                          // descendantsAreTraversable: false,
                          child: IconButton(
                            onPressed: () =>
                                passwordNotifier.value = !passwordObscure,
                            style: IconButton.styleFrom(
                              minimumSize: const Size.square(48),
                            ),
                            icon: Icon(
                              passwordObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: confirmPasswordNotifier,
                    builder: (_, confirmPasswordObscure, __) {
                      return AppTextFormField(
                        labelText: AppStrings.confirmPassword,
                        controller: confirmPasswordController,
                        //obscureText: confirmPasswordObscure,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? AppStrings.pleaseReEnterPassword
                              : AppRegex.passwordRegex.hasMatch(value)
                                  ? passwordController.text ==
                                          confirmPasswordController.text
                                      ? null
                                      : AppStrings.passwordNotMatched
                                  : AppStrings.invalidPassword;
                        },
                        suffixIcon: Focus(
                          /// If false,
                          ///
                          /// disable focus for all of this node's descendants.
                          descendantsAreFocusable: false,

                          /// If false,
                          ///
                          /// make this widget's descendants un-traversable.
                          // descendantsAreTraversable: false,
                          child: IconButton(
                            onPressed: () => confirmPasswordNotifier.value = true,
                                //!confirmPasswordObscure,
                            style: IconButton.styleFrom(
                              minimumSize: const Size.square(48),
                            ),
                            icon: const Icon(
                              //confirmPasswordObscure
                                   Icons.visibility_off_outlined,
                                  // Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  AppTextFormField(
                    labelText: AppStrings.urlProfile,
                    controller: urlProfileController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.url,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseUrlImage
                          : AppRegex.urlProfileImageRegex.hasMatch(value)
                          ? null
                          : AppStrings.invalidUrlImage;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (_, isValid, __) {
                      return FilledButton(
                        onPressed: () => {
                          ref .read(registerUserProvider.notifier)
                              .register(UserRegister(
                                                      nameController.text,
                                                      emailController.text,
                                                      passwordController.text,
                                                      urlProfileController.text))
                        },

                        child: const Text(AppStrings.register)
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.iHaveAnAccount,
                style: AppTheme.bodySmall.copyWith(color: Colors.black),
              ),
              TextButton(
                onPressed: () => {
                  ref.invalidate(fetchRegisterUserProvider)
                },

                child: const Text(AppStrings.login),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
