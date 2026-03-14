# Posibles Causas del Fallo de SharedPreferences

## Causa 1: Excepción en SharedPreferences.getInstance()
**Síntoma**: Logs no muestran "✅ [LOGIN] SharedPreferences instance obtained"

**Verificación de código**:
```dart
final prefs = await SharedPreferences.getInstance();  // PUNTO DE FALLO
SecurityService.secureLog('✅ [LOGIN] SharedPreferences instance obtained', level: 'DEBUG');
```

**Solución**: Revisar que:
- [ ] `shared_preferences` está en `pubspec.yaml`
- [ ] `flutter pub get` se ejecutó recientemente
- [ ] No hay conflictos de versiones

**Fix rápido**:
```bash
flutter pub get && flutter clean && flutter run -d chrome
```

---

## Causa 2: await prefs.setString() Falla Silenciosamente
**Síntoma**: Logs no muestran "✅ [LOGIN] Email saved" después de "💾 [LOGIN] Step 1: Saving email..."

**Verificación de código**:
```dart
SecurityService.secureLog('💾 [LOGIN] Step 1: Saving email...', level: 'DEBUG');
await prefs.setString('lastUserEmail', user.email ?? '');  // PUNTO DE FALLO
SecurityService.secureLog('✅ [LOGIN] Email saved: "${user.email ?? ''}"', level: 'DEBUG');
```

**Posibles razones**:
- LocalStorage en navegador está deshabilitada
- Cuota de almacenamiento agotada (poco probable)
- Error en write operation

**Solución en Firefox/Chrome**:
- Abre DevTools (F12)
- Ve a: Application → Local Storage
- Verifica que la URL de la app está en la lista
- Si NO está, SharedPreferences no puede guardar nada

**Fix rápido**:
```javascript
// En DevTools Console:
localStorage.setItem('test', 'value');
console.log(localStorage.getItem('test'));  // Debe mostrar 'value'
```

---

## Causa 3: user.email es null
**Síntoma**: "✅ [LOGIN] Email saved: """ (guardando vacío)

**Verificación de código**:
```dart
await prefs.setString('lastUserEmail', user.email ?? '');  // Si user.email es null, guarda ''
```

**Posibles razones**:
- Firebase Auth devolvió User sin email
- Email no se verificó
- Problema con Firebase configuration

**Verificación**:
En los logs deberías ver antes:
```
"🔐 [USER PROVIDER] Attempting Firebase Auth with email..."
"✅ [USER PROVIDER] Firebase Auth successful, user UID: UID***"
```

Si ves el segundo log pero `user.email` es null, el problema está en Firebase.

---

## Causa 4: Excepción en ReAuthService.generateSessionToken()
**Síntoma**: Logs muestran guardado exitoso de email/displayName, pero:
- No ves "✅ [LOGIN] Session token generated"
- Ves "❌ [LOGIN] CRITICAL ERROR saving user data"

**Verificación**: Revisar si hay error en `ReAuthService` (línea ~179):
```
"⚠️ [LOGIN] Error generating session token: ..."
```

**Solución**: 
- Ver qué error reporta ReAuthService
- Posible causa: SharedPreferences en ReAuthService también falla
- Solución: Revisar ReAuthService.dart

---

## Causa 5: Datos se Guardan pero se Borran Inmediatamente
**Síntoma**: 
- Logs muestran "✅ [LOGIN] Email saved: "user@email.com""
- Pero AuthWrapper lee "lastUserEmail=null"

**Posibles razones**:
- SignOut() se llama inesperadamente después del login
- Hay code que borra SharedPreferences en algún lado
- Flutter hot reload borra datos

**Búsqueda de culpables**:
```bash
# Buscar si algo más está borrando datos
grep -r "removeString\|clear\|delete" lib/
grep -r "lastUserEmail" lib/
```

**Verificación rápida**:
- ¿El logout está siendo llamado automáticamente?
- Verificar flag `_isLoggingOut` en UserProviders

---

## Causa 6: Problema Específico de Web/localStorage en Flutter

**Symptom**: Todo funciona en Android/iOS pero NO en web

**Razón**: Flutter web usa `localStorage` que puede tener restricciones:
- localStorage no persiste en modo incógnito
- localStorage se limpia con cookies
- localStorage puede estar deshabilitado

**Debugging en Chrome**:
```javascript
// F12 → Console:
// Check que localStorage existe
console.log(typeof localStorage);  // "object"  

// Try storing manually
localStorage.setItem('test_prefs_key', 'test_value');
let value = localStorage.getItem('test_prefs_key');
console.log('Test value:', value);  // "test_value"

// Check app data
Object.keys(localStorage).forEach(key => {
  if (key.includes('lastUserEmail')) {
    console.log(`Found: ${key} = ${localStorage.getItem(key)}`);
  }
});
```

Si no ves nada guardados en localStorage, ese es el problema.

---

## Causa 7: AuthWrapper Lee SharedPreferences Antes de Guardarse

**Symptom**: Timing issue - app reinicia, AuthWrapper en millisegundos lee prefs

**Verificación**: Ver logs;
- ¿Cuánto tiempo entre "🎉 [LOGIN] All user data saved" y cierre de app?

**Solución**: Agregar pequeño delay antes de cerrar app
```dart
// En login_screen.dart, ref.listen():
} else if (next.value != null && next.value?.email != null && !_hasNavigated) {
  _hasNavigated = true;
  usernameController.clear();
  passwordController.clear();
  
  // ESPERAR a que SharedPreferences termine de guardar
  await Future.delayed(Duration(milliseconds: 500));
  
  SchedulerBinding.instance.addPostFrameCallback((_) {
    Navigator.of(context).pushNamedAndRemoveUntil(...)
  });
}
```

---

## Próximas Acciones

1. **EJECUTAR primero el test de login con los nuevos logs**
   - Revisar consola (F12 → Console) paso por paso
   - Identificar dónde se detiene la cadena de logs

2. **Si falla en Step 1 (SharedPreferences.getInstance)**
   - Ejecutar: `flutter pub get && flutter clean && flutter run -d chrome`

3. **Si falla en Step 2-4 (setString operations)**
   - Verificar localStorage en DevTools
   - Posible que localStorage esté deshabilitado

4. **Si falla en verificación (savedEmail vacío)**
   - El problema está en Firebase Auth (user.email es null)

5. **Si se guarda pero AuthWrapper lee null**
   - Timing issue o código borra datos entre login y restart
   - Ver localStorage en DevTools entre logout y restart

---

## Checklist de Debug Final

```bash
# 1. Asegurar que cambios se compilaron
flutter run -d chrome --verbose 2>&1 | grep -i "saveusersecurely"

# 2. Abrir Chrome DevTools
# F12 → Application → Local Storage → [URL de app]

# 3. Hacer login y observar:
# - Console logs (cada "Step X" debe aparecer)
# - LocalStorage debe tener: lastUserEmail, lastUserDisplayName, lastUserPhoto

# 4. Cierre completo:
# Cmd+Q (no solo cerrar tab)

# 5. Reabre Chrome:
# Navega a la app, observa AuthWrapper logs

# 6. Compara resultados esperados vs actuales
```

