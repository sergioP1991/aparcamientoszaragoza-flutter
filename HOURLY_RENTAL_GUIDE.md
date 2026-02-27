# 🕐 Alquiler de Plazas por Horas - Guía de Implementación

## Resumen
Se ha implementado un sistema completo de alquiler de plazas de aparcamiento por horas con:
- ✅ Liberación automática después del tiempo contratado
- ✅ Opción de liberar antes de tiempo (cobrar solo tiempo usado)
- ✅ Margen de 5 minutos después del vencimiento
- ✅ Notificaciones de vencimiento y multa potencial
- ✅ Cloud Functions para automatización

---

## 📁 Archivos Creados/Modificados

### Modelos
- **`lib/Models/alquiler_por_horas.dart`** (NUEVO)
  - Clase `AlquilerPorHoras` con lógica de cálculo de tiempo y precio
  - Enum `EstadoAlquilerPorHoras` con estados: activo, completado, vencido, multa_pendiente, liberado
  - Métodos para verificar vencimiento, margen, etc.

### Servicios
- **`lib/Services/RentalByHoursService.dart`** (NUEVO)
  - `createRental()`: Crear nuevo alquiler por horas
  - `getActiveRentalForPlaza()`: Obtener alquiler activo de una plaza
  - `getActiveRentalsForUser()`: Obtener alquileres activos del usuario
  - `releaseRentalEarly()`: Liberar plaza antes de tiempo
  - `markRentalAsExpired()`: Marcar como vencido
  - `markRentalAsExpiredWithPenalty()`: Marcar con multa pendiente
  - Streams en tiempo real para monitorear alquileres

### Cloud Functions
- **`functions/rentalByHours.js`** (NUEVO)
  - `processHourlyRentals()`: Pub/Sub job que corre cada minuto
    - Marca alquileres como vencidos cuando llega la hora
    - Envía notificación de vencimiento
    - Marca multa pendiente después de 5 minutos
    - Envía notificación de multa potencial
  - `releaseHourlyRental()`: Callable function para liberar plaza
  - `getRentalStatus()`: Callable function para obtener estado del alquiler

### UI/Screens
- **`lib/Screens/rent_by_hours/rent_by_hours_screen.dart`** (NUEVO)
  - Pantalla para seleccionar duración (1h, 2h, 4h, 8h, 12h, 24h o personalizada)
  - Desglose de precios (alquiler + comisión + IVA)
  - Información de vencimiento
  - Botón para confirmar y crear alquiler

- **`lib/Screens/active_rentals/active_rentals_screen.dart`** (NUEVO)
  - Pantalla para monitorear alquileres activos
  - Muestra tiempo restante con barra de progreso
  - Avisos de vencimiento y multa pendiente
  - Botón para liberar plaza antes de tiempo
  - Actualiza en tiempo real (cada segundo)

- **`lib/Screens/rent_by_hours/rental_by_hours_provider.dart`** (NUEVO)
  - Providers de Riverpod para gestionar estado

---

## 🔧 Configuración Requerida

### 1. Actualizar `main.dart` - Agregar Rutas
```dart
import 'package:aparcamientoszaragoza/Screens/rent_by_hours/rent_by_hours_screen.dart';
import 'package:aparcamientoszaragoza/Screens/active_rentals/active_rentals_screen.dart';

// En el MaterialApp.router, agregar rutas:
routes: {
  RentByHoursScreen.routeName: (context) => const RentByHoursScreen(),
  ActiveRentalsScreen.routeName: (context) => const ActiveRentalsScreen(),
  // ... resto de rutas
}
```

### 2. Desplegar Cloud Functions
```bash
cd functions
npm install  # Si no estaba hecho
firebase deploy --only functions:processHourlyRentals,functions:releaseHourlyRental,functions:getRentalStatus
```

