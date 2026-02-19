# 🔐 Guía de Configuración de reCAPTCHA v3

## Resumen

Este documento explica cómo configurar Google reCAPTCHA v3 para proteger contra bots la aplicación Aparcamientos Zaragoza.

---

## 📋 Tabla de Contenidos

1. [Crear Cuenta en Google reCAPTCHA](#crear-cuenta)
2. [Obtener Site Key y Secret Key](#obtener-llaves)
3. [Configurar Site Key en Frontend](#configurar-frontend)
4. [Configurar Secret Key en Backend](#configurar-backend)
5. [Verificar Servidor-side (Cloud Functions)](#verificar-servidor)
6. [Probar en Desarrollo](#probar)
7. [Desplegar en Producción](#produccion)

---

## 🔧 Crear Cuenta en Google reCAPTCHA {#crear-cuenta}

1. Ir a: https://www.google.com/recaptcha/admin
2. Hacer click en **"Create" / "Crear"**
3. Completar el formulario:
   - **Label** (Etiqueta): `Aparcamientos Zaragoza`
   - **reCAPTCHA type**: `reCAPTCHA v3`
   - **Domains** (Dominios):
     - `localhost` (desarrollo web local)
     - `aparcamientos.local` (desarrollo local)
     - `aparcamientos-zaragoza.com` (producción)
     - `www.aparcamientos-zaragoza.com` (producción con www)
4. Aceptar términos y hacer click **"Create"**
5. Google mostrará las claves (copiar ambas)

---

## 🔑 Obtener Site Key y Secret Key {#obtener-llaves}

Después de crear la aplicación en reCAPTCHA Admin, Google mostrará:

```
Site Key:   6LecWLsqAAAAAKKvMqSmAWPfYf0Nn5TYSbIqvf8l  (PÚBLICA)
Secret Key: 6LecWLsq...XXXXXXXXXXXXXXXXXXXX  (PRIVADA)
```

- **Site Key**: ✅ Seguro colocar en código frontend (es pública)
- **Secret Key**: ❌ NUNCA colocar en código (es privada)

---

## 🌐 Configurar Site Key en Frontend {#configurar-frontend}

### Paso 1: Actualizar `web/index.html`

```html
<!-- Actualizar esta línea con tu Site Key -->
<script src="https://www.google.com/recaptcha/api.js?render=YOUR_SITE_KEY"></script>
```

Reemplaza `YOUR_SITE_KEY` con tu Site Key real:

```html
<!-- ANTES (testing) -->
<script src="https://www.google.com/recaptcha/api.js?render=6LecWLsqAAAAAKKvMqSmAWPfYf0Nn5TYSbIqvf8l"></script>

<!-- DESPUÉS (producción) -->
<script src="https://www.google.com/recaptcha/api.js?render=6LecWLsqAAAAAKKvMqSmAWPfYf0Nn5TYSbIqvf8l"></script>
```

### Paso 2: Actualizar `lib/Services/RecaptchaService.dart`

Busca la línea:

```dart
static const String siteKey = 'YOUR_RECAPTCHA_SITE_KEY';
```

Reemplaza con tu Site Key:

```dart
static const String siteKey = '6LecWLsqAAAAAKKvMqSmAWPfYf0Nn5TYSbIqvf8l';
```

---

## 🔒 Configurar Secret Key en Backend {#configurar-backend}

⚠️ **NUNCA coloques la Secret Key en el código de la app**

### Opción 1: Firebase Remote Config (RECOMENDADO)

1. En Firebase Console: https://console.firebase.google.com
2. Ir a: **Remote Config**
3. Crear parámetro:
   - **Parameter name**: `recaptcha_secret_key`
   - **Value**: `6LecWLsq...XXXXXXXXXXXXXXXXXXXX`
   - **Default value**: (dejar vacío)
4. En Cloud Functions (backend):

```javascript
// functions/index.js
const admin = require('firebase-admin');
const fetch = require('node-fetch');

exports.verifyRecaptchaToken = functions.https.onCall(async (data, context) => {
  const remoteConfig = admin.remoteConfig();
  const template = await remoteConfig.getServerTemplate();
  
  const secretKey = template.parameters.recaptcha_secret_key.defaultValue.value;
  const token = data.token;
  const action = data.action;
  
  const response = await fetch('https://www.google.com/recaptcha/api/siteverify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `secret=${secretKey}&response=${token}`
  });
  
  const result = await response.json();
  return { success: result.success, score: result.score };
});
```

### Opción 2: Variables de Entorno en Cloud Functions

1. Crear archivo `functions/.env`:
```
RECAPTCHA_SECRET_KEY=6LecWLsq...XXXXXXXXXXXXXXXXXXXX
```

2. En `functions/index.js`:
```javascript
require('dotenv').config();
const secretKey = process.env.RECAPTCHA_SECRET_KEY;
```

3. Deploy:
```bash
firebase deploy --only functions
```

---

## ✅ Verificar Servidor-side (Cloud Functions) {#verificar-servidor}

⚠️ **CRÍTICO**: Siempre verifica tokens en el servidor, nunca en el cliente

### Implementar Cloud Function

Archivo: `functions/index.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

admin.initializeApp();

const RECAPTCHA_SECRET_KEY = process.env.RECAPTCHA_SECRET_KEY || 'YOUR_SECRET_KEY';

exports.verifyRecaptchaToken = functions.https.onCall(async (data, context) => {
  const { token, action } = data;
  
  if (!token || !action) {
    throw new functions.https.HttpsError('invalid-argument', 'Token and action required');
  }
  
  try {
    // Llamar a la API de reCAPTCHA
    const response = await fetch('https://www.google.com/recaptcha/api/siteverify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `secret=${RECAPTCHA_SECRET_KEY}&response=${token}`
    });
    
    const result = await response.json();
    
    // Validar respuesta
    if (!result.success) {
      throw new Error('reCAPTCHA verification failed');
    }
    
    // Verificar que la acción sea correcta
    if (result.action !== action) {
      throw new Error('Action mismatch');
    }
    
    // Retornar puntuación y decisión
    return {
      success: true,
      score: result.score,
      action: result.action,
      challenge_ts: result.challenge_ts,
      isPossibleBot: result.score < 0.3,
      requiresVerification: result.score < 0.5,
    };
  } catch (error) {
    console.error('reCAPTCHA verification error:', error);
    throw new functions.https.HttpsError('internal', 'Verification failed');
  }
});
```

### Desplegar:

```bash
cd functions
npm install
firebase deploy --only functions
```

---

## 🧪 Probar en Desarrollo {#probar}

### 1. Compilar en Web

```bash
flutter run -d chrome
```

### 2. Abrir Consola del Navegador (F12)

Buscar logs:
```
✅ reCAPTCHA token obtained for action: login
🎯 reCAPTCHA score (test): 0.85
```

### 3. Probar Login

- Ir a pantalla de Login
- Intentar login (verificará reCAPTCHA)
- Ver logs: "✅ Verificación reCAPTCHA exitosa"

### 4. Probar Contacto

- Ir a Settings > Compose Email
- Escribir mensaje y enviar
- Ver logs: "✅ Verificación reCAPTCHA exitosa para contacto"

### 5. Simular Bot (testing)

En `lib/Services/RecaptchaService.dart`, cambiar umbral temporalmente:

```dart
// Cambiar de:
static const double highRiskThreshold = 0.3;
// A:
static const double highRiskThreshold = 0.9;
```

Intentar login → Debe mostrar "Se detectó actividad de bot"

Revertir cambio después del test.

---

## 🚀 Desplegar en Producción {#produccion}

### Checklist de Producción

- [ ] Site Key configurada en `web/index.html` (versión de producción)
- [ ] Site Key configurada en `RecaptchaService.dart`
- [ ] Secret Key guardada en Firebase Remote Config (NO en código)
- [ ] Cloud Function `verifyRecaptchaToken` implementada y desplegada
- [ ] Dominios configurados en Google reCAPTCHA Admin
- [ ] Testing completado en Chrome y Android
- [ ] Logs de seguridad habilitados en Firebase
- [ ] Alertas configuradas para intentos bloqueados

### Comandos de Despliegue

```bash
# 1. Compilar para web
flutter build web

# 2. Desplegar Cloud Functions
cd functions
firebase deploy --only functions

# 3. Desplegar con Firebase Hosting
firebase deploy

# 4. Verificar logs
firebase functions:log
```

---

## 📊 Monitorear reCAPTCHA

En Google reCAPTCHA Admin:

1. Click en tu aplicación
2. Ver sección **"Analytics"**:
   - Traffic: Intentos totales
   - Score distribution: Distribución de scores
   - Requests by action: Login, Register, Contact, Comment
   - Top threats detected

---

## 🔗 Enlaces Útiles

- [Google reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin)
- [reCAPTCHA v3 Documentation](https://developers.google.com/recaptcha/docs/v3)
- [Verification API Docs](https://developers.google.com/recaptcha/docs/verify)
- [Firebase Remote Config Docs](https://firebase.google.com/docs/remote-config)
- [Firebase Cloud Functions Guide](https://firebase.google.com/docs/functions)

---

## ⚠️ Seguridad

- **NUNCA** compartas tu Secret Key en repositorios públicos
- **SIEMPRE** verifica tokens en el servidor (Cloud Functions)
- Usa Firebase Remote Config para Secret Key (no en código)
- Monitorea intentos bloqueados en Google reCAPTCHA Analytics
- Implementa logging de intentos fallidos en Firestore
- Considera integrar 2FA cuando score esté en zona de riesgo medio (0.3-0.5)

---

**Última actualización**: 19 de febrero de 2026
**Responsable**: Copilot
