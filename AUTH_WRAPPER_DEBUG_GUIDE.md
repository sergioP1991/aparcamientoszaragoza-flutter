# Auth Wrapper - Debugging Session Save Issue

## El Problema
AuthWrapper no rememDa la sesión del usuario después de hacer logout:
```
[DEBUG] 📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=null, displayName=null, photo=null
[DEBUG] 🌟 [AUTH WRAPPER] CASE 3: No active session and no remembered user → Showing WelcomeScreen
```

## Hipótesis: Los Datos NUNCA se Guardaron Después del Login

### Verificaciones Necesarias

**1. Buscar Logs de _saveUserSecurely()**
```bash
# En la consola después de hacer login, deberías ver:
# "💾 [LOGIN] Saving user data to SharedPreferences..."
# "✅ [LOGIN] Saved to SharedPreferences: email=..., displayName=..., photo=..."
# "🔍 [LOGIN] Verification - Saved and read back: email=..., displayName=..., photo=..."

# Si NO ves estos logs, _saveUserSecurely() nunca se ejecutó
# Si ves logs pero los valores están vacíos ("photo=empty"), hay un problema
```

**2. Verificar LoginMailUser Completó Exitosamente**
```bash
# Deberías ver en consola:
# "🔐 [USER PROVIDER] loginMailUser() called for: email***"
# "✅ [USER PROVIDER] Firebase Auth successful, user UID: UID***"
# "💾 [USER PROVIDER] Calling _saveUserSecurely() to save remembered user..."
# "✅ [USER PROVIDER] User data saved successfully"
# "🎉 [USER PROVIDER] Login complete, state updated to AsyncData"

# Si la secuencia se interrumpe, ahí está el problema
```

**3. Caso: Exception Silenciosa en _saveUserSecurely**
URL in `_saveUserSecurely()` hay try-catch que loguea:
```
"❌ [LOGIN] Error saving user data: ${e.runtimeType} - $e"
```
Si ves este error, SharedPreferences no se guardó.

## Pasos para Debugging

### PASO 1: Verificar el Login Completo
```
1. Abre la app en Chrome
2. Ve a Welcome Screen
3. Click "Entrar" para ir a Login
4. Ingresa credenciales válidas
5. Click en "Entrar" para hacer login

ESPERADO:
- ✅ Navega a HomePage
- ✅ En consola (F12 → Console) deberías ver:
  - "🔐 [USER PROVIDER] loginMailUser() called for: email***"
  - "💾 [LOGIN] Saving user data to SharedPreferences..."
  - "✅ [LOGIN] Saved to SharedPreferences: email=..., displayName=..., photo=..."
  - "🔍 [LOGIN] Verification - Saved and read back: email=..., displayName=..., photo=..."
  - "🎉 [LOGIN] Login complete, state updated to AsyncData"
```

### PASO 2: Cerrar la App Completamente
```
1. En Chrome, presiona Cmd+Q (cerrar completamente)
2. Abre Chrome nuevamente
3. Navega a la app (http://localhost:...]
```

