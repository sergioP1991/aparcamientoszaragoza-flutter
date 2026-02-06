import 'package:aparcamientoszaragoza/Models/user-register.dart';
import 'package:aparcamientoszaragoza/Screens/login/login_screen.dart';
import 'package:aparcamientoszaragoza/Screens/register/providers/RegisterProviders.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aparcamientoszaragoza/Screens/login/providers/UserProviders.dart';

import '../../Utils/helpers/snackbar_helper.dart';
import '../../Values/app_regex.dart';
import '../../Values/app_strings.dart';
import '../../Values/app_theme.dart';
import 'package:aparcamientoszaragoza/l10n/app_localizations.dart';
import '../smsVerified/smsvalidate_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';


class RegisterPage extends ConsumerStatefulWidget {
  static const routeName = '/register-page';
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController urlProfileController;
  late final TextEditingController phoneNumberController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isScanning = false;
  
  bool _acceptTerms = false;
  bool _acceptMarketing = false;
  XFile? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  void initializeControllers() {
    nameController = TextEditingController()
      ..addListener(() => setState(() {}));
    emailController = TextEditingController()
      ..addListener(() => setState(() {}));
    passwordController = TextEditingController()
      ..addListener(() => setState(() {}));
    confirmPasswordController = TextEditingController()
      ..addListener(() => setState(() {}));
    urlProfileController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    urlProfileController.dispose();
    phoneNumberController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Si ya está inicializada y el controlador está OK, no hacemos nada
    if (_isCameraInitialized && _cameraController != null && _cameraController!.value.isInitialized) return;
    
    try {
      // Si hay un controlador previo que no está bien, lo liberamos
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No se encontraron cámaras');
        return;
      }
      
      // Buscar cámara frontal
      CameraDescription? frontCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }
      
