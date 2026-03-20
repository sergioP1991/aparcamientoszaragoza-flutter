# 🔍 Guía de Debugging - Botón "Liberar Ahora" No Funciona

## Problema Reportado
El botón "Liberar Ahora" en la pantalla de alquileres activos no funciona.

## Arquitetura Actual
```
Button Click
    ↓
_releaseRental() valida documentId
    ↓
¿documentId == null/empty/'NULL'?
    ├─ SÍ → Muestra error rojo: "documentId faltante"
    └─ NO → Diálogo confirmación
        ↓
    Usuario confirma
        ↓
    RentalByHoursService.releaseRental(documentId)
        ├─ Valida documentId
        ├─ Obtiene documento de Firestore
        ├─ Deserializa a AlquilerPorHoras
        ├─ Verifica propiedad
        └─ Actualiza estado a 'liberado'
        ↓
    Espera 1200ms (propagación Firestore)
        ↓
    ref.refresh() actualiza providers
        ↓
    Muestra SnackBar verde de éxito
```

## Puntos de Fallo Identificados

### 1️⃣ documentId es null al hacer click
**Síntomas:** Usuario ve error rojo "❌ Error interno: documentId faltante. Recarga la app."

**Causa probable:** 
- El alquiler fue creado ANTES de que se implementara el código que usa `snapshot.id`
- El campo `documentId` no estaba siendo capturado en `fromFirestore()`

**Verificación:** 
En el debug output deberías ver:
```
🔍 [RENTAL_CARD] documentId="null", idPlaza=5
```

**Solución recomendada:** Ejecutar esto en Firebase Console para verificar si los documentos tienen el campo `documentId`:

```javascript
// En Firebase Console > Firestore > Ejecutar Query
db.collection('alquileres')
  .where('tipo', '==', 2)
  .where('estado', '==', 'activo')
  .get()
  .then(snapshot => {
    snapshot.docs.forEach(doc => {
      console.log(`Doc ID: ${doc.id}, Tiene documentId: ${doc.data().documentId ? 'SÍ' : 'NO'}`);
    });
  });
```

---

### 2️⃣ El servicio lanza error al liberar
**Síntomas:** Usuario ve error rojo con mensaje del error (ej: "Documento no encontrado")

**Causa probable:**
- El `documentId` es incorrecto
- El documento no existe en Firestore
- El usuario no es el propietario del alquiler

**Verificación:**
En el debug output deberías ver:
```
❌ [ACTIVE_RENTALS] Error liberando: ...error message...
```

**Solución:** El error message te dirá exactamente qué falló.

---

### 3️⃣ El alquiler se libera pero no desaparece de la lista
**Síntomas:** Usuario ve SnackBar verde "Plaza liberada" pero el card sigue visible

**Causa probable:**
- El `ref.refresh()` no está actualizando correctamente el stream
- Firestore tardó más de 1200ms en propagar el cambio

**Verificación:**
En el debug output deberías ver:
```
✅ [ACTIVE_RENTALS] Alquiler liberado en Firestore
🔄 [ACTIVE_RENTALS] Refrescando providers
✅ Plaza liberada. Total: €X.XX
```

Pero luego el card sigue visible.

**Solución:** Forzar un refresh más agresivo o esperar más tiempo.

---

## Pasos de Debugging Recomendados

### Paso 1: Habilitar logs en consola
```bash
# Compilar con verbose
flutter run -d chrome --verbose 2>&1 | tee debug_logs.txt
```

Buscar en los logs:
```
🔍 [RENTAL_CARD] documentId=
🔵 [BUTTON] Intento de liberación
🔵 [_RELEASE] Iniciando liberación
🔑 [ACTIVE_RENTALS] Llamando a RentalByHoursService
✅ [ACTIVE_RENTALS] Alquiler liberado
```

---

### Paso 2: Verificar documentId en Firestore

En Firebase Console:
1. Ir a: Firestore > Colección `alquileres`
2. Buscar un documento con `tipo: 2` y `estado: activo`
3. Revisar si tiene el campo `documentId`
4. El `documentId` debería coincidir con el ID del documento

**Esperado:**
```
Documento ID: "abc123xyz..."
  documentId: "abc123xyz..." ✅ Debe coincidir
  idPlaza: 5
  tipo: 2
  estado: "activo"
```

**Problema:**
```
Documento ID: "abc123xyz..."
  documentId: NO EXISTE ❌ O es "null" ❌
```

---

### Paso 3: Probar el flujo manualmente

1. Abrir app en Chrome
2. Crear alquiler por horas (ir a plaza > Alquiler por Horas > Seleccionar duración > Pagar)
3. Ir a Mis Alquileres
4. Abrir DevTools (F12 > Console)
5. Hacer click en "Liberar Ahora"
6. Observar los logs y mensajes de error

**Esperado:**
```
Console output:
  🔍 [RENTAL_CARD] documentId="...", idPlaza=5
  🔵 [BUTTON] Intento de liberación. documentId="..."
  ✅ [BUTTON] documentId válido, proceediendo...
  🔵 [_RELEASE] Iniciando liberación
  ✅ [_RELEASE] documentId válido, documentId existe: true
  Diálogo de confirmación aparece
  Usuario hace click "Liberar"
  🔑 [ACTIVE_RENTALS] Llamando a RentalByHoursService...
  ✅ [ACTIVE_RENTALS] Alquiler liberado en Firestore
  ✅ Plaza liberada. Total: €X.XX
  Card desaparece de la lista
```

---

## Posibles Soluciones

### Si documentId es null:
```dart
// En alquiler_por_horas.dart fromFirestore() línea 198, asegurar:
documentId: snapshot.id,  // CRÍTICO: Usar snapshot.id SIEMPRE
```

### Si el servicio falla:
Revisar los logs de `RentalByHoursService.releaseRental()` para ver qué validación falló.

### Si el card no desaparece:
```dart
// En active_rentals_screen.dart _releaseRental() línea 620-621, cambiar:
ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: true));

// POR:
await ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: false));
await ref.refresh(fetchHomeProvider(allGarages: true, onlyMine: true));
```

---

## Archivos Clave

| Archivo | Responsabilidad | Línea Clave |
|---------|-----------------|------------|
| `lib/Services/RentalByHoursService.dart` | Crear alquiler con documentId | L47: `await docRef.update({'documentId': docRef.id});` |
| `lib/Models/alquiler_por_horas.dart` | Deserializar documentId | L198: `documentId: snapshot.id,` |
| `lib/Screens/active_rentals/active_rentals_screen.dart` | Botón y validación | L509-534: Botón click handler |
| `lib/Screens/active_rentals/active_rentals_screen.dart` | Liberar alquiler | L540-700: Método _releaseRental() |

---

## Próximos Pasos

1. **Recolectar logs** siguiendo Paso 2 de debugging
2. **Capturar screenshot** del error si la aparece
3. **Verificar Firestore** si documentos tienen el campo `documentId`
4. **Reportar** exactamente qué error se muestra en rojo

---

**Generado:** 21 de marzo de 2026  
**Versión**: v29.1 Release Button Debug Guide
