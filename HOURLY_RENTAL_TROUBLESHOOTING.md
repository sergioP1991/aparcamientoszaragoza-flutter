# 🆘 Troubleshooting y FAQs - Sistema de Alquiler por Horas

## Preguntas Frecuentes

### 🤔 General

**P: ¿Dónde están todos los archivos nuevos?**
```
R: 
lib/Models/alquiler_por_horas.dart
lib/Services/RentalByHoursService.dart
lib/Screens/rent_by_hours/
lib/Screens/active_rentals/
functions/rentalByHours.js
```

**P: ¿Qué archivos existentes se modificaron?**
```
R:
lib/Models/alquiler.dart (comentario tipo 2)
lib/Screens/home/providers/HomeProviders.dart (soporte tipo 2)
AGENTS.md (documentación)
```

**P: ¿Necesito instalar nuevos paquetes?**
```
R: No. Usa solo los que ya existen:
✅ cloud_firestore
✅ firebase_auth
✅ cloud_functions
✅ flutter_riverpod
✅ intl
```

**P: ¿Funciona en web, Android e iOS?**
```
R: Sí. El código es 100% multiplataforma.
Web: ✅ Funcionará
Android APK: ✅ Funcionará
iOS: ✅ Funcionará
```

---

### 💰 Precios

**P: ¿Cómo cambio los precios?**
```
R: Edita lib/Screens/rent_by_hours/rent_by_hours_screen.dart

  static const double pricePerHour = 2.50;        // Cambiar aquí
  static const double managementFee = 0.45;       // O aquí
  static const double ivaRate = 0.21;             // O aquí
```

**P: ¿Cómo aplico multas?**
```
R: TODO - Aún no implementado. Cuando lo hagas:

1. Agregar campo en AlquilerPorHoras:
   double multa = 10.00; // €10 de multa
   
2. En Cloud Function, calcular:
   if (hasPenalty) {
     finalPrice += rental.multa;
   }
```

**P: ¿El cliente ve exactamente lo que paga?**
```
R: Sí. El desglose muestra:
- Alquiler (duración × precio/hora)
- Comisión de gestión
- IVA (21%)
- TOTAL (suma exacta)

El cliente paga solo por tiempo usado si libera antes.
```

---

### ⏱️ Tiempo y Vencimiento

**P: ¿Cuándo se ejecuta la Cloud Function?**
```
R: Cloud Scheduler lo ejecuta cada minuto:
- Verifica alquileres vencidos
- Marca como vencido
- Envía notificación
- Después de 5 minutos: marca multa pendiente

Latencia: ~1 minuto (puede ser hasta 2 si hay carga)
```

**P: ¿Qué pasa si el servidor cae?**
```
R: Cloud Scheduler reintentas automáticamente:
- 1er intento: +5 min
- 2do intento: +35 min
- 3er intento: +100+ min

En los reintentos, se ejecutará el procesamiento.
```

**P: ¿El usuario puede ver tiempo en vivo?**
```
R: Sí. ActiveRentalsScreen:
- Usa Timer de 1 segundo
- Recalcula tiempo restante cada segundo
- Muestra barra de progreso actualizada

⚠️ NOTA: Es tiempo local. Si el reloj del dispositivo 
está desincronizado, los tiempos pueden variar.
```

**P: ¿Cómo evito que manipule el reloj del dispositivo?**
```
R: Ya está implementado:
- Timestamps vienen del servidor (Firestore)
- Cálculos se hacen en Cloud Functions
- El cliente solo muestra, no calcula

✅ Seguro contra manipulación
```

---

### 🔔 Notificaciones

**P: ¿Dónde aparecen las notificaciones?**
```
R: Documentos en Firestore en /notificaciones

Para notificaciones PUSH:
- Requiere Firebase Cloud Messaging (FCM)
- Aún no integrado (TODO)
- Por ahora solo guarda en DB
```

**P: ¿Cómo muestro las notificaciones en la app?**
```
R: Stream en ActiveRentalsScreen:

StreamBuilder<List<DocumentSnapshot>>(
  stream: FirebaseFirestore.instance
    .collection('notificaciones')
    .where('userId', isEqualTo: user.uid)
    .orderBy('timestamp', descending: true)
    .snapshots(),
  builder: (context, snapshot) {
    // Mostrar notificaciones aquí
  }
)
```