### 3. Configurar Firestore Security Rules
Agregar estas reglas para permitir lectura/escritura de alquileres por horas:
```
match /alquileres/{document=**} {
  allow read: if request.auth.uid != null;
  allow write: if request.auth.uid != null && 
               (request.resource.data.tipo == 2 || 
                request.resource.data.idArrendatario == request.auth.uid);
}

match /notificaciones/{document=**} {
  allow read: if request.auth.uid == resource.data.userId;
  allow write: if false; // Solo Cloud Functions puede escribir
}
```

### 4. Configurar Pub/Sub Scheduler
- Ir a GCP Console > Cloud Scheduler
- Crear un nuevo job que ejecute cada minuto:
  ```
  Name: hourly-rental-processor
  Frequency: * * * * * (cada minuto)
  Timezone: Europe/Madrid
  HTTP method: POST
  URL: https://europe-west1-<PROJECT_ID>.cloudfunctions.net/processHourlyRentals
  Auth header: Add OIDC token
  Service account: service-<PROJECT_ID>@gcp-sa-cloud-scheduler.iam.gserviceaccount.com
  ```

### 5. Configurar precios (opcional)
Los precios están configurados en `rent_by_hours_screen.dart`:
- `pricePerHour = 2.50` €/hora (modificable)
- `ivaRate = 0.21` (21%)
- `managementFee = 0.45` € (comisión de gestión)
- `margenMinutos = 5` (en `alquiler_por_horas.dart`)

---

## 📊 Estructura de Datos en Firestore

### Colección: `alquileres`
```json
{
  "tipo": 2,  // 0=Normal, 1=Especial, 2=PorHoras
  "estado": "EstadoAlquilerPorHoras.activo",
  "idPlaza": 5,
  "idArrendatario": "user_id_xxx",
  "fechaInicio": Timestamp(2026-02-27 10:00:00),
  "fechaVencimiento": Timestamp(2026-02-27 11:00:00),
  "fechaLiberacion": null,
  "duracionContratada": 60,  // en minutos
  "tiempoUsado": null,
  "precioMinuto": 0.0417,  // €/minuto (2.50€/60min)
  "precioTotal": null,
  "notificacionVencimientoEnviada": false,
  "notificacionMultaEnviada": false
}
```

### Colección: `notificaciones`
```json
{
  "userId": "user_id_xxx",
  "tipo": "alquiler_vencido" | "multa_pendiente",
  "titulo": "⏰ Tu alquiler ha vencido",
  "mensaje": "Tu alquiler de la plaza 5 ha vencido...",
  "plazaId": 5,
  "rentalId": "doc_id_xxx",
  "leida": false,
  "timestamp": Timestamp(2026-02-27 11:00:00)
}
```

---

## 🔄 Flujo de Funcionamiento

### Crear Alquiler por Horas
1. Usuario navega a detalle de plaza
2. Click en "Alquiler por Horas" → Va a `RentByHoursScreen`
3. Selecciona duración (ej: 2 horas)
4. Ve desglose de precios
5. Click "Confirmar Alquiler" → Crea documento en Firestore
6. Navega a `ActiveRentalsScreen`

### Monitoreo Automático (Cloud Function cada minuto)
1. Busca alquileres con `estado = 'EstadoAlquilerPorHoras.activo'`
2. Si `fechaVencimiento <= now`:
   - Marca como `vencido`
   - Crea notificación `alquiler_vencido`
3. Busca alquileres con `estado = 'vencido'` y `notificacionMultaEnviada = false`
4. Si ya pasaron 5 minutos desde `fechaVencimiento`:
   - Marca como `multa_pendiente`
   - Crea notificación `multa_pendiente`

### Liberar Plaza Antes de Tiempo
1. En `ActiveRentalsScreen`, usuario ve tiempo restante
2. Click "Liberar Ahora" → Confirma en diálogo
3. Cloud Function `releaseHourlyRental()`:
   - Calcula tiempo real usado
   - Calcula precio final = `tiempoUsado * precioMinuto`
   - Actualiza documento: `estado = 'liberado'`
   - Registra en historial
   - Devuelve precio final

### Estados del Alquiler

