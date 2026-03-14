# 🐛 DEBUGGING RÁPIDO: Usuario Recordado No Persiste - Guía de Logs

## Problema
**Después de logout + restart, el usuario no se recuerda**
- Esperado: LoginPage con tarjeta "¿No eres tú?"
- Real: WelcomeScreen (usuario olvidado)

---

## ⚡ TEST RÁPIDO (3 MINUTOS)

### PASO 1: Login y Observar Logs
```bash
1. Abrir app en Chrome
2. Presionar F12 → Console
3. LIMPIAR consola (Ctrl+L)
4. Navegar: Welcome → Entrar → Rellenar credenciales válidas
5. Presionar "Entrar"
6. VER LOGS que deberían aparecer en orden:

   BUSCAR ESTOS LOGS en orden:
   ✅ "🔐 [USER PROVIDER] loginMailUser() called"
   ✅ "🔐 [USER PROVIDER] Attempting Firebase Auth"
   ✅ "✅ [USER PROVIDER] Firebase Auth successful"
   ✅ "💾 [USER PROVIDER] Calling _saveUserSecurely()"
   ✅ "💾 [LOGIN] Saving user data to SharedPreferences..."
   ✅ "✅ [LOGIN] Email saved: "user@example.com""
   ✅ "✅ [LOGIN] All SharedPreferences keys saved successfully"
   ✅ "🔍 [LOGIN] Verification complete - Saved and read back..."
```

**Si VES todos estos logs:**
→ El login y guardado funcionan correctamente
→ Ir al PASO 2

**Si NO ves algunos logs o ves ❌ errores:**
→ El problema está en login/guardado
→ NOTA: qué logs faltan exactamente
→ Ir a SECCIÓN "DIAGNÓSTICO A" abajo

---

### PASO 2: Logout y Observar Logs
```bash
1. En HomePage, ir a Settings
2. Presionar "Cerrar Sesión"
3. VER LOGS que deberían aparecer:

   ✅ "🚪 [LOGOUT] Starting logout process"
   ✅ "✅ [LOGOUT] SharedPreferences preserved"
   ✅ "🎉 [LOGOUT] Session closed successfully"

4. Después de logout:
   - ¿Estás en LoginPage?
   - ¿Ves la tarjeta "¿No eres tú?" con el email?
```

**Si VES tarjeta "¿No eres tú?" con email:**
→ El usuario fue recordado correctamente
→ Ir al PASO 3

**Si NO ves tarjeta:**
→ El problema es en la CARGA del usuario recordado
→ NOTA: qué logs viste
→ Ir a SECCIÓN "DIAGNÓSTICO B"

---

### PASO 3: Restart y Observar Logs
```bash
1. Presionar Cmd+Shift+R (hard refresh) o cerrar Chrome completamente
2. Esperar a que la app cargue
3. VER LOGS que deberían aparecer:

   ✅ "[AUTH WRAPPER] Iniciando verificación..."
   ✅ "[AUTH WRAPPER] SharedPreferences check: lastUserEmail=..."
   ✅ "[AUTH WRAPPER] CASE 2: Remembered user found"
   ✅ "Mostrando LoginPage con usuario recordado"

4. ¿Qué pantalla ves?
   - LoginPage con tarjeta "¿No eres tú?" = ✅ ARREGLADO
   - WelcomeScreen = ❌ AÚN ROTO
```

**Si ves LoginPage con tarjeta "¿No eres tú?":**
→ El problema se ha solucionado 🎉

**Si ves WelcomeScreen:**
→ Ir a SECCIÓN "DIAGNÓSTICO C"

---

## 🔍 DIAGNÓSTICO RÁPIDO - Qué Significa Cada Log

### Logs de LOGIN (deben aparecer en este orden):

| Log | Significa | Si FALTA |
|-----|-----------|----------|
| `🔐 [USER PROVIDER] loginMailUser() called` | El usuario presionó "Entrar" | No llegó a login |
| `🔐 Attempting Firebase Auth` | Se intenta conectar a Firebase | Problema de red |
| `✅ Firebase Auth successful` | Login en Firebase funcionó | Credenciales inválidas |
| `💾 Calling _saveUserSecurely()` | Comienza a guardar datos | Error en auth |
| `💾 [LOGIN] Saving to SharedPreferences` | Obtiene instancia de SharedPreferences | SharedPreferences error |
| `✅ All keys saved successfully` | Los datos se guardaron | Falló al guardar |
| `🔍 Verification complete` | Se verificó que quedó guardado | Datos no se guardaron |

### Logs de LOGOUT (deben aparecer):

| Log | Significa |
|-----|-----------|
| `🚪 [LOGOUT] Starting logout` | Comenzó logout |
| `✅ SharedPreferences preserved` | Se MANTIENE (good!) |
| `🎉 Session closed` | Firebase session cerrada |

### Logs de RESTART (deben aparecer):

