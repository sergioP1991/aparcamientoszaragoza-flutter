# 📝 Remembered User Debug Guide

**Objetivo**: Rastrear por qué el usuario recordado se pierde después de logout + app reload.

**Estado**: ✅ Comprehensive logging agregado en todos los puntos críticos

---

## 📊 Puntos de Logging Agregados

### 1. **Login Screen - initState()** 🚀
- **Archivo**: `lib/Screens/login/login_screen.dart` líneas 75-79
- **Logs**:
  - `🚀 [LOGIN SCREEN] initState() called` - Se llamó initState
  - `✅ [LOGIN SCREEN] initState() completed` - Se completó initState
- **Propósito**: Confirmar que LoginPage está siendo creada e inicializada

### 2. **Login Screen - _loadRememberedUser()** 📝
- **Archivo**: `lib/Screens/login/login_screen.dart` líneas 87-120
- **Logs**:
  - `📝 [LOGIN SCREEN] Checking for remembered user...` - Inicia búsqueda
  - `📋 [LOGIN SCREEN] SharedPreferences contains: email=$email, displayName=$displayName` - Estado de SharedPreferences
  - `✅ [LOGIN SCREEN] Remembered user loaded: $email` - Usuario encontrado y cargado
  - `❌ [LOGIN SCREEN] No remembered user found in SharedPreferences` - Usuario NO encontrado
  - `⚠️ [LOGIN SCREEN] Error loading remembered user: ...` - Error durante lectura
- **Propósito**: Ver si SharedPreferences tiene datos cuando LoginPage.initState() corre

### 3. **Home Screen - Logout Button** 🏠
- **Archivo**: `lib/Screens/home/home_screen.dart` líneas 217-230
- **Logs**:
  - `🏠 [HOME SCREEN] Logout button tapped` - Usuario clickeó logout
  - `🏠 [HOME SCREEN] signOut() completed, navigating to login...` - signOut() terminó
  - `🏠 [HOME SCREEN] Navigation to /login-page completed` - Navegación a LoginPage completada
- **Propósito**: Rastrear el flujo desde logout hasta navegación

### 4. **User Providers - signOut()** 🚪
- **Archivo**: `lib/Screens/login/providers/UserProviders.dart` líneas 157-208
- **Logs**:
  - `🚪 [LOGOUT] Starting logout process...` - Inicia logout
  - `✅ [LOGOUT] State set to null` - Estado puesto a null
  - `✅ [LOGOUT] Cleared encrypted data from SecureStorage` - SecurityService limpiado
  - `✅ [LOGOUT] Session token invalidated for: $email` - Token invalidado
  - `✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)` - **CRÍTICO**: confirma que SharedPreferences NO fue borrado
  - `✅ [LOGOUT] Google SignIn disconnected` - Google desconectado
  - `✅ [LOGOUT] Firebase session closed` - Firebase cerrado
  - `🎉 [LOGOUT] Session closed successfully` - Logout completado
- **Propósito**: Verificar que SharedPreferences está siendo preservado en signOut()

### 5. **User Providers - _saveUserSecurely()** 💾
- **Archivo**: `lib/Screens/login/providers/UserProviders.dart` líneas 164-190
- **Logs**:
  - `💾 [LOGIN] Saving user data to SharedPreferences...` - Inicia guardado
  - `✅ [LOGIN] Saved to SharedPreferences: email=$email, displayName=$displayName` - Datos guardados en SharedPreferences
  - `✅ [LOGIN] Saved encrypted credentials to SecureStorage` - Credenciales encriptadas guardadas
  - `✅ [LOGIN] Session token generated` - Token de sesión generado
  - `🎉 [LOGIN] All user data saved successfully` - Todos los datos guardados
  - `❌ [LOGIN] Error saving user data: ...` - Error durante guardado
- **Propósito**: Confirmar que los datos se guardan correctamente en login

### 6. **Auth Wrapper - _checkAuthState()** 🔐
- **Archivo**: `lib/Screens/auth_wrapper.dart` líneas 36-105
- **Logs**:
  - `🔐 [AUTH WRAPPER] Starting auth state check...` - Inicia verificación
  - `⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session...` - Espera a Firebase
  - `⏱️ [AUTH WRAPPER] Firebase restore timeout reached` - Timeout alcanzado
  - `⚠️ [AUTH WRAPPER] Error waiting for authStateChanges: ...` - Error en stream de Firebase
  - `ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences...` - Firebase vacío, verifica SharedPreferences
  - `📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=$email, displayName=$displayName, photo=$photo` - Estado de SharedPreferences
  - `✅ [AUTH WRAPPER] CASE 1: Active Firebase session found for $email → Showing Home` - Sesión activa
  - `✅ [AUTH WRAPPER] CASE 2: Remembered user found: $email → Showing LoginPage` - Mencionó usuario encontrado
  - `🌟 [AUTH WRAPPER] CASE 3: No active session and no remembered user → Showing WelcomeScreen` - Sin datos
  - `❌ [AUTH WRAPPER] Unexpected error during auth check: ...` - Error inesperado
- **Propósito**: Mostrar qué pantalla se está mostrando y por qué

---

## 🧪 Cómo Testear

### Test 1: Verificar que _saveUserSecurely() Guarda los Datos ✅

```bash
1. flutter run -d chrome
2. Abrir DevTools en la app (F12 en navegador)
3. Ir a Console
4. Click "Entrar" en welcome screen
5. Ingresar email + password
6. Click "Entrar"
7. Verifica logs en console:
   ✅ 💾 [LOGIN] Saving user data...
   ✅ ✅ [LOGIN] Saved to SharedPreferences: email=...
   ✅ 🎉 [LOGIN] All user data saved successfully
```

**Resultado esperado**: 
- SharedPreferences contiene: `lastUserEmail`, `lastUserDisplayName`, `lastUserPhoto`
- Deberías estar logueado en Home

---

### Test 2: Verificar que signOut() Preserva SharedPreferences ✅

```bash
1. Estando logueado en Home (desde Test 1)
2. Click en logout button (círculo de usuario arriba)
3. Verifica logs:
   ✅ 🏠 [HOME SCREEN] Logout button tapped
   ✅ 🚪 [LOGOUT] Starting logout process...
   ✅ ✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)
   ✅ 🎉 [LOGOUT] Session closed successfully
   ✅ 🏠 [HOME SCREEN] Navigation to /login-page completed
```

**Resultado esperado**:
- Estás en LoginPage
- Deberías ver "¿No eres tú?" button con tu email
- Log `✅ [LOGOUT] SharedPreferences preserved` confirma que NO fue borrado

---

### Test 3: Verificar que AuthWrapper Encuentra el Usuario Recordado 🔐

```bash
1. Estando en LoginPage (desde Test 2, con usuario recordado)
2. Cerrar COMPLETAMENTE el navegador (Cmd+Q en Mac)
3. Reabre el navegador y vuelve a Flutter app
4. Verifica logs en console:
   ✅ 🔐 [AUTH WRAPPER] Starting auth state check...
   ✅ ⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session...
   Espera ~8 segundos
   ✅ ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences...
   ✅ 📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=$email...
   ✅ ✅ [AUTH WRAPPER] CASE 2: Remembered user found: $email → Showing LoginPage
```

**Resultado esperado**:
- AuthWrapper muestra LoginPage (no Welcome)
- SharedPreferences check muestra `lastUserEmail=$email`
- Log CASE 2 confirma que se encontró usuario recordado

---

### Test 4: Verificar que LoginScreen._loadRememberedUser() Carga el Usuario ✅

```bash
1. Mismo punto que Test 3 (App reabierta, en AuthWrapper)
2. Continúa viendo los logs:
   ✅ 🚀 [LOGIN SCREEN] initState() called
   ✅ 📝 [LOGIN SCREEN] Checking for remembered user...
   ✅ 📋 [LOGIN SCREEN] SharedPreferences contains: email=$email, displayName=...
   ✅ ✅ [LOGIN SCREEN] Remembered user loaded: $email
   ✅ ✅ [LOGIN SCREEN] initState() completed
```

**Resultado esperado**:
- LoginPage.initState() se llamó
- _loadRememberedUser() leyó SharedPreferences
- Usuario recordado se cargó y se mostró en la UI (deberías ver "¿No eres tú?" button)

---

## 🔍 Diagrama de Flujo Esperado

```
Test 2: Logout
├─ Home Screen
│  └─ Click Logout Button
│     ├─ 🏠 [HOME SCREEN] Logout button tapped
│     └─ signOut() called
│        ├─ 🚪 [LOGOUT] Starting logout process...
│        ├─ ✅ [LOGOUT] State set to null
│        ├─ ✅ [LOGOUT] Cleared encrypted data from SecureStorage
│        ├─ ✅ [LOGOUT] [LOGOUT] SharedPreferences preserved ← CLAVE
│        ├─ ✅ [LOGOUT] Firebase session closed
│        └─ 🎉 [LOGOUT] Session closed successfully
│     └─ Navigate to '/login-page'
│        ├─ 🏠 [HOME SCREEN] Navigation to /login-page completed
│        └─ LoginPage created
│           ├─ initState() called
│           ├─ 🚀 [LOGIN SCREEN] initState() called
│           └─ _loadRememberedUser() called
│              ├─ 📝 [LOGIN SCREEN] Checking for remembered user...
│              ├─ 📋 [LOGIN SCREEN] SharedPreferences check: email=$email
│              └─ ✅ [LOGIN SCREEN] Remembered user loaded: $email
└─ LoginPage with remembered user displayed

Test 3/4: App Reload
├─ App closes completely (user task kills it)
├─ App reopens
│  └─ AuthWrapper._checkAuthState()
│     ├─ 🔐 [AUTH WRAPPER] Starting auth state check...
│     ├─ ⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session...
│     ├─ ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences...
│     ├─ 📝 [AUTH WRAPPER] SharedPreferences check: email=$email (← SI está aquí = usuario recordado existe)
│     └─ ✅ [AUTH WRAPPER] CASE 2: Remembered user found: $email → Showing LoginPage
│        └─ LoginPage.initState()
│           ├─ 🚀 [LOGIN SCREEN] initState() called
│           └─ _loadRememberedUser()
│              ├─ 📋 [LOGIN SCREEN] SharedPreferences contains: email=$email
│              └─ ✅ [LOGIN SCREEN] Remembered user loaded: $email
└─ LoginPage with remembered user displayed ✅
```

---

## 🐛 Debugging por Scenario

### Scenario A: Usuario recordado NO Se Muestra Después de Logout

**Posible Causa**: SharedPreferences está siendo borrado en signOut()

**Cómo debug**:
```
1. En Test 2, busca:
   ✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)
   
   Si NO está este log → signOut() está borrando SharedPreferences (BUG)
   Si SÍ está → SharedPreferences se preservó correctamente (goto Scenario B)
```

### Scenario B: SharedPreferences Preservado pero Usuario NO Se Carga en LoginPage

**Posible Causa**: _loadRememberedUser() no está siendo llamado o SharedPreferences está vacío

**Cómo debug**:
```
1. En Test 4, busca:
   ❌ [LOGIN SCREEN] No remembered user found in SharedPreferences
   
   Si ves este log → SharedPreferences ESTÁ VACÍO (BUG: perdido entre logout y reload)
   Si NO lo ves → BUG diferente (goto Scenario C)
```

### Scenario C: _loadRememberedUser() Cargó Usuario Pero UI No Muestra "¿No eres tú?"

