# Bug: Usuario Recordado No Se Persiste Después de Logout + Restart

## El Problema Reportado
- ✅ Usuario hace **login** exitoso
- ✅ Usuario ve **HomePage** normalmente
- ❌ Usuario hace **logout** (Settings → Cerrar Sesión)
- ❌ Usuario **reinicia la app** (close + reopen OR hard refresh Cmd+Shift+R)
- ❌ **Resultado**: WelcomeScreen en lugar de LoginPage con usuario recordado
- ❌ **Síntoma en logs**: `lastUserEmail=null` en AuthWrapper._checkAuthState()

---

## Análisis del Flujo Esperado

### FASE 1: LOGIN (Debe guardar datos)
```
1. LoginScreen _submitLogin()
   ✅ Valida email/password
   ✅ Llama a ref.read(loginUserProvider.notifier).loginMailUser(email, password)
   
2. UserProviders.loginMailUser(email, password)
   ✅ Valida entrada
   ✅ Chequea rate limiting
   ✅ Intenta FirebaseAuth.signInWithEmailAndPassword()
   ✅ SI EXITOSO: Llama a _saveUserSecurely(user, email, password)
   
3. UserProviders._saveUserSecurely(user, email?, password?)
   ✅ Obtiene SharedPreferences instance
   ✅ Guarda: 'lastUserEmail', 'lastUserDisplayName', 'lastUserPhoto'
   ✅ VERIFICA que se guardó (leyendo de vuelta)
   ✅ Guarda credenciales encriptadas en SecureStorage
   ✅ Genera session token
```

**Logs esperados en consola después de login**:
```
🔐 [USER PROVIDER] loginMailUser() called for: email***
🔐 [USER PROVIDER] Attempting Firebase Auth with email...
✅ [USER PROVIDER] Firebase Auth successful, user UID: UID***
💾 [USER PROVIDER] Calling _saveUserSecurely()...
💾 [LOGIN] Saving user data to SharedPreferences...
✅ [LOGIN] SharedPreferences instance obtained
💾 [LOGIN] Step 1: Saving email...
✅ [LOGIN] Email saved: "user@example.com"
💾 [LOGIN] Step 2: Saving displayName...
✅ [LOGIN] DisplayName saved: "User Name"
💾 [LOGIN] Step 3: Saving photoURL...
✅ [LOGIN] Photo saved: ""
✅ [LOGIN] All SharedPreferences keys saved successfully
🔍 [LOGIN] Starting verification of saved data...
🔍 [LOGIN] Saved lastUserEmail: "user@example.com" (length=18)
🔍 [LOGIN] Verification complete - Saved and read back: email=user@example.com, displayName=User Name, photo=empty
💾 [LOGIN] Saving encrypted credentials to SecureStorage...
✅ [LOGIN] Saved encrypted credentials to SecureStorage
💾 [LOGIN] Generating session token...
✅ [LOGIN] Session token generated for user@example.com
🎉 [LOGIN] All user data saved successfully
✅ [USER PROVIDER] User data saved successfully
✅ [USER PROVIDER] Login attempts reset
🎉 [USER PROVIDER] Login complete, state updated to AsyncData
```

---

### FASE 2: LOGOUT (No debe limpiar SharedPreferences)
```
1. Settings → Click "Cerrar Sesión"
   ✅ Llama a ref.read(loginUserProvider.notifier).signOut()
   
2. UserProviders.signOut()
   ✅ Setter _isLoggingOut = true (previene updatess)
   ✅ State → AsyncData(null)
   ✅ Limpia SecureStorage (credenciales encriptadas)
   ✅ Invalida session token
   ⚠️ NO LIMPIA SharedPreferences (guardado de usuario recordado)
   ✅ Desconecta Google SignIn
   ✅ Cierra sesión de Firebase
```

**Logs esperados en consola tras logout**:
```
🚪 [LOGOUT] Starting logout process...
✅ [LOGOUT] State set to null
✅ [LOGOUT] Cleared encrypted data from SecureStorage
✅ [LOGOUT] Session token invalidated for: user@example.com
✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)
✅ [LOGOUT] Google SignIn disconnected (o fallback signOut)
✅ [LOGOUT] Firebase session closed
🎉 [LOGOUT] Session closed successfully
```

---

