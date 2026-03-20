# Testing Checklist: Release Button Fix (21 de marzo 2026)

## Objetivo
Validar que el botón "Liberar Ahora" en la pantalla de alquileres activos funciona correctamente después del fix de `documentId`.

---

## Pre-requisitos

- [ ] App compilada: `flutter run -d chrome`
- [ ] Cuenta de usuario válida (ya loginizado)
- [ ] Al menos una plaza de aparcamiento registrada
- [ ] Plaza con alquiler por horas (no mensual)

---

## Pasos de Testing

### 1️⃣ Setup: Crear Alquiler Nuevo

**Objetivo**: Crear un alquiler nuevo para testear que `documentId` se guarda correctamente.

```
[ ] Home (lista de plazas)
[ ] Click en plaza con rentIsNormal = false (tipo alquiler por horas)
[ ] Click botón "Alquiler por Horas"
[ ] Seleccionar duración: 2 horas
  ↳ Verificar en consola (F12):
    - 🔑 [RENTAL_SERVICE] Guardando documentId="..." en el documento
    - ✅ [RENTAL_SERVICE] Alquiler creado con ID: ...
[ ] Seleccionar método de pago: Tarjeta
[ ] Completar pago con tarjeta Test: 4242 4242 4242 4242
[ ] Verificar redirección a Home después de pago exitoso
```

**Expected Output en Console:**
```
🔑 [RENTAL_SERVICE] Guardando documentId="abc123xyz" en el documento
✅ [RENTAL_SERVICE] Alquiler creado con ID: abc123xyz
📍 [RENTAL_SERVICE] PlazaId: 5, Tipo: 2, Estado: activo
```

---

### 2️⃣ Main Test: Liberar Alquiler

**Objetivo**: Testear que el botón "Liberar Ahora" funciona correctamente.

```
[ ] Navegar a Perfil/Settings
[ ] Click en "Mis Alquileres" (ícono de coche)
  ↳ O ir a Perfil → Opción "Mis Alquileres"
[ ] Deberías ver el alquiler que acabas de crear
[ ] En el alquiler, click botón "Liberar Ahora"
  ↳ Verificar en consola (F12):
    - 🔑 [BUTTON] Intento de liberación. documentId=...
    - ✅ [BUTTON] documentId válido, proceediendo...
    - 📍 [BUTTON] Plaza ID: 5, documentId válido
[ ] Se abre diálogo de confirmación: "¿Estás seguro..."
[ ] Click botón "Liberar" en el diálogo de confirmación
[ ] Verificar en consola:
    - Loading dialog: "Liberando alquiler..."
    - ✅ [BUTTON] Alquiler liberado exitosamente
    - 💰 Precio final: €X.XX
    - ✅ Plaza liberada. Total: €X.XX (SnackBar verde)
[ ] El alquiler debería desaparecer de la lista
[ ] Verificar que la plaza ahora está disponible en Home (sin banner azul)
```

**Expected Console Output - Operación Exitosa:**
```
🔑 [BUTTON] Intento de liberación. documentId="abc123xyz"
✅ [BUTTON] documentId válido, proceediendo...
[Confirmation Dialog appears]
🔄 [BUTTON] Liberando alquiler... 
✅ [Button] Alquiler liberado en Firestore
💰 Precio final: €4.20
🎉 Plaza liberada. Total: €4.20
```

**Expected Console Output - Si Falla (Para Verificar Fix):**
```
❌ [BUTTON] ERROR: documentId inválido
  └─ Este error NO debería aparecer después del fix
```

---

### 3️⃣ Data Integrity: Verificar Firestore

**Objetivo**: Validar que los cambios se persisten correctamente en Firestore.

```
[ ] Abrir Firebase Console: https://console.firebase.google.com
[ ] Proyecto: aparcamientos-zaragoza
[ ] Firestore → Colección "alquileres"
[ ] Buscar el documento que acabas de liberar (ordenado por timestamp más reciente)
[ ] Verificar campos en el documento:
    ✅ documentId: existe y coincide con el document ID del documento
    ✅ estado: "EstadoAlquilerPorHoras.liberado"
    ✅ fechaLiberacion: timestamp reciente
    ✅ tiempoUsado: número de minutos (> 0)
    ✅ precioCalculado: precio en euros (> 0)
```

**Documento Esperado en Firestore:**
```json
{
  "idPlaza": 5,
  "idArrendatario": "user@example.com",
  "documentId": "abc123xyz",  // ✅ CRÍTICO: Debe existir
  "estado": "liberado",
  "fechaInicio": Timestamp(...),
  "fechaVencimiento": Timestamp(...),
  "fechaLiberacion": Timestamp(...),
  "tiempoUsado": 24,  // minutos
  "duracionContratada": 120,
  "precioMinuto": 2.5,
  "precioCalculado": 4.20,
  "notificacionVencimientoEnviada": false,
  "notificacionMultaEnviada": false
}
```

---

### 4️⃣ Adicional: Crear Múltiples Alquileres

**Objetivo**: Verificar que el fix funciona consistentemente con múltiples alquileres.

```
[ ] Crear segundo alquiler (mismos pasos que 1️⃣)
[ ] Crear tercero alquiler (mismos pasos que 1️⃣)
[ ] Ir a "Mis Alquileres"
[ ] Debería haber 3 alquileres en la lista
[ ] Liberar los 3 en orden:
    [ ] Liberar 1º → ✅ Éxito
    [ ] Liberar 2º → ✅ Éxito
    [ ] Liberar 3º → ✅ Éxito
[ ] Todos deberían desaparecer de la lista
[ ] Verificar en Firestore que todos tienen estado="liberado"
```

---

## Pruebas de Regresión (Caso Negativo)

### 5️⃣ Verificar que Fallos se Detectan Correctamente

```
[ ] Crear alquiler Normal (mensual, rentIsNormal=true)
[ ] Ir a detalles de la plaza
[ ] Debería mostrar banner naranja "Alquiler Mensual Activo"
[ ] Click "Liberar Alquiler" (si está visible)
[ ] Verificar que funciona correctamente también
```

---

## Resultados Esperados

✅ **Test Passed Si:**
- [x] El botón "Liberar Ahora" no muestra error "documentId inválido"
- [x] El alquiler desaparece de la lista después de liberar
- [x] Se muestra SnackBar verde con precio final
- [x] En Firestore, el documento tiene documentId = document.id
- [x] El estado en Firestore es "liberado"
- [x] La plaza vuelve a estar disponible en Home sin banner

❌ **Test Falló Si:**
- [x] Aparece error "documentId inválido" en consola
- [x] El alquiler NO desaparece de la lista
- [x] No se muestra SnackBar de confirmación
- [x] En Firestore, el campo documentId está vacío o null
- [x] La plaza sigue mostrando como ocupada después de liberar

---

## Logs para Monitorear en F12 Console

### Búsquedas Clave:
```javascript
// En F12 Console, copiar y pegar:

// 1. Verificar documentId se guardó:
console.log("✅ documentId se guardó correctamente");

// 2. Filtrar por RELEASE:
// Presionar Ctrl+F en console y buscar: [BUTTON]
// Debería mostrar: "Liberar Ahora" logs

// 3. Filtrar por errores:
// Presionar Ctrl+F en console y buscar: ❌ ERROR
// Debería estar VACÍO (sin errores de documentId)
```

---

## Fallback: Si los Tests Fallan

Si el botón sigue sin funcionar después del fix:

```bash
# 1. Limpiar caché
flutter clean
flutter pub get

# 2. Hard refresh en Chrome
Cmd+Shift+R (en Mac)
Ctrl+Shift+R (en Windows/Linux)

# 3. Ver logs de error con máximo detalle
dart analyze lib/Services/RentalByHoursService.dart --verbose

# 4. Verificar que los cambios están en el archivo:
grep "await docRef.update" lib/Services/RentalByHoursService.dart
grep "documentId: snapshot.id" lib/Models/alquiler_por_horas.dart
```

---

## Screenshots a Capturar (Opcional)

Si todo funciona, capturar:
- [ ] Console F12 con logs de éxito: 🔑, ✅, 💰
- [ ] Firestore documento con documentId field
- [ ] Home en estado post-liberación (plaza sin banner azul)
- [ ] SnackBar verde "Plaza liberada. Total: €X.XX"

---

## Observaciones importantes:

⚠️ **Notas de Implementación:**
- `documentId` se guarda en Firestore con actualización inmediata: `await docRef.update({'documentId': docRef.id})`
- Cuando se carga el alquiler, `fromFirestore()` usa `snapshot.id` como fuente de verdad única
- El debug logging incluye 🔑, ✅, 💰, ❌ emojis para fácil identificación en console

⚠️ **Timing:**
- Cada test toma ~30-60 segundos (crear alquiler + completar pago)
- Múltiples tests juntos pueden tomar 3-5 minutos

⚠️ **Ambiente:**
- Tests en Chrome (web)
- Uses test Firebase config from `web/index.html`
- Payment uses Stripe Test Mode (4242 4242 4242 4242)

---

**Fecha**: 21 de marzo de 2026
**Status**: ✅ Ready for Testing
**Expected Duration**: 15-20 minutos