**Posible Causa**: setState() no se ejecutó o cambio de estado no se reflejó

**Cómo debug**:
```
1. En Test 4, busca:
   ✅ [LOGIN SCREEN] Remembered user loaded: $email
   
   Si ves este log → Usuario se cargó en memoria
   
2. Pero en UI no ves "¿No eres tú?" button → setState() problema o UI rendering
```

### Scenario D: Logs Muestran TODO Bien Pero App Va a WelcomeScreen

**Posible Causa**: AuthWrapper._checkAuthState() devolviendo WelcomeScreen en lugar de LoginPage

**Cómo debug**:
```
1. En Test 3, busca exactamente estas dos líneas:
   ✅ [AUTH WRAPPER] CASE 2: Remembered user found: $email
   
   Si NO ves CASE 2 → Ves CASE 3 (No remembered user)
   Si ves CASE 3 → SharedPreferences fue borrado ENTRE logout y reload (race condition)
```

---

## 📋 Checklist de Debugging

Ejecuta los tests en orden y marca lo que funciona:

- [ ] Test 1: _saveUserSecurely() guarda datos en SharedPreferences
- [ ] Test 2: signOut() preserva SharedPreferences (log "SharedPreferences preserved")
- [ ] Test 2: LoginPage se muestra después de logout
- [ ] Test 3/4: AuthWrapper detecta usuario recordado después de reload
- [ ] Test 3/4: AuthWrapper muestra LoginPage (no WelcomeScreen)
- [ ] Test 4: LoginScreen._loadRememberedUser() carga usuario
- [ ] Test 4: "¿No eres tú?" button se muestra en UI

---

## 🎯 Conclusiones

### Si Todo Funciona (todos los tests pasan):
- El usuario recordado se guarda correctamente en login
- Se preserva correctamente en logout
- Se restaura correctamente después de reload de app
- **Conclusión**: Feature está funcionando correctamente, el problema reportado NO se reproduce

### Si Algo Falla:
1. **Busca en logs el tipo de error**
2. **Compara con el diagrama de flujo esperado**
3. **Identifica en qué paso el log desaparece**
4. **Ese es el lugar donde el bug está ocurriendo**

---

## 📄 Ejemplo de Log Esperado Completo

```
[Logout]
🏠 [HOME SCREEN] Logout button tapped
🚪 [LOGOUT] Starting logout process...
✅ [LOGOUT] State set to null
✅ [LOGOUT] Cleared encrypted data from SecureStorage
✅ [LOGOUT] Session token invalidated for: user@example.com
✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)
✅ [LOGOUT] Google SignIn disconnected
✅ [LOGOUT] Firebase session closed
🎉 [LOGOUT] Session closed successfully
🏠 [HOME SCREEN] signOut() completed, navigating to login...
🚀 [LOGIN SCREEN] initState() called
📝 [LOGIN SCREEN] Checking for remembered user...
📋 [LOGIN SCREEN] SharedPreferences contains: email=user@example.com, displayName=John Doe
✅ [LOGIN SCREEN] Remembered user loaded: user@example.com
✅ [LOGIN SCREEN] initState() completed
🏠 [HOME SCREEN] Navigation to /login-page completed

[After App Reload]
🔐 [AUTH WRAPPER] Starting auth state check...
⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session...
ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences...
📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=user@example.com, displayName=John Doe, photo=...
✅ [AUTH WRAPPER] CASE 2: Remembered user found: user@example.com → Showing LoginPage
🚀 [LOGIN SCREEN] initState() called
📝 [LOGIN SCREEN] Checking for remembered user...
📋 [LOGIN SCREEN] SharedPreferences contains: email=user@example.com, displayName=John Doe
✅ [LOGIN SCREEN] Remembered user loaded: user@example.com
✅ [LOGIN SCREEN] initState() completed
```

---

**Última actualización**: 13 de marzo de 2026  
**Agente**: GitHub Copilot