      _cameraController = CameraController(
        frontCamera ?? _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error al inicializar la cámara: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  void _nextStep() {
    // Solo validamos el formulario en los pasos 1 y 2 que es donde están los campos
    if (_currentStep <= 2) {
      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep == 2) {
      final l10n = AppLocalizations.of(context)!;
      final password = passwordController.text;
      final confirm = confirmPasswordController.text;

      final has8Chars = password.length >= 8;
      final hasNumber = password.contains(RegExp(r'[0-9]'));
      final noSpaces = !password.contains(' ') && password.isNotEmpty;
      final match = password == confirm && password.isNotEmpty;

      if (!(has8Chars && hasNumber && noSpaces && match)) {
        SnackbarHelper.showSnackBar(
          isError: true, 
          l10n.passwordSecurityWarning
        );
        return;
      }
      _initializeCamera();
    }

    if (_currentStep == 3 || _currentStep == 4) {
      final l10n = AppLocalizations.of(context)!;
      if (_currentStep == 4) {
        if (!_acceptTerms) {
          SnackbarHelper.showSnackBar(isError: true, l10n.termsRequired);
          return;
        }
        _handleRegister();
      } else {
        setState(() => _currentStep++);
      }
      return;
    }
    
    setState(() {
      if (_currentStep < 4) _currentStep++;
    });
  }

  void _handleRegister() {
    ref.read(registerUserProvider.notifier)
        .register(UserRegister(
            nameController.text,
            emailController.text,
            passwordController.text,
            urlProfileController.text,
            phoneNumberController.text
    ));
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070914),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: _previousStep,
      ),
      title: Text(
        AppLocalizations.of(context)!.registerTitle,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        if (_currentStep == 4)
           Center(
             child: Padding(
               padding: const EdgeInsets.only(right: 16.0),
               child: Text(
                 AppLocalizations.of(context)!.finishAction,
                 style: TextStyle(
                   color: const Color(0xFF4FC3F7).withOpacity(0.8),
                   fontSize: 12,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1.2
                 ),
               ),
             ),
           )
        else
          Container(
            margin: const EdgeInsets.only(right: 16),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)!.stepXofY(_currentStep, 4),
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Column(
        children: [
          if (_currentStep == 4)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    AppLocalizations.of(context)!.stepXofY(4, 4),
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
          Row(
            children: List.generate(4, (index) {
              bool isActive = index < _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: isActive 
                        ? const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)]) 
                        : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.1)]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildPasswordStep();
      case 3:
        return _buildFacialCaptureStep();
      case 4:
        return _buildTermsAndPrivacyStep();
      default:
        return Center(child: Text(AppLocalizations.of(context)!.errorTitle, style: const TextStyle(color: Colors.white)));
    }
  }

  Widget _buildPersonalInfoStep() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personalDataTitle,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.personalDataSubtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          
          _buildFieldLabel(l10n.fullNameLabel),
          _buildTextField(
            controller: nameController,
            hintText: l10n.fullNameHint,
            icon: Icons.person_outline_rounded,
            validator: (value) => value!.isEmpty ? l10n.fullNameRequired : null,
          ),
          
          const SizedBox(height: 24),
          
          _buildFieldLabel(l10n.emailLabel),
          _buildTextField(
            controller: emailController,
            hintText: l10n.emailHintRegister,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.emailRequiredRegister;
              if (!AppRegex.emailRegex.hasMatch(value)) return l10n.emailInvalidRegister;
              return null;
            },
          ),
          
          const SizedBox(height: 40),
          
          _buildContinueButton(l10n),
          
          const SizedBox(height: 32),
          
          _buildDivider(),
          
          const SizedBox(height: 32),
          
          _buildSocialLogins(),
          
          const SizedBox(height: 32),
          
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passwordStepTitle,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.passwordStepSubtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          
          _buildFieldLabel(l10n.passwordLabel),
          _buildTextField(
            controller: passwordController,
            hintText: l10n.passwordMinChars,
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.passwordRequiredRegister;
              if (value.length < 8) return l10n.passwordMinChars;
              if (!value.contains(RegExp(r'[0-9]'))) return l10n.passwordNumbers;
              if (value.contains(' ')) return l10n.passwordNoSpaces;
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white30,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildFieldLabel(l10n.confirmPasswordLabel),
          _buildTextField(
            controller: confirmPasswordController,
            hintText: l10n.confirmPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value != passwordController.text) return l10n.passwordsMismatch;
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white30,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          
          const SizedBox(height: 32),
          
          _buildSecurityRequirements(l10n),
          
          const SizedBox(height: 40),
          
          _buildContinueButton(l10n),
        ],
      ),
    );
  }

  Widget _buildFacialCaptureStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.facialCaptureTitle,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.facialCaptureSubtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 40),
        
        Center(
          child: Container(
            width: 280,
            height: 350,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2235).withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_capturedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: kIsWeb 
                       ? Image.network(_capturedImage!.path, width: 240, height: 310, fit: BoxFit.cover)
                       : Image.file(File(_capturedImage!.path), width: 240, height: 310, fit: BoxFit.cover),
                  )
                else if (_isCameraInitialized && _cameraController != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 240,
                      height: 310,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  )
                else ...[
                  // Oval frame
                  Container(
                    width: 200,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF4FC3F7).withOpacity(0.4),
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.all(Radius.elliptical(100, 130)),
                    ),
                  ),
                  // Scanning Indicators
                  _buildScanningIndicators(),
                  // Face Icon
                  Icon(
                    Icons.face_retouching_natural_rounded,
                    color: Colors.white.withOpacity(0.1),
                    size: 80,
                  ),
                ],
                if (_isScanning)
                  const CircularProgressIndicator(color: Color(0xFF4FC3F7)),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        Center(
          child: Column(
            children: [
              Text(
                _capturedImage != null ? l10n.photoGoodHint : l10n.faceInFrameHint,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _capturedImage != null ? l10n.clearPhotoHint : l10n.goodLightingHint,
                style: const TextStyle(color: Colors.white30, fontSize: 14),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 48),
        
        if (_capturedImage != null) ...[
          _buildContinueButton(l10n),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: _retakePicture,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4FC3F7), size: 20),
              label: Text(
                l10n.retakePhoto,
                style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ] else 
          _buildScanButton(l10n),
        
        const SizedBox(height: 24),
        
        if (_capturedImage == null)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentStep = 4),
              child: Text(
                l10n.skipForNow,
                style: const TextStyle(color: Colors.white30, fontSize: 15),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      setState(() => _isScanning = true);
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      SnackbarHelper.showSnackBar(isError: true, AppLocalizations.of(context)!.cameraError(e.toString()));
    }
  }

  Future<void> _retakePicture() async {
    setState(() {
      _capturedImage = null;
      _isCameraInitialized = false;
    });
    await _initializeCamera();
  }

  Widget _buildTermsAndPrivacyStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2962FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2962FF).withOpacity(0.2)),
          ),
          child: const Icon(Icons.gavel_rounded, color: Color(0xFF4FC3F7), size: 24),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.termsTitle,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.termsSubtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 32),
        
        _buildTermsCard(
          value: _acceptTerms,
          onChanged: (val) => setState(() => _acceptTerms = val ?? false),
          text: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              children: [
                TextSpan(text: l10n.acceptTermsPrefix),
                TextSpan(
                  text: l10n.termsOfService,
                  style: const TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold),
                ),
                TextSpan(text: l10n.andThe),
                TextSpan(
                  text: l10n.privacyPolicy,
                  style: const TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold),
                ),
                TextSpan(text: l10n.acceptTermsSuffix),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildTermsCard(
          value: _acceptMarketing,
          onChanged: (val) => setState(() => _acceptMarketing = val ?? false),
          text: Text(
            l10n.marketingConsent,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
        ),
        
        const SizedBox(height: 48),
        
        _buildRegisterButton(l10n),
        
        const SizedBox(height: 32),
          
        _buildDivider(text: l10n.continueWith),
        
        const SizedBox(height: 32),
        
        _buildSocialLogins(),
      ],
    );
  }

  Widget _buildTermsCard({required bool value, required ValueChanged<bool?> onChanged, required Widget text}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF4FC3F7),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide(color: Colors.white.withOpacity(0.2), width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: text),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.registerActionStep,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningIndicators() {
    return Stack(
      children: [
        // Top indicator
        Positioned(
          top: 45,
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.5), blurRadius: 8)
              ],
            ),
          ),
        ),
        // Bottom indicator
        Positioned(
          bottom: 45,
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Left indicator
        Positioned(
          left: 40,
          child: Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Right indicator
        Positioned(
          right: 40,
          child: Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _takePicture,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              'Escanear cara',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityRequirements(AppLocalizations l10n) {
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    final has8Chars = password.length >= 8;
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final noSpaces = !password.contains(' ') && password.isNotEmpty;
    final match = password == confirm && password.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requisitos de seguridad',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRequirementItem('Mínimo 8 caracteres', has8Chars),
          _buildRequirementItem('Al menos un número', hasNumber),
          _buildRequirementItem('No contener espacios', noSpaces),
          _buildRequirementItem('Las contraseñas coinciden', match),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: met ? const Color(0xFF4FC3F7) : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.white : Colors.white30,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white30, size: 20) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF1E2235).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildContinueButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29B6F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Continuar',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider({String text = 'O REGÍSTRATE CON'}) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildSocialLogins() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: 'assets/vectors/google.svg',
            label: 'Google',
            onPressed: () async {
              try {
                await ref.read(loginUserProvider.notifier).signIn();
              } catch (e) {
                SnackbarHelper.showSnackBar(isError: true, e.toString());
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.apple,
            label: 'Apple',
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({required dynamic icon, required String label, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E2235).withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon is IconData)
            Icon(icon, color: Colors.white, size: 24)
          else
            SvgPicture.asset(icon, width: 20, height: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacementNamed(LoginPage.routeName),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.white60, fontSize: 15),
            children: [
              TextSpan(text: '¿Ya tienes cuenta? '),
              TextSpan(
                text: 'Inicia sesión',
                style: TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}