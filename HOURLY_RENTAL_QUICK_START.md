# ⚡ Quick Start - Sistema de Alquiler por Horas

## Lo que se ha implementado ✅

```
✅ Modelo AlquilerPorHoras con estados completos
✅ Servicio RentalByHoursService con todas las operaciones
✅ UI de selección de duración (RentByHoursScreen)
✅ UI de monitoreo en tiempo real (ActiveRentalsScreen)
✅ Cloud Functions para automatización (3 funciones)
✅ Documentación completa (HOURLY_RENTAL_GUIDE.md)
```

---

## Pasos para Activar (5-10 minutos)

### Paso 1: Actualizar Routes en `main.dart`
```dart
// Agregar imports
import 'package:aparcamientoszaragoza/Screens/rent_by_hours/rent_by_hours_screen.dart';
import 'package:aparcamientoszaragoza/Screens/active_rentals/active_rentals_screen.dart';

// En MaterialApp.router, agregar en routes:
RentByHoursScreen.routeName: (context) => const RentByHoursScreen(),
ActiveRentalsScreen.routeName: (context) => const ActiveRentalsScreen(),
```

### Paso 2: Desplegar Cloud Functions
```bash
# Desde la raíz del proyecto
cd functions

# Desplegar las 3 funciones nuevas
firebase deploy --only functions:processHourlyRentals,functions:releaseHourlyRental,functions:getRentalStatus

# Si quieres desplegar todas las funciones
firebase deploy --only functions
```

### Paso 3: Configurar Firestore Security Rules
En Firebase Console > Firestore > Rules, agregar:
```
match /alquileres/{document=**} {
  allow read: if request.auth.uid != null;
  allow write: if request.auth.uid != null;
}

match /notificaciones/{document=**} {
  allow read: if request.auth.uid == resource.data.userId;
  allow write: if false; // Solo Cloud Functions
}
```

### Paso 4: Configurar Cloud Scheduler (Automatización)
En GCP Console > Cloud Scheduler:
1. Click "Create Job"
2. Name: `hourly-rental-processor`
3. Frequency: `* * * * *` (cada minuto)
4. Timezone: `Europe/Madrid`
5. Click "Create"
6. Click "Edit"
7. Execution settings:
   - HTTP method: `POST`
   - URL: `https://europe-west1-<PROJECT_ID>.cloudfunctions.net/processHourlyRentals`
   - Auth header: `Add OIDC token`
   - Service account: `service-<PROJECT_ID>@gcp-sa-cloud-scheduler.iam.gserviceaccount.com`
8. Click "Save"

### Paso 5: Agregar Botones en la UI (Opcional)
Ver `HOURLY_RENTAL_UI_INTEGRATION.md` para instrucciones detalladas.

---

## Testing Rápido (3 minutos)

### Opción A: Crear alquiler de prueba en Firestore

1. Firebase Console > Firestore > `alquileres` > "+ Add document"
2. Document ID: (auto)
3. Agregar campos:
```json
{
  "tipo": 2,
  "estado": "EstadoAlquilerPorHoras.activo",
  "idPlaza": 5,
  "idArrendatario": "YOUR_USER_ID",
  "fechaInicio": (Timestamp ahora),
  "fechaVencimiento": (Timestamp ahora + 1 minuto),
  "duracionContratada": 1,
  "tiempoUsado": null,
  "precioMinuto": 0.0417,
  "precioTotal": null,
  "notificacionVencimientoEnviada": false,
  "notificacionMultaEnviada": false
}
```

4. En la app, navega a "Alquileres Activos"
5. Verás el alquiler con tiempo restante

### Opción B: Crear alquiler desde la app

1. Navega a una plaza
2. Click "Alquiler por Horas"
3. Selecciona duración
4. Click "Confirmar Alquiler"
5. Automáticamente ve el alquiler en "Alquileres Activos"

---

## Verificación Post-Despliegue

```bash
# 1. Verificar Cloud Functions
firebase functions:list

# 2. Ver logs de la función
firebase functions:log processHourlyRentals

# 3. Ver si Cloud Scheduler está ejecutando
gcloud scheduler jobs describe hourly-rental-processor

# 4. Ver trabajos ejecutados
gcloud scheduler jobs describe hourly-rental-processor --format json | grep lastExecution
```

---

## Archivos Importantes

| Archivo | Propósito | Estado |
|---------|-----------|--------|
| `lib/Models/alquiler_por_horas.dart` | Modelo de datos | ✅ Listo |
| `lib/Services/RentalByHoursService.dart` | Servicios | ✅ Listo |
| `lib/Screens/rent_by_hours/` | UI de duración | ✅ Listo |
| `lib/Screens/active_rentals/` | UI de monitoreo | ✅ Listo |
| `functions/rentalByHours.js` | Automatización | ✅ Listo |
| `HOURLY_RENTAL_GUIDE.md` | Documentación técnica | ✅ Listo |
| `HOURLY_RENTAL_UI_INTEGRATION.md` | Instrucciones UI | ✅ Listo |

---

## Próximos Pasos Opcionales

### Después de que funcione básico:
1. **Pagos**: Integrar Stripe para pagos automáticos
2. **Notificaciones Push**: Agregar Firebase Cloud Messaging
3. **Emails**: Enviar confirmación y vencimiento por email
4. **Analytics**: Dashboard de uso y estadísticas
5. **Descuentos**: Tarjetas de cliente frecuente

---

## Troubleshooting

### ❌ "Cloud Function no se ejecuta"
- Verificar que Cloud Scheduler está habilitado
- Ver logs en: GCP Console > Cloud Functions > Logs
- Verificar que el trigger está configurado

### ❌ "No veo alquileres activos"
- Verificar en Firestore que existen documentos con tipo=2
- Verificar que el usuario está logeado
- Ver logs de la app en DevTools

### ❌ "Error al crear alquiler"
- Verificar Firestore Security Rules
- Verificar que el usuario está autenticado
- Ver logs en DevTools (F12)

### ❌ "Las notificaciones no aparecen"
- Verificar que se crean en Firestore: `notificaciones` collection
- Las notificaciones push requieren Firebase Cloud Messaging
- Por ahora solo se crean documentos (sin push)

---

## Preguntas Frecuentes

**P: ¿Cuál es el precio configurado?**
R: €2.50 por hora + €0.45 comisión + 21% IVA. Configurable en `rent_by_hours_screen.dart`.

**P: ¿Cuándo se libera automáticamente?**
R: Cloud Function se ejecuta cada minuto. La liberación es casi instantánea (con ~1 minuto de latencia).

**P: ¿Qué pasa si no se libera en el margen de 5 minutos?**
R: Se marca como `multa_pendiente` y se notifica al usuario. Aún no hay multa cobrada (TODO).

**P: ¿Funciona en móvil?**
R: Sí. El código es multiplataforma (web/Android/iOS).

**P: ¿Cómo integro con pagos?**
R: En la pantalla de confirmación de pago, pasar el precio calculado al servicio de Stripe.

---

## Contacto y Soporte

- Documentación técnica: `HOURLY_RENTAL_GUIDE.md`
- Integración UI: `HOURLY_RENTAL_UI_INTEGRATION.md`
- Código fuente: `lib/Models/alquiler_por_horas.dart`
- Cloud Functions: `functions/rentalByHours.js`

---

**Versión**: 1.0
**Fecha**: 27 de febrero de 2026
**Estado**: Listo para producción