| Log | Significa |
|-----|-----------|
| `[AUTH WRAPPER] Iniciando verificación` | AuthWrapper ejecutándose |
| `SharedPreferences check: lastUserEmail=...` | Lee las claves |
| `CASE 2: Remembered user found` | ¡Lo encontró! |
| `[AUTH WRAPPER] Mostrando LoginPage` | Debería mostrar LoginPage |

---

## 🎯 DIAGNÓSTICO A: Falla en LOGIN/GUARDADO

**Síntoma**: Los logs de login no aparecen o aparecen con ❌

```
Posibles causas:

1️⃣  El usuario presionó "Entrar" pero FirebaseAuth falló
   → Revisar credenciales
   → Revisar conexión de red
   → ¿Aparece "❌ [USER PROVIDER] FirebaseAuthException"?

2️⃣  FirebaseAuth funcionó pero _saveUserSecurely() no
   → Revisar si "💾 [LOGIN] Saving to SharedPreferences" aparece
   → Si NO aparece: widget destruido antes de guardar
   → Si SÍ aparece pero sin verificación: error en SharedPreferences

3️⃣  SharedPreferences falla
   → ¿Aparece "❌ [LOGIN] CRITICAL: Email was not saved"?
   → En web: problema de localStorage/cookies
   → En mobile: problema de permisos (unlikely pero posible)
```

**Solución:**
- Verificar credenciales son correctas
- Revisar conexión internet
- Ver consola del navegador para excepciones (no logs de app)

---

## 🎯 DIAGNÓSTICO B: Falla en CARGA de Usuario Recordado

**Síntoma**: Después de logout, NO ves tarjeta "¿No eres tú?"

```
Significa: LoginScreen._loadRememberedUser() no encontró datos

Posibles causas:

1️⃣  Los datos NO se guardaron en login
   → Volver a PASO 1: revisar si guardado funcionó

2️⃣  Los datos se guardaron PERO no se cargan en LoginScreen
   → ¿Aparece algún log en LoginScreen?
   → Revisar: "📝 [LOGIN SCREEN] Checking for remembered user"
   →
 Si NO aparece: LoginScreen.initState() no ejecutó _loadRememberedUser()
   → Si SÍ aparece: revisar el siguiente

3️⃣  Los datos se leen pero no se validan
   → ¿Aparece "❌ No valid remembered user"?
   → Significa email guardado es inválido (vacío o no contiene @)
   → Esto sugiere que user.email era null después de Firebase login
```

**Solución:**
- Verificar que email se guardó correctamente (revisar PASO 1)
- Si está guardado correctamente pero no valida: revisar formato del email

---

## 🎯 DIAGNÓSTICO C: Falla en RESTART

**Síntoma**: Después de restart, SharedPreferences dice `lastUserEmail=null`

```
Significa: Los datos que se guardaron NO persisten después de restart

Posibles causas:

1️⃣  Datos NUNCA se guardaron (problema en login)
   → Volver a PASO 1 y PASO 2

2️⃣  Datos se guardaron pero se BORRARON después
   → ¿Presionaste "No soy yo" después de logout?
   → Ese botón limpia SharedPreferences (por diseño)
   →  Si es eso, es correcto

3️⃣  AuthWrapper no lee las claves correctamente
   → Revisar logs en restart: qué dice exactamente de SharedPreferences?
   → Si dice "lastUserEmail=null": datos no están en SharedPreferences
   → Si dice "lastUserEmail=user@example.com": sí están
```

**Solución:**
- No presionar "No soy tú" si quieres probar
- Ir a Developer Tools → Application → Cookies → Buscar SharedPreferences/localStorage
- Verificar manualmente si las claves están allí

---

## 💡 EJEMPLO COMPLETO DE LOGS BUENOS

Cuando TODO funciona correctamente, deberías ver esto:

```
// PASO 1: LOGIN
🔐 [USER PROVIDER] loginMailUser() called for: user***
🔐 [USER PROVIDER] Attempting Firebase Auth with email...
✅ [USER PROVIDER] Firebase Auth successful, user UID: abc12345***
💾 [USER PROVIDER] Calling _saveUserSecurely() to save remembered user...
💾 [LOGIN] Saving user data to SharedPreferences...
📋 [LOGIN] Starting with user: email=user@example.com, displayName=John Doe, photoURL=https://...
✅ [LOGIN] SharedPreferences instance obtained
💾 [LOGIN] Step 1: Saving email...
✅ [LOGIN] Email saved: "user@example.com"
💾 [LOGIN] Step 2: Saving displayName...
✅ [LOGIN] DisplayName saved: "John Doe"
💾 [LOGIN] Step 3: Saving photoURL...
✅ [LOGIN] Photo saved: "https://..."
✅ [LOGIN] All SharedPreferences keys saved successfully
🔍 [LOGIN] Starting verification of saved data...
🔍 [LOGIN] Saved lastUserEmail: "user@example.com" (length=17)
🔍 [LOGIN] Saved lastUserDisplayName: "John Doe" (length=8)
🔍 [LOGIN] Saved lastUserPhoto: "https://..." (length=45)
🔍 [LOGIN] Verification complete - Saved and read back: email=user@example.com, displayName=John Doe, photo=loaded
✅ [USER PROVIDER] User data saved successfully
✅ [USER PROVIDER] Login attempts reset
🎉 [USER PROVIDER] Login complete, state updated to AsyncData

// PASO 2: LOGOUT
🚪 [LOGOUT] Starting logout process...
✅ [LOGOUT] SecureStorage cleared + session token invalidated
✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)
🎉 [LOGOUT] Session closed successfully

// Después de logout, aparecen estos logs en LoginScreen:
📝 [LOGIN SCREEN] Checking for remembered user...
📋 [LOGIN SCREEN] SharedPreferences contains: email=user@example.com, displayName=John Doe, photo=https://...
✅ [LOGIN SCREEN] Valid remembered user loaded: user@example.com

// PASO 3: RESTART (Cmd+Shift+R)
📝 [AUTH WRAPPER] Iniciando verificación de estado...
✅ [AUTH WRAPPER] Esperando a Firebase...
📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=user@example.com, displayName=John Doe, photo=https://...
✅ [AUTH WRAPPER] CASE 2: Remembered user found: user@example.com →
 Showing LoginPage
🎉 [AUTH WRAPPER] HomePage aún no disponible (Firebase session no restaurada)
```

---

## 📋 CHECKLIST - Qué Revisar en la Consola

- [ ] ¿Aparecen logs con emojis (🔐, 💾, ✅, etc.)?
  - Si NO: SecurityService.secureLog() no funciona o console.log está filtrado
- [ ] ¿Aparecen logs de "USER PROVIDER"?
  - Si NO: loginMailUser() nunca se llamó
- [ ] ¿Aparecen logs de "CRITICAL" o "ERROR" (❌)?
  - Si SÍ: hay una excepción, necesitas ver el detalle
- [ ] ¿Después de logout ves logs de "LOGIN SCREEN"?
  - Si NO: initState() no ejecutó _loadRememberedUser() o fue destruido
- [ ] ¿Los logs de verificación (🔍) muestran datos non-vacíos?
  - Si SÍ: datos se guardaron correctamente
  - Si NO: datos no se guardaron

---

## 🚀 Próximo Paso

Una vez ejecutes estos PASOS 1-3 y veas los logs:

1. **Si funcionó en PASO 1-2 pero falló en PASO 3:**
   - El problema es en la PERSISTENCIA entre restart
   - Revisar Developer Tools → Application → Local Storage o SessionStorage
   - Buscar claves 'lastUserEmail', 'lastUserDisplayName', 'lastUserPhoto'
   - ¿Están ahí? Si no: SharedPreferences no persiste en web
   - Si sí: AuthWrapper no las lee correctamente

2. **Si falló en PASO 1:**
   - El problema es en login/guardado
   - Ver qué logs faltan exactamente
   - Revisar credenciales y conexión de red

3. **Si falló en PASO 2:**
   - Problema raro: logout parece exitoso pero datos no quedan
   - Revisar si "SharedPreferences preserved" realmente aparece
   - Ver si algo las limpia en signOut()

---

## 🎯 Última Opción: Verificar a Mano

Si los logs no aparecen (¿SecurityService deshabilitado?):

```javascript
// En consola del navegador (F12), ejecuta:
await (await import('package:shared_preferences/shared_preferences.dart')).SharedPreferences.getInstance().then(p => {
  console.log('lastUserEmail:', p.getString('lastUserEmail'));
  console.log('lastUserDisplayName:', p.getString('lastUserDisplayName'));
  console.log('lastUserPhoto:', p.getString('lastUserPhoto'));
});
```

O más simple, en Chrome DevTools:
```
Application → Cookies → [sitio]
Buscar "prefs_" o "flutter_"
Ver si hay claves con "lastUser"
```

---

## 💬 Reporta Con:

Cuando reportes el problema, incluye:

```
PASO 1 - Login logs:
[Pega los logs aquí, especialmente desde 🔐 hasta 🎉]

PASO 2 - Logout logs:
[Pega los logs aquí, especialmente desde 🚪 hasta 🎉]
¿Apareció tarjeta "¿No eres tú?"? SI / NO

PASO 3 - Restart logs:
[Pega los logs aquí, especialmente desde AUTH WRAPPER]
¿Qué pantalla viste? WelcomeScreen / LoginPage / HomePage

¿Viste algún error (❌) o exception?
[SÍ / NO] - Si sí, pega el error exacto
```

Esto nos permitirá identificar exactamente dónde falla.

---

**Fecha**: Marzo 14, 2026
**Agente**: GitHub Copilot
**Sesión**: Debugging de Usuario Recordado