### FASE 3: RESTART APP (Debe encontrar usuario recordado)
```
1. AuthWrapper._checkAuthState()
   ⏳ Espera 8 segundos a que Firebase restaure sesión
   
   SI hay sesión de Firebase → HomePage (CASE 1)
   
   SI NO hay sesión:
   ✅ Obtiene SharedPreferences
   ✅ Lee 'lastUserEmail'
   ✅ SI NO está vacío → LoginPage (CASE 2) ← AQUÍ ES DONDE DEBE ENTRAR
   ✅ SI está vacío → WelcomeScreen (CASE 3) ← AQUÍ ES DONDE ESTÁS YENDO
```

**Logs esperados en consola tras restart**:
```
⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session...
(espera 8 segundos)
📝 [AUTH WRAPPER] Firebase session check completed
🌐 [AUTH WRAPPER] No active Firebase session found
ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences...
📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=user@example.com, displayName=User Name, photo=
✅ [AUTH WRAPPER] CASE 2: Remembered user found: user@example.com → Showing LoginPage
```

```
2. LoginScreen._loadRememberedUser()
   ✅ Obtiene SharedPreferences
   ✅ Lee 'lastUserEmail', 'lastUserDisplayName', 'lastUserPhoto'
   ✅ Valida que email no está vacío y contiene '@'
   ✅ Actualiza UI (mostrar tarjeta de usuario recordado)
```

---

## Dónde Está Fallando (Diagnóstico)

El hecho que ves `lastUserEmail=null` en AuthWrapper significa:

### ❌ OPCIÓN A: _saveUserSecurely() NUNCA se ejecutó
**Síntomas**: Los logs de _saveUserSecurely()

 NO aparecen después del login
- Esto ocurre si `loginMailUser()` falla ANTES de llamar a _saveUserSecurely()
- O si el widget se destruyó antes de completar la guardada

**Qué buscar**: ¿Ves logs tipo `"❌ [USER PROVIDER] FirebaseAuthException..."`?

### ❌ OPCIÓN B: _saveUserSecurely() falló silenciosamente
**Síntomas**: Ves los logs positivos al inicio, luego error
- `"💾 [LOGIN] Saving user data..."` ✅
- PERO LUEGO: `"❌ [LOGIN] Error saving user data: ..."`
- O ves: `"❌ [LOGIN] CRITICAL: Email was not saved!"`

**Qué buscar**: Un log de error que dice exactamente qué falló

### ❌ OPCIÓN C: SharedPreferences se limpia entre logout y restart
**Síntomas**: Logs correctos durante login/logout, pero después del restart está vacío
- El login guarda datos ✅
- El logout ve que están guardados ✅
- PERO después del restart desaparecen ❌

**Qué buscar**: ¿Algo en el código está limpiando SharedPreferences?

### ❌ OPCIÓN D: El flag _isLoggingOut está interfiriendo
**Síntomas**: El authStateChanges() listener no se ejecuta
- En _init(), el listener tiene: `if (!_isLoggingOut) { ... }`
- Si el flag no se resetea correctamente, podría prevenir que se guarden datos

**Qué buscar**: ¿El flag _isLoggingOut se resetea a false correctamente después del logout?

---

## Debugging Paso a Paso

### PASO 1: Verificar que login GUARDA datos
```
1. Abre la app en Chrome
2. Abre DevTools (F12)
3. Ve a Console tab
4. Ve a Welcome → Click "Entrar" → Login Screen
5. Ingresa email válido y contraseña
6. Click botón "Entrar"

DEBES VER en console:
✅ "💾 [LOGIN] Saving user data to SharedPreferences..."
✅ "✅ [LOGIN] Saved to SharedPreferences: email=..., displayName=..., photo=..."
✅ "🔍 [LOGIN] Verification - Saved and read back: email=..., displayName=..., photo=..."

SI NO VES ESTOS LOGS:
→ _saveUserSecurely() NO se está ejecutando
→ El problema está en loginMailUser() que probablemente está fallando antes

SI VES UN LOG DE ERROR como:
→ "❌ [LOGIN] CRITICAL: Email was not saved!"
→ El problema está en la guardada a SharedPreferences

SI NO VES LOGS DE _saveUserSecurely() PERO VES "Login complete":
→ El widget se destruyó antes de completar la guardada (widget disposal)
```

### PASO 2: Verificar que logout NO limpia los datos
```
1. Habiendo hecho login exitoso (paso anterior)
2. Ve a Settings
3. Click "Cerrar Sesión"
4. Confirma

DEBES VER en console:
✅ "🚪 [LOGOUT] Starting logout process..."
✅ "✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)"
✅ "🎉 [LOGOUT] Session closed successfully"

DESPUÉS del logout:
✅ Deberías estar en LoginPage o WelcomeScreen
⚠️ SI VES WelcomeScreen AQUÍ MISMO → El problema ocurrió en login (paso 1)
✅ SI VES LoginPage → Continúa al PASO 3
```

