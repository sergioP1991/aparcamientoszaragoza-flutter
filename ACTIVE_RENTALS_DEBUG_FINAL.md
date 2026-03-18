# Debug Guide: Liberar Alquiler desde Active Rentals Screen

## Problema Actual
El botón "Liberar Ahora" en la pantalla de "Mis Alquileres" no funciona. El código está presente pero `documentId` probablemente es `null`.

## Punto Crítico Identificado
En `active_rentals_screen.dart` línea 505-506:
```dart
debugPrint('🔵 [BUTTON] Botón liberar presionado. documentId=${rental.documentId}');
_releaseRental(context, rental, rental.documentId ?? 'NULL');
```

Si `rental.documentId` es `null`, pasa literal `'NULL'` (string), que luego es rechazado por validación.

---

## FASES DE DEBUG

### FASE 1: Compilar y Ver Logs en Real-Time

```bash
# Limpiar para asegurar cambios
flutter clean
flutter pub get

# Ejecutar en web con verbose logging visible
flutter run -d chrome
```

**En Chrome DevTools:**
1. Abre la app
2. **F12** → Ir a **Console** tab
3. Search: `WATCH_RENTALS` para ver si watchUserActiveRentals está funcionando

---

### FASE 2: Navegar a "Mis Alquileres"

1. En la app, navega a **Perfil** (Profile icon)
2. Busca la opción **"Mis Alquileres"** (o **"Active Rentals"**)
3. En Chrome Console (F12), busca logs con prefijo `[WATCH_RENTALS]`

**Que Deberías VER en Logs:**
```
🔍 [WATCH_RENTALS] Usuario: [tu-uid-aqui-abc123...]
📊 [WATCH_RENTALS] Total documentos encontrados: 1
📝 [WATCH_RENTALS] Procesando doc: [documento-id-12345]
   ✅ [WATCH_RENTALS] documentId=12345
   🔄 [WATCH_RENTALS] Estado: EstadoAlquilerPorHoras.activo
   ✅ Alquiler activo incluido
📈 [WATCH_RENTALS] Total alquileres activos: 1
```

**QUE BUSCAR:**
- ¿Dice `documentId=12345` o `documentId=null`?
- **SI VES `documentId=null` → PROBLEMA RAÍZ ENCONTRADO**
- **SI VES documentId con valor → Pasar a FASE 3**

---

### FASE 3: Presionar Botón "Liberar Ahora"

1. En pantalla de "Mis Alquileres", verás un card con tu alquiler
2. Click en **"Liberar Ahora"** (botón azul/rojo)

**En Chrome Console, busca logs con `[BUTTON]`:**
```
🔵 [BUTTON] Botón liberar presionado. documentId=[AQUI DEBE MOSTRAR EL ID]
```

**QUE BUSCAR:**
- ¿Muestra `documentId=null`?
- ¿Muestra `documentId=12345` (válido)?
- **SI VES `null` → documentId se perdió entre FASE 2 y aquí**

---

### FASE 4: Validación en _releaseRental()

Después de ver `docum EntId=` del FASE 3, busca logs con `[_RELEASE]`:

```
🔵 [_RELEASE] Iniciando liberación
   documentId recibido: "12345"
   rental.documentId: "12345"
   rental.idPlaza: 5
   rental.estado: EstadoAlquilerPorHoras.activo
```

**QUE BUSCAR:**
- ¿Muestra `documentId recibido: "NULL"`? → PROBLEMA: se pasó null
- ¿Muestra `documentId recibido: ""`? → PROBLEMA: se pasó vacío
- ¿Muestra `documentId recibido: "12345"`? → PASO CORRECTO

Si documentId es inválido, verás:
```
❌ [_RELEASE] Error: documentId está vacío o es NULL
```

---

## ESCENARIOS Y SOLUCIONES

### Escenario A: `documentId=null` en FASE 2
**Causa:** El método `fromFirestore()` NO está capturando `snapshot.id` correctamente

**Acción:** 
1. Abre `lib/Models/alquiler_por_horas.dart`
2. Línea 183 debe ser: `documentId: snapshot.id,`
3. Si no está, AGRÉGALO

**Código Correcto:**
```dart
factory AlquilerPorHoras.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
  // ... código previo ...
  return AlquilerPorHoras(
    idPlaza: data['idPlaza'] as int? ?? 0,
    idArrendatario: data['idArrendatario'] as String? ?? 'unknown',
    documentId: snapshot.id,  // ← DEBE ESTAR ESTA LÍNEA
    // ... resto de parámetros ...
  );
}
```

---

### Escenario B: `documentId` está bien en FASE 2, pero `null` en FASE 3
**Causa:** El objeto rental está siendo recreado o el Stream está emitiendo nuevos valores

**Acción:**
1. El logging ya está en lugar
2. Pero adicionar más contexto en `_buildActionButtons()`:

En `active_rentals_screen.dart` línea ~240 (en `_buildActionButtons()`), agregar al inicio:
```dart
void _buildActionButtons(BuildContext context, AlquilerPorHoras rental, ...) {
  debugPrint('🔍 [ACTION_BUTTONS] EDIFICANDO botones para rental:');
  debugPrint('   documentId en _buildActionButtons: ${rental.documentId}');
  debugPrint('   idPlaza: ${rental.idPlaza}');
  debugPrint('   estado: ${rental.estado}');
  // ... resto del método
}
```

---

### Escenario C: El botón no se presiona (onClick no se ejecuta)
**Causa:** El widget `OutlinedButton` podría estar deshabilitado o no tener onPressed handler

**Verificación:**
Busca en Chrome Console logs con `🔵 [BUTTON]` después de presionar. Si NO aparecen:
- El `onPressed` callback NO se está ejecutando
- Revisar que en línea ~505 el `onPressed:` NO sea `null`

**Código Correcto:**
```dart
OutlinedButton(
  onPressed: () {  // ← DEBE EXISTIR
    debugPrint('🔵 [BUTTON] Botón liberar presionado. documentId=${rental.documentId}');
    _releaseRental(context, rental, rental.documentId ?? 'NULL');
  },
  child: const Text('Liberar Ahora'),
),
```

---

## PASOS PARA REPORTAR

Una vez que hayas ejecutado las 4 fases, dime:

1. **FASE 2 Resultado:**
   - ¿Ves `documentId=` con un valor o `documentId=null`?
   - Copia exactamente el log que ves

2. **FASE 3 Resultado:**
   - Después de presionar "Liberar Ahora", ¿ves `🔵 [BUTTON]` en los logs?
   - ¿Qué dice el `documentId=`?

3. **FASE 4 Resultado:**
   - ¿Ves `🔵 [_RELEASE]` en logs?
   - ¿Qué dice `documentId recibido:`?
   - ¿Ves `❌ Error: documentId está vacío o es NULL`?

---

## Quick Fix Temporary

Si quieres un fix rápido temporal mientras debuggeamos, puedes cambiar la validación en `_releaseRental()` para ser menos estricta:

**EN `active_rentals_screen.dart` líneas 525-540, cambiar:**

```dart
// ANTES (estricto):
if (documentId.isEmpty || documentId == 'NULL') {
  debugPrint('❌ [_RELEASE] Error: documentId está vacío o es NULL');
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(/*...*/);
  }
  return;
}

// A DESPUÉS (diagnosticar qué recibimos):
if (documentId.isEmpty || documentId == 'NULL') {
  debugPrint('❌ [_RELEASE] documentId inválido: "$documentId"');
  debugPrint('   rental.documentId en _releaseRental: "${rental.documentId}"');
  debugPrint('   rental.idPlaza: ${rental.idPlaza}');
  debugPrint('   Intentando usar rental.documentId directamente...');
  
  // Fallback: usar rental.documentId si el parámetro no funciona
  if (rental.documentId != null && rental.documentId!.isNotEmpty) {
    debugPrint('   ✅ Usando rental.documentId como fallback');
    // Continuar con rental.documentId en lugar de documentId
    await RentalByHoursService.releaseRental(rental.documentId!);
    // ... resto del flujo
    return;
  }
  
  // Si ni siquiera rental.documentId es válido:
  debugPrint('❌ [_RELEASE] rental.documentId también está vacío o null');
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(/*...*/);
  }
  return;
}
```

**Pero esto es temporal.** Primero necesitamos entender dónde se pierde el `documentId`.

---

## Resumen

**El objetivo es encontrar EN QUÉ FASE se pierde el `documentId`:**
1. ✅ FASE 2: ¿Se captura en `watchUserActiveRentals()`?
2. ⏳ FASE 3: ¿Se mantiene cuando se presiona el botón?
3. ⏳ FASE 4: ¿Llega válido a `_releaseRental()`?

Una vez que sepamos en qué fase se pierde, la solución será evidente. **Ejecuta el app ahora y dime qué ves en FASE 2.**
