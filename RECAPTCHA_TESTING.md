# 🧪 Testing Guide for reCAPTCHA v3 Integration

## Quick Start Testing

### 1. Run the App

```bash
cd /Users/e032284/Proyectos/Sergio-Clases/AparcamientosZaragozaFlutter/aparcamientoszaragoza-flutter/aparcamientoszaragoza

# Compile and run in Chrome
flutter run -d chrome
```

### 2. Test Login with reCAPTCHA

**Steps:**
1. Navigate to Login Screen
2. Enter any valid email: `test@example.com`
3. Enter any password: `TestPass123`
4. Click "Entrar" button
5. Observe:
   - Browser Console (F12) should show: `✅ reCAPTCHA token obtained for action: login`
   - App logs should show: `🔐 Iniciando verificación reCAPTCHA`
   - Then: `🎯 Resultado reCAPTCHA: RiskLevel.low`

**Expected Behavior:**
- If score >= 0.7: Login proceeds normally ✅
- If score < 0.3: Shows "Se detectó actividad de bot" 🚫
- If 0.3-0.7: Warns but proceeds (with 2FA in future) ⚠️

### 3. Test Contact/Email Form

**Steps:**
1. Go to Settings (⚙️ icon)
2. Select "Contacto" or "Enviar mensaje"
3. Fill in form:
   - Subject: "Test Message"
   - Message: "Testing reCAPTCHA"
4. Click "Enviar"
5. Observe:
   - Console: `✅ reCAPTCHA token obtained for action: contact`
   - Logs: `✅ Verificación reCAPTCHA exitosa para contacto`

### 4. Browser Console Logs

Press **F12** in Chrome to open Developer Tools → Console tab

Look for:

```
✅ reCAPTCHA token obtained for action: login
🎯 reCAPTCHA score (test): 0.85
🔐 Iniciando verificación reCAPTCHA
✅ Verificación reCAPTCHA exitosa
```

### 5. Simulate Bot Detection (Testing Only)

To test bot-blocking behavior:

**File:** `lib/Services/RecaptchaService.dart`

**Change line 28:**
```dart
// BEFORE (normal):
static const double highRiskThreshold = 0.3;

// AFTER (testing - makes threshold higher):
static const double highRiskThreshold = 0.9;  // Any score < 0.9 is "bot"
```

**Test:**
1. Try login → Should now show "Se detectó actividad de bot" 🚫
2. Try contact form → Should block email

**Revert:**
```dart
// Change back to normal after testing:
static const double highRiskThreshold = 0.3;
```

### 6. Verify Network Calls

In Chrome DevTools → Network tab:

1. Look for request to: `https://www.google.com/recaptcha/api/siteverify`
2. Should see POST request with:
   - Site Key
   - Token from reCAPTCHA
   - Response with score (0.0-1.0)

### 7. Test on Android

```bash
# Build APK
flutter build apk --debug

# Run on device/emulator
flutter install
flutter run

# Navigate to login and test
```

**Note:** reCAPTCHA v3 requires webview on Android. Should still work on web platform.

---

## Testing Checklist

- [ ] Login with valid credentials → reCAPTCHA verifies → Login succeeds
- [ ] Contact form with message → reCAPTCHA verifies → Email sends
- [ ] Browser console shows reCAPTCHA logs
- [ ] Network tab shows Google reCAPTCHA API calls
- [ ] Changing threshold to 0.9 blocks login/email
- [ ] Reverting threshold allows normal operation
- [ ] Testing on both Chrome and Android APK
- [ ] Logs never contain sensitive data (email, password)

---

## Troubleshooting

### Issue: "reCAPTCHA not loaded"

**Solution:**
1. Check `web/index.html` has reCAPTCHA script tag
2. Verify Site Key is present in script tag
3. Reload page (Ctrl+Shift+R or Cmd+Shift+R)

### Issue: No console logs appear

**Solution:**
1. Open DevTools with F12
2. Check Console tab (not Network tab)
3. Search for "reCAPTCHA" or "✅"
4. Check if SecurityService.secureLog() is working

### Issue: Score always very low (< 0.3)

**Solution:**
- Normal for repeated login attempts (suspicious behavior)
- Try from different browser or in incognito mode
- Wait a few minutes between attempts

### Issue: Android APK doesn't load reCAPTCHA

**Solution:**
- reCAPTCHA v3 works best in web builds
- For mobile, consider using `google_recaptcha` package
- For now, focus on web platform (Flutter for web)

---

## Production Deployment Checklist

- [ ] Site Key configured with production domain
- [ ] Secret Key stored in Firebase Remote Config (NOT in code)
- [ ] Cloud Function `verifyRecaptchaToken` implemented
- [ ] Firebase logging enabled for audit trail
- [ ] Alerts configured for suspicious login attempts
- [ ] Analytics dashboard created in reCAPTCHA Admin
- [ ] Rate limiting still active (defense in depth)
- [ ] Error messages user-friendly but don't leak info

---

## Key Files to Reference

| File | Purpose |
|------|---------|
| `lib/Services/RecaptchaService.dart` | reCAPTCHA token generation & scoring |
| `lib/Screens/login/login_screen.dart` | Login verification logic |
| `lib/Screens/settings/compose_email_screen.dart` | Email form verification |
| `web/index.html` | reCAPTCHA script injection |
| `RECAPTCHA_SETUP.md` | Full setup guide |
| `SECURITY.md` | Security standards documentation |

---

**Last Updated:** February 19, 2026
**Tested By:** GitHub Copilot
