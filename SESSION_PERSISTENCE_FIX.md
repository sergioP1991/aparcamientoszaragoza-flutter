# Solución: Persistencia de Sesión en App Cierre/Reapertura

**Problema**: Cuando el usuario cierra la app y la reabre, NO se mantiene la sesión activa.

**Causa**: El flujo de persistencia confía en session tokens que caducan en 7 días, y el timeout para restaurar Firebase session puede ser muy corto.

## ✅ Solución Implementada

### 1. **Mejorado AuthWrapper - Timeout Aumentado (5s → 8s)**
**Archivo**: `lib/Screens/auth_wrapper.dart`

El `_checkAuthState()` ahora:
- Espera **8 segundos** (en lugar de 5) a que Firebase restaure la sesión desde localStorage
- Es más tolerante con conexiones lentas en desarrollo

**Antes**:
```dart
authStateChanges()
    .first
    .timeout(Duration(seconds: 5))  // ❌ Muy corto para web en desarrollo
```

**Ahora**:
```dart
authStateChanges()
    .first
    .timeout(Duration(seconds: 8))  // ✅ Más tiempo para que Firebase restaure
```

### 2. **Flujo Simplificado de Autenticación**

**Orden de verificación mejorada**:

```
App reabre
     ↓
AuthWrapper._checkAuthState()
     ↓
┌─ Esperar 8s a Firebase restaurar sesión desde localStorage ─┐
│ (Firebase hace esto automáticamente en web)               │
└──────────────────────────────────────────────────────────┘
     ↓
¿Hay sesión activa en Firebase Auth?
  │
  ├─ ✅ SÍ → Ir a HomePage (usuario permanece logueado) ✓
  │
  └─ ❌ NO → Verificar usuario recordado en SharedPreferences
       ↓
       ¿Hay usuario recordado?
         │
         ├─ ✅ SÍ → Mostrar LoginPage (con opción "No soy tú")
         │           Usuario solo ve login familiar
         │
         └─ ❌ NO → Mostrar WelcomeScreen
```

### 3. **No Confiar Excesivamente en Session Tokens**

El sistema usa session tokens que expiran en 7 días como **fallback secundario**:
- **Primario**: Firebase Auth persistence (automático)
- **Secundario**: Session tokens (fallback after 7° day)
- **Fallback**: Mostrar LoginPage para pedir credenciales

## ⚠️ Importante: Firebase Persistence en Web

Firebase **YA persiste automáticamente** en web usando `localStorage`. **Pero** en desarrollo con HMR (Hot Module Reload), esto puede no funcionar bien.

### ✅ Probar Correctamente:

**OPCIÓN A - Hard Refresh (Lo más confiable)**:
```bash
# En Chrome/Mac: Cmd+Shift+R
# En Chrome/Windows: Ctrl+Shift+R   
# Esto limpia cache y fuerza recarga completa
```

**OPCIÓN B - Cerrar sesión del navegador completamente**:
```bash
# 1. flutter run -d chrome
# 2. Login con usuario
# 3. Cerrar pestaña(s) del navegador COMPLETAMENTE (no solo refresh)
# 4. Abrir de nuevo Chrome
# 5. Navegar a http://localhost:xxxxx  
# 🎯 Usuario debería estar logueado
```

**OPCIÓN C - Build web para producción** (más confiable que dev):
```bash
flutter build web --release
# Servir el contenido de build/web con un servidor HTTP real
```

## 🔍 Debugging: Verificar que Firebase Persiste

### En Chrome DevTools:
```
1. Abre DevTools (F12)
2. Application → Local Storage → http://localhost:xxxx
3. Busca claves como:
   - firebase:... (sesión de Firebase)
   - lastUserEmail (nuestra app)
   - lastUserDisplayName (nuestra app)
4. Login normalmente
5. Recarga página (Cmd+R)
6. ¿Siguen las claves ahí? ✅ SÍ → Firebase persistence funciona
```

### En ConsoleWW de Flutter:
```dart
// Incluido en logs al ejecutar con --verbose:
SecurityService.secureLog('🎯 Resultado reCAPTCHA: ...', level: 'DEBUG');

// Busca en la salida:
✅ Sesión restaurada: user@example.com. Ir a Home.
```

## 📋 Checklist: ¿Por Qué Podría No Funcionar?

- [ ] ¿Usando Hard Refresh (Cmd+Shift+R)? → **SÍ es obligatorio en desarrollo**
- [ ] ¿localStorage está habilitado en navegador? → Verificar DevTools → Application
- [ ] ¿Hay código limpiando localStorage inadecuadamente? → Buscar `.clear()`
- [ ] ¿Estás en incognito/private mode? → localStorage no persiste ahí
- [ ] ¿Fireflies persiste Android/iOS? → Por defecto sí, pero revisar si hay rollback
- [ ] ¿El email de login es válido?... → Verificar SecurityService.isValidEmail()
- [ ] ¿Timeout de 8s es suficiente? → Puedes aumentar a 10s si desarrollo es lento

## 🚀 Próximos Pasos (Opcional)

### Para Producción:
1. **Verificar Firebase settings para persistencia explícita**:
   ```dart
   // En main.dart después de Firebase.initializeApp():
   await FirebaseAuth.instance.setPersistence(
     Persistence.LOCAL, // web: localStorage
   );
   ```

2. **Monitorear logs** para ver cuánto tarda Firebase en restaurar:
   ```
   Logger: Sesión restaurada en XXms
   ```

3. **CI/CD**: Asegurar que tests incluyan "restart app" scenarios

### Para Testing Completo:
```bash
# Test 1: Hard refresh
flutter run -d chrome
# Login
# Cmd+Shift+R
# ✅ Debe estar logueado

# Test 2: Cierre completo
flutter run -d chrome
# Login
# Cerrar pestaña
# Abrir Chrome nuevamente
# ✅ Debe estar logueado

# Test 3: APK Android
flutter build apk --release
echo "Instalar en dispositivo y probar"
# Login → Cerrar app → Abrir app
# ✅ Debe estar logueado
```

## 📊 Resumen de Cambios

| Aspecto | Antes | Después |
|---------|-------|---------|
| Timeout Firebase | 5s | 8s |
| Confianza en session tokens | Alta | Media (fallback) |
| Confianza en Firebase persistence | Media | Alta |
| Fallback a auto-login | Con verificación token | Simplificado |
| Comportamiento esperado | Reloguear cada vez | Persistencia automática |

---

**Fecha**: 11 de marzo 2026  
**Agente**: GitHub Copilot  
**Status**: ✅ Actualización de AuthWrapper completada

Para probar: **`flutter run -d chrome` → Login → Cmd+Shift+R → Verificar que sigue logueado**
