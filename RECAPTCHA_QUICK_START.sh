#!/bin/bash

# 🚀 Quick Reference - reCAPTCHA Integration Testing Commands

# Project Directory
PROJECT_DIR="/Users/e032284/Proyectos/Sergio-Clases/AparcamientosZaragozaFlutter/aparcamientoszaragoza-flutter/aparcamientoszaragoza"

echo "🔐 reCAPTCHA v3 Integration - Quick Reference"
echo "=============================================="
echo ""

# 1. Setup
echo "1️⃣  SETUP"
echo "   cd $PROJECT_DIR"
echo "   flutter pub get"
echo ""

# 2. Run in Chrome
echo "2️⃣  RUN IN CHROME"
echo "   flutter run -d chrome"
echo ""

# 3. Test Commands
echo "3️⃣  TESTING"
echo "   # Test Login with reCAPTCHA"
echo "   # 1. Open app in Chrome"
echo "   # 2. Go to Login Screen"
echo "   # 3. Enter email: test@example.com"
echo "   # 4. Enter password: TestPass123"
echo "   # 5. Click 'Entrar'"
echo "   # 6. Check console (F12) for: '✅ reCAPTCHA token obtained'"
echo ""
echo "   # Test Contact Form"
echo "   # 1. Go to Settings > Compose Email"
echo "   # 2. Fill subject and message"
echo "   # 3. Click 'Enviar'"
echo "   # 4. Check console for: '✅ reCAPTCHA token obtained for action: contact'"
echo ""

# 4. Verify Compilation
echo "4️⃣  VERIFY COMPILATION"
echo "   dart analyze lib/Screens/login/login_screen.dart"
echo "   dart analyze lib/Screens/settings/compose_email_screen.dart"
echo "   dart analyze lib/Services/RecaptchaService.dart"
echo ""

# 5. Build for Android
echo "5️⃣  BUILD ANDROID APK (Optional)"
echo "   flutter build apk --debug"
echo "   # APK at: build/app/outputs/flutter-apk/app-debug.apk"
echo ""

# 6. Testing Bot Detection
echo "6️⃣  TEST BOT DETECTION (Development Only)"
echo "   # Edit: lib/Services/RecaptchaService.dart"
echo "   # Change line 28:"
echo "   #   FROM: static const double highRiskThreshold = 0.3;"
echo "   #   TO:   static const double highRiskThreshold = 0.9;"
echo "   # Then try login - should show 'Se detectó actividad de bot'"
echo "   # Revert change when done"
echo ""

# 7. Production Setup
echo "7️⃣  PRODUCTION SETUP"
echo "   # 1. Go to: https://www.google.com/recaptcha/admin"
echo "   # 2. Create new reCAPTCHA v3 app"
echo "   # 3. Get Site Key and Secret Key"
echo "   # 4. Update web/index.html with your Site Key"
echo "   # 5. Save Secret Key in Firebase Remote Config"
echo "   # 6. Deploy Cloud Function for verification"
echo ""

# 8. Documentation
echo "8️⃣  DOCUMENTATION"
echo "   # Quick Testing Guide"
echo "   cat RECAPTCHA_TESTING.md"
echo ""
echo "   # Full Setup Guide"
echo "   cat RECAPTCHA_SETUP.md"
echo ""
echo "   # Implementation Summary"
echo "   cat RECAPTCHA_IMPLEMENTATION_SUMMARY.md"
echo ""
echo "   # Security Documentation"
echo "   cat SECURITY.md"
echo ""

# 9. File Locations
echo "9️⃣  KEY FILES"
echo "   # Service"
echo "   $PROJECT_DIR/lib/Services/RecaptchaService.dart"
echo ""
echo "   # Integration Points"
echo "   $PROJECT_DIR/lib/Screens/login/login_screen.dart (line 175+)"
echo "   $PROJECT_DIR/lib/Screens/settings/compose_email_screen.dart (line 131+)"
echo ""
echo "   # Configuration"
echo "   $PROJECT_DIR/web/index.html (line 44+)"
echo ""
echo "   # Documentation"
echo "   $PROJECT_DIR/RECAPTCHA_SETUP.md"
echo "   $PROJECT_DIR/RECAPTCHA_TESTING.md"
echo "   $PROJECT_DIR/RECAPTCHA_IMPLEMENTATION_SUMMARY.md"
echo "   $PROJECT_DIR/SECURITY.md"
echo ""

# 10. Troubleshooting
echo "🔧 TROUBLESHOOTING"
echo "   # No console logs?"
echo "   1. Open DevTools (F12)"
echo "   2. Go to Console tab"
echo "   3. Search for 'reCAPTCHA' or '✅'"
echo "   4. Reload page (Ctrl+Shift+R)"
echo ""
echo "   # reCAPTCHA not loaded?"
echo "   1. Check web/index.html has script tag"
echo "   2. Verify Site Key is in script"
echo "   3. Reload page"
echo ""
echo "   # Low scores always?"
echo "   1. Normal for repeated attempts (suspicious)"
echo "   2. Try incognito mode"
echo "   3. Wait between attempts"
echo ""

# 11. Quick Commands
echo "⚡ QUICK COMMANDS"
echo "   cd $PROJECT_DIR && flutter run -d chrome              # Run app"
echo "   flutter clean && flutter pub get                      # Clean build"
echo "   dart analyze lib/Services/RecaptchaService.dart       # Check syntax"
echo "   grep -r 'RecaptchaService' lib/                       # Find usages"
echo ""

echo "✅ Ready to test reCAPTCHA v3!"
echo ""