### PASO 3: Verificar Si Recuerda el Usuario
```
ESPERADO:
- ✅ AuthWrapper._checkAuthState() se ejecuta
- ✅ Logs muestran:
  - "⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session..."
  - "ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences..."
  - "📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=USER@EXAMPLE.COM, displayName=USER_NAME, photo=..."
  - "✅ [AUTH WRAPPER] CASE 2: Remembered user found: USER@EXAMPLE.COM → Showing LoginPage"
- ✅ LoginPage abre y muestra:
  - Tarjeta de usuario recordado
  - Botón"

¿No eres tú?"

### PASO 4: Probar Si es a LoginMailUser o _saveUserSecurely

Si en PASO 1 NO ves logs de `_saveUserSecurely()`, el problema está en `loginMailUser()`:

**Posibilidad A: loginMailUser() nunca se ejecutó**
- Verificar que `ref.read(loginUserProvider.notifier).loginMailUser(...)` se ejecutó
- Los logs deberían mostrar: "✅ [LOGIN] Calling loginMailUser()..."

**Posibilidad B: loginMailUser() falló antes de llamar a _saveUserSecurely()**
- Verificar la validación de email en `loginMailUser()`
- Verificar el Firebase Auth - posible error en credenciales
- Los logs mostrarían: "❌ [USER PROVIDER] FirebaseAuthException: code=..."

**Posibilidad C: loginMailUser() completó pero _saveUserSecurely() no**
- Excepción silenciosa en `_saveUserSecurely()`
- Logs mostrarían: "❌ [LOGIN] Error saving user data: ..."

## Fix Propuesto

Si el problema es que `_saveUserSecurely()` falla:

```dart
// En UserProviders.dart, línea ~130
Future<void> _saveUserSecurely(User user, [String? email, String? password]) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Añadir logs adicionales para cada operación
    SecurityService.secureLog('💾 [LOGIN] Saving email...', level: 'DEBUG');
    await prefs.setString('lastUserEmail', user.email ?? '');
    SecurityService.secureLog('✅ [LOGIN] Email saved: ${user.email}', level: 'DEBUG');
    
    SecurityService.secureLog('💾 [LOGIN] Saving displayName...', level: 'DEBUG');
    await prefs.setString('lastUserDisplayName', user.displayName ?? '');
    SecurityService.secureLog('✅ [LOGIN] DisplayName saved: ${user.displayName}', level: 'DEBUG');
    
    SecurityService.secureLog('💾 [LOGIN] Saving photo...', level: 'DEBUG');
    await prefs.setString('lastUserPhoto', user.photoURL ?? '');
    SecurityService.secureLog('✅ [LOGIN] Photo saved: ${user.photoURL}', level: 'DEBUG');
    
    // ... resto del código
  } catch (e) {
    SecurityService.secureLog(
      '❌ [LOGIN] CRITICAL ERROR saving user data: ${e.runtimeType} - $e\nStackTrace: ${StackTrace.current}',
      level: 'ERROR'
    );
  }
}
```

## Checklist de Debug

- [ ] ¿JSON está en modo DEBUG en build? (flutter run -d chrome)
- [ ] ¿SharedPreferences está habilitado en el proyecto?
- [ ] ¿_saveUserSecurely() está siendo ejecutado?
- [ ] ¿Hay excepción en _saveUserSecurely()?
- [ ] ¿Los datos se están guardando pero están vacíos?
- [ ] ¿Hay algo que esté borrando los datos automáticamente?

## Logs Esperados (Flujo Completo)

```
[DEBUG] 🔐 [LOGIN] _submitLogin() called - Using MANUAL user: email***
[DEBUG] ✅ [LOGIN] Calling loginMailUser() for email: email***
[DEBUG] 🔐 [USER PROVIDER] loginMailUser() called for: email***
[DEBUG] 🔐 [USER PROVIDER] Attempting Firebase Auth with email...
[DEBUG] ✅ [USER PROVIDER] Firebase Auth successful, user UID: UID***
[DEBUG] 💾 [USER PROVIDER] Calling _saveUserSecurely() to save remembered user...
[DEBUG] 💾 [LOGIN] Saving user data to SharedPreferences...
[DEBUG] ✅ [LOGIN] Saved to SharedPreferences: email=user@email.com, displayName=User Name, photo=loaded
[DEBUG] 🔍 [LOGIN] Verification - Saved and read back: email=user@email.com, displayName=User Name, photo=loaded
[DEBUG] ✅ [LOGIN] Saved encrypted credentials to SecureStorage
[DEBUG] ✅ [LOGIN] Session token generated for user@email.com
[DEBUG] 🎉 [LOGIN] All user data saved successfully
[DEBUG] ✅ [USER PROVIDER] User data saved successfully
[DEBUG] ✅ [USER PROVIDER] Login attempts reset
[DEBUG] 🎉 [USER PROVIDER] Login complete, state updated to AsyncData
[DEBUG] ✅ [LOGIN] loginMailUser() returned successfully

(Usuario navega a Home)

(Usuario cierra app completamente)

(Usuario reabre app)

[DEBUG] 🔐 [AUTH WRAPPER] Starting auth state check...
[DEBUG] ⏳ [AUTH WRAPPER] Waiting 8s for Firebase to restore session...
[DEBUG] ℹ️ [AUTH WRAPPER] No active Firebase session found, checking SharedPreferences...
[DEBUG] 📝 [AUTH WRAPPER] SharedPreferences check: lastUserEmail=user@email.com, displayName=User Name, photo=loaded
[DEBUG] ✅ [AUTH WRAPPER] CASE 2: Remembered user found: user@email.com → Showing LoginPage
```

## Investigación Adicional

Si todos los logs muestran que se guardó correctamente pero AuthWrapper recibe null:

1. **SharedPreferences diferente entre login y auth_wrapper?**
   - Verificar que no hay múltiples instancias
   - Ambos usan `SharedPreferences.getInstance()`

2. **Problema con web/Chrome?**
   - SharedPreferences en web usa localStorage
   - Verificar que localStorage está habilitado
   - Chrome DevTools → Application → Local Storage

3. **Problema de timing?**
   - ¿Hay await correctos en todos lados?
   - ¿navega antes de que se guarden los datos?