### PASO 3: Hard refresh y verificar usuario recordado
```
1. Estando en LoginPage (después del logout), presiona:
   Cmd+Shift+R (Chrome hard refresh en Mac)
   
2. La app debería:
   a) Mostrar loading brief
   b) AuthWrapper._checkAuthState() se ejecuta
   c) NO llama a Firebase (sesión cerrada)
   d) Busca en SharedPreferences
   
DEBES VER en console:
✅ "ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences..."
✅ "📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=USER@EXAMPLE.COM, displayName=USER_NAME, photo=..."
✅ "✅ [AUTH WRAPPER] CASE 2: Remembered user found: USER@EXAMPLE.COM → Showing LoginPage"

ENTONCES en LoginPage:
✅ Deberías ver tarjeta de usuario recordado (foto, nombre, email)
✅ "¿No eres tú?" button visible

SI VIENDO ESTO:
✅ "📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=null, displayName=null, photo=null"
✅ "🌟 [AUTH WRAPPER] CASE 3: No active session and no remembered user → Showing WelcomeScreen"

→ EL PROBLEMA: Los datos NUNCA se guardaron en paso 1
→ Ve de vuelta al PASO 1 y busca dónde falla _saveUserSecurely()
```

---

## Checklist de Revisión Rápida

```
✅ ¿LoginMailUser() se ejecuta hasta el final?
   Busca log: "🎉 [USER PROVIDER] Login complete, state updated to AsyncData"
   
✅ ¿_saveUserSecurely() completa sin errores?
   Busca log: "🎉 [LOGIN] All user data saved successfully"
   
✅ ¿La verificación de datos guardados es positiva?
   Busca log: "🔍 [LOGIN] Verification complete - Saved and read back: email=user@example.com"
   (email NO debe estar vacío)
   
✅ ¿Después de logout, SharedPreferences se preserva?
   Busca log: "✅ [LOGOUT] SharedPreferences preserved (remembered user will be available)"
   
✅ ¿Después del restart, AuthWrapper encuentra el usuario?
   Busca log: "✅ [AUTH WRAPPER] CASE 2: Remembered user found"
   (NO debe ver "CASE 3: No active session and no remembered user")
```

---

## Mapa de Ejecución con Flags

### El Flag _isLoggingOut (Potencial Problema)
```
_init() tiene un listener de authStateChanges():

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (!_isLoggingOut) {  ← IMPORTANTE: Solo ejecuta si NO estamos haciendo logout
      state = AsyncData(user);
      if (user != null) {
        _saveUserSecurely(user);  ← Solo guarda si NO hay logout en progreso
      }
    }
  });
```

**Flowchart**:
```
Login → _isLoggingOut = false
      → Firebase.signInWithEmailAndPassword()
      → authStateChanges() emite nuevo user
      → if (!_isLoggingOut) es TRUE
      → _saveUserSecurely(user) EJECUTA ✅

Logout → _isLoggingOut = true
       → Firebase.signOut()
       → authStateChanges() emite null
       → if (!_isLoggingOut) es FALSE
       → _saveUserSecurely() NO ejecuta ✅ (correcto, no queremos guardar null)
       
Restart → No hay listener activo de authStateChanges()
        → AuthWrapper._checkAuthState() busca en SharedPreferences
        → Debería encontrar los datos guardados en login
```

---

## Conclusión

El bug está en **UNA de estas ubicaciones**:

1. **LoginMailUser() no llama a _saveUserSecurely()**
   - Solución: Verificar que el flujo en loginMailUser() no retorna antes de llamar _saveUserSecurely()

2. **_saveUserSecurely() falla silenciosamente**
   - Solución: Ver si hay error en try-catch que no está siendo logueado

3. **SharedPreferences se limpia en signOut()**
   - Solución: Remover cualquier línea que haga prefs.clear() o prefs.remove()

4. **Widget disposal antes de completar_saveUserSecurely()**
   - Solución: Asegurar que mounted checks se usan correctamente

---

## Próximos Pasos

**Ejecuta los PASOS de debugging arriba y reporta**:
- ¿Qué logs exactos ves después de hacer login?
- ¿Ves todos los logs de _saveUserSecurely()?
- ¿Aparece algún log de ERROR?
- ¿Después del restart qué logs ves en CASE 2 vs CASE 3?

Con esa información podré identificar exactamente dónde está el problema.