```
┌─────────────────────────────────────────────────────────┐
│ ACTIVO (Durante el alquiler)                            │
├─────────────────────────────────────────────────────────┤
│ • Tiempo restante visible                              │
│ • Usuario puede liberar antes                          │
│ • Notificaciones: Ninguna                              │
└──────────────────────┬──────────────────────────────────┘
                       │ Tiempo vencido
                       ↓
┌─────────────────────────────────────────────────────────┐
│ VENCIDO (Margen de 5 minutos)                           │
├─────────────────────────────────────────────────────────┤
│ • Cloud Function lo marca automáticamente              │
│ • Usuario recibe notificación                          │
│ • Usuario tiene 5 minutos para liberar                 │
│ • Si libera: estado = LIBERADO                         │
└──────────────────────┬──────────────────────────────────┘
                       │ Pasados 5 minutos sin liberar
                       ↓
┌─────────────────────────────────────────────────────────┐
│ MULTA_PENDIENTE (Se aplica multa)                       │
├─────────────────────────────────────────────────────────┤
│ • Cloud Function lo marca automáticamente              │
│ • Usuario recibe notificación urgente                  │
│ • Se aplica multa (configurable)                       │
│ • Usuario debe pagar multa + precio                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ LIBERADO (Usuario liberó antes de vencer)              │
├─────────────────────────────────────────────────────────┤
│ • Usuario pagó solo tiempo usado                       │
│ • Sin multa                                            │
│ • Plaza disponible para otros                          │
└─────────────────────────────────────────────────────────┘
```

---

## 📱 Próximos Pasos

### Fase 1 (Implementado) ✅
- [x] Modelo de alquiler por horas
- [x] Servicio de gestión de alquileres
- [x] Cloud Functions básicas
- [x] UI de selección de duración
- [x] UI de monitoreo en tiempo real

### Fase 2 (Próxima) ⏳
- [ ] Integración con sistema de pagos Stripe
- [ ] Cálculo y aplicación de multas
- [ ] Firebase Cloud Messaging para notificaciones push
- [ ] Email de confirmación y vencimiento
- [ ] Dashboard de análisis (cliente/propietario)

### Fase 3 (Futuro)
- [ ] Descuentos por duración prolongada
- [ ] Abonos/pases mensuales
- [ ] Renovación automática de alquileres
- [ ] Rating/reputación de plazas
- [ ] Integración con Apple Pay/Google Pay

---

## 🧪 Testing Local

### 1. Crear un alquiler de prueba
```bash
# En Firebase Console > Firestore, agregar documento a 'alquileres':
{
  "tipo": 2,
  "estado": "EstadoAlquilerPorHoras.activo",
  "idPlaza": 5,
  "idArrendatario": "TU_USER_ID",
  "fechaInicio": Timestamp.now(),
  "fechaVencimiento": Timestamp.now() + 5 minutos,
  "duracionContratada": 5,
  "precioMinuto": 0.0417,
  ...
}
```

### 2. Verificar en la app
- Navega a `Alquileres Activos`
- Verás el alquiler con 5 minutos de tiempo restante
- Cada segundo, el contador baja

### 3. Esperar a que venza
- Pasados 5 minutos, verás el estado cambiar a "Vencido"
- Se mostrará aviso en naranja

### 4. Esperar margen
- Pasados otros 5 minutos (10 total), verá "Multa Pendiente"
- Aviso en rojo

### 5. Liberar antes de tiempo
- Click "Liberar Ahora"
- Confirma
- Estado cambia a "Liberado"
- Muestra precio cobrado

---

## 🔐 Seguridad

- ✅ Validación de autenticación en Cloud Functions
- ✅ Verificación de permisos (solo el arrendatario puede liberar)
- ✅ Timestamps del servidor para evitar manipulación
- ✅ Cálculos de precio en el backend (Cloud Functions)
- ✅ Auditoría en `historial_actividad`

---

## 📞 Soporte

Para dudas sobre la implementación:
1. Revisar los logs de Cloud Functions en GCP Console
2. Verificar datos en Firestore Console
3. Revisar comentarios en el código

---

**Fecha**: 27 de febrero de 2026
**Agente**: GitHub Copilot