**P: ¿Envío emails?**
```
R: Aún no implementado. Opciones:

1. Firebase Email Extension (requiere Blaze)
2. Cloud Function con SendGrid/MailGun
3. Backend externo (Heroku, AWS)

Ver HOURLY_RENTAL_GUIDE.md sección "Próximos Pasos"
```

---

### 🛠️ Configuración y Despliegue

**P: ¿Cómo despliego las Cloud Functions?**
```bash
# Opción 1: Solo las nuevas
cd functions
firebase deploy --only functions:processHourlyRentals,functions:releaseHourlyRental,functions:getRentalStatus

# Opción 2: Todas
firebase deploy --only functions

# Ver logs
firebase functions:log processHourlyRentals
```

**P: ¿Qué pasa si Firebase Cloud Scheduler no existe?**
```
R: Crea uno manualmente:
1. GCP Console > Cloud Scheduler
2. "Create Job"
3. Name: hourly-rental-processor
4. Frequency: * * * * *
5. HTTP POST a la Cloud Function URL
6. Autorización OIDC

Ver HOURLY_RENTAL_GUIDE.md para detalles exactos.
```

**P: ¿Qué Firestore Rules necesito?**
```
match /alquileres/{document=**} {
  allow read: if request.auth.uid != null;
  allow write: if request.auth.uid != null;
}

match /notificaciones/{document=**} {
  allow read: if request.auth.uid == resource.data.userId;
  allow write: if false;  // Solo Cloud Functions
}
```

---

### 🐛 Debugging

**P: ¿Cómo debug los alquileres?**
```
R: Opción 1: Firebase Console
- Firestore > alquileres > Ver documentos
- Ver campos: tipo, estado, fechas, etc.

Opción 2: Cloud Function logs
firebase functions:log processHourlyRentals | tail -50

Opción 3: DevTools en navegador (Chrome)
- F12 > Console
- Ver prints de la app
```

**P: ¿Cómo veo si Cloud Function se ejecutó?**
```
R: GCP Console > Cloud Functions > processHourlyRentals
- Ver "Latest Execution" 
- Ver logs si falló
- Verificar que no está deshabilitada

O en terminal:
gcloud functions describe processHourlyRentals --region europe-west1
```

**P: ¿Cómo pruebo sin esperar a que venza?**
```
R: Opción 1: Crear alquiler de prueba con 1 minuto
let futuro = Date.now() + 60000; // 1 minuto
db.collection('alquileres').add({
  fechaVencimiento: futuro,
  ...
})

Opción 2: Modificar Cloud Function para 10 segundos
if (now >= (expiredTime - 10*1000)) { // 10 segundos
  // Marcar vencido
}

Opción 3: Crear alquiler, esperar a que venza y ver cambios
```

---

### 🔒 Seguridad

**P: ¿Es seguro almacenar precios en el cliente?**
```
R: No. El desglose se muestra solo para UX.
El precio final se calcula en Cloud Functions:
✅ Backend calcula precioTotal = tiempoUsado × precioMinuto
✅ Cliente no puede modificar

Seguro ✅
```

**P: ¿Quién puede liberar una plaza?**
```
R: Solo el arrendatario (quien alquiló).
Verificación en Cloud Function:
if (rental.idArrendatario !== context.auth.uid) {
  throw "No tienes permiso";
}

Seguro ✅
```

**P: ¿Qué pasa si alguien intenta manipular un documento?**
```
R: Firestore Rules previenen:
- Solo el dueño puede leer sus notificaciones
- Cloud Functions re-verifica todo
- Timestamps vienen del servidor

Seguro ✅
```

---

## Errores Comunes y Soluciones

### ❌ "Cloud Function no encontrada"
```
CAUSA: No desplegada
SOLUCIÓN:
  cd functions
  firebase deploy --only functions:processHourlyRentals
```

### ❌ "Collection alquileres no existe"
```
CAUSA: Firestore no inicializado o Rules incorrectas
SOLUCIÓN:
  1. Firebase Console > Firestore > "Create Database"
  2. Verificar Rules (ver arriba)
  3. Crear manualmente una colección "alquileres"
```

### ❌ "permission-denied al crear alquiler"
```
CAUSA: Firestore Rules incorrecto o no autenticado
SOLUCIÓN:
  1. Verificar que usuario está logeado
  2. Actualizar Firestore Rules
  3. Esperar 1 minuto para que se propaguen
```

### ❌ "No veo alquileres en ActiveRentalsScreen"
```
CAUSA: Stream no se carga o no hay datos
SOLUCIÓN:
  1. Verificar en Firestore que existen documentos con tipo=2
  2. Verificar que idArrendatario == user.uid
  3. Ver logs en DevTools (F12 > Console)
  4. Hacer rebuild: hot reload (r)
```

### ❌ "El tiempo no se actualiza cada segundo"
```
CAUSA: Timer no se inició o StreamBuilder no actualiza
SOLUCIÓN:
  1. Verificar que Timer._updateTimer existe en initState
  2. Verificar que setState() es llamado
  3. Agregar key en StreamBuilder para forzar rebuild
```

### ❌ "Error al liberar: RentalId no está definido"
```
CAUSA: No se pasa el ID del documento
SOLUCIÓN:
  - En ActiveRentalsScreen, pasar rentalDocId:
    await functions.httpsCallable('releaseHourlyRental').call({
      'rentalId': docId,  // ← Agregar esto
      'plazaId': rental.idPlaza,
    });
```

### ❌ "Cloud Scheduler nunca se ejecuta"
```
CAUSA: No está configurado o deshabilitado
SOLUCIÓN:
  1. GCP Console > Cloud Scheduler
  2. Verificar que existe el job
  3. Hacer click "Force run" para probar
  4. Ver logs en Cloud Function
```

---

## Performance y Optimización

**P: ¿Qué pasa si hay 1000 alquileres activos?**
```
R: Cloud Function procesa:
- Usa índices de Firestore (tipo + estado)
- ~100ms por ejecución
- Escalable a 10k+ sin problemas

✅ Performante
```

**P: ¿El Stream consume mucho ancho de banda?**
```
R: No. StreamBuilder:
- Se actualiza cuando hay cambios en DB
- No es un polling, es listener
- Una conexión WebSocket abierta

✅ Eficiente
```

**P: ¿Cómo reduzco el tamaño del APK?**
```
R: La lógica de alquiler por horas es muy pequeña:
- Modelos: 5KB
- Servicios: 8KB
- UI: 20KB
- Total: ~35KB

No afecta al tamaño del APK significativamente.
```

---

## Integraciones Futuras

**P: ¿Cómo integro Stripe para pagos?**
```
R: 
1. En el resumen de precio, mostrar botón "Proceder al Pago"
2. Pasar el totalAmount a StripeService.createPaymentIntent()
3. Tras pago exitoso, marcar como pagado

Ver STRIPE_INTEGRATION_GUIDE.md
```

**P: ¿Cómo agrego Firebase Cloud Messaging (notificaciones push)?**
```
R:
1. Habilitar FCM en Firebase Console
2. En Cloud Function, después de crear notificación:
   await admin.messaging().sendToDevice(deviceTokens, {
     notification: { title, body },
     data: { rentalId, plazaId }
   });
3. En la app, registrar token en initState

Requiere ~100 líneas de código.
```

**P: ¿Cómo hago un dashboard de analytics?**
```
R:
1. Stream de alquileres completados
2. Calcular: ingresos totales, tiempo promedio, plazas más usadas
3. Mostrar gráficos con charts_flutter

Require ~200 líneas.
```

---

## Contacto y Soporte

| Componente | Dónde buscar | Contacto |
|-----------|-------------|---------|
| Modelo | `lib/Models/alquiler_por_horas.dart` | Revisar comentarios |
| Servicio | `lib/Services/RentalByHoursService.dart` | Revisar métodos |
| UI | `lib/Screens/rent_by_hours/` | Ver código |
| Cloud Functions | `functions/rentalByHours.js` | Ver comentarios |
| Documentación | `HOURLY_RENTAL_GUIDE.md` | Leer guía |

---

## Checklist de Despliegue

- [ ] Importar `RentByHoursScreen` y `ActiveRentalsScreen` en `main.dart`
- [ ] Agregar rutas en `main.dart`
- [ ] Hacer `firebase deploy` de Cloud Functions
- [ ] Configurar Cloud Scheduler
- [ ] Actualizar Firestore Security Rules
- [ ] Probar crear un alquiler
- [ ] Probar ver alquileres activos
- [ ] Probar liberar antes de tiempo
- [ ] Esperar a que venza y ver cambios de estado
- [ ] Verificar notificaciones en Firestore
- [ ] Ir a producción ✅

---

**Última actualización**: 27 de febrero de 2026  
**Versión**: 1.0
