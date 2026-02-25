# Configuración de Webhook en Stripe - Guía Paso a Paso

## 📋 Tus Claves (Entorno Test)

```
Publishable Key: pk_test_51SuUod2KaK54WVOoow3ceAdHyLefry0S7wHHA5R0SfjFyB9mVyfwpocCmt0adzDFDiwsaM4diLCht1E98oJV8UWU00H20ta2MQ
Secret Key: sk_test_51SuUod2KaK54WVOoDRRDNKAb4BoDBWT6pycLg45iSQIMDIrR1kfWd3GP9K1pDdAubZqChuHIA24o7MsmukcTFC53009adHE2Hl
```

⚠️ **IMPORTANTE**: Nunca comitees la Secret Key al repositorio. Se ha guardado en el código solo para desarrollo local. En producción, usar Firebase Environment Variables.

---

## 🔧 Configuración del Webhook en Stripe Dashboard

### Paso 1: Acceder al Dashboard de Stripe

1. Ve a **https://dashboard.stripe.com**
2. Inicia sesión con tu cuenta
3. Asegúrate de estar en **Test Mode** (verás "Test mode" en la esquina superior)

### Paso 2: Navegar a Webhooks

1. En el panel izquierdo, ve a **Developers** (ícono de código `</>`):
   ```
   Dashboard > Developers (lado izquierdo) > Webhooks
   ```

2. O accede directamente a:
   ```
   https://dashboard.stripe.com/webhooks
   ```

### Paso 3: Crear Endpoint (Opción A - Firebase Hosting + Cloud Functions)

**Si ya tienes Firebase desplegado:**

1. **Obtener URL de tu Cloud Function:**
   ```
   https://europe-west1-YOUR_PROJECT_ID.cloudfunctions.net/stripeWebhook
   ```
   
   Para encontrar tu Project ID:
   - Firebase Console > Configuración del Proyecto
   - O ejecutar: `firebase projects:list`

2. **En Stripe Dashboard, click en "Add an endpoint"**

3. **Ingresa la URL:**
   ```
   https://europe-west1-aparcamientodisponible.cloudfunctions.net/stripeWebhook
   ```

4. **Selecciona "Receive all events" (recomendado para inicio)**

5. **O selecciona eventos específicos:**
   ```
   ✅ payment_intent.succeeded
   ✅ payment_intent.payment_failed
   ✅ charge.refunded
   ```

6. **Click "Add endpoint"**

### Paso 4: Crear Endpoint (Opción B - Testing Local con ngrok)

**Para probar webhooks localmente sin desplegar:**

1. **Instalar ngrok:**
   ```bash
   brew install ngrok  # macOS
   # o descargar de https://ngrok.com
   ```

2. **Ejecutar tu Cloud Function localmente:**
   ```bash
   firebase emulators:start
   # O ejecutar el servidor Node.js directamente
   node functions/index.js
   ```

3. **Exponer con ngrok:**
   ```bash
   ngrok http 5001
   ```
   
   Te dará algo como:
   ```
   Forwarding                    https://abc123.ngrok.io -> http://localhost:5001
   ```

4. **En Stripe Dashboard:**
   - Endpoint URL: `https://abc123.ngrok.io/stripeWebhook`
   - Event types: Todos o selecciona los necesarios

5. **Copiar Signing Secret (ver paso 5)**

---

## 🔐 Paso 5: Copiar Webhook Signing Secret

Después de crear el endpoint:

1. El endpoint aparecerá en la lista
2. Haz click en él para ver detalles
3. Copia el **Signing Secret** (empieza con `whsec_`):
   ```
   whsec_test_XXXXXXXXXXXXX
   ```

4. **Guardar en tu proyecto:**

### Opción A: En Firebase Environment Variables (RECOMENDADO)
```bash
# En functions/.env.local (NO COMMITEAR)
STRIPE_WEBHOOK_SECRET=whsec_test_XXXXXXXXXXXXX
STRIPE_SECRET_KEY=sk_test_51SuUod2KaK54WVOoDRRDNKAb4BoDBWT6pycLg45iSQIMDIrR1kfWd3GP9K1pDdAubZqChuHIA24o7MsmukcTFC53009adHE2Hl
```

Luego desplegar:
```bash
firebase deploy --only functions
```

### Opción B: En Firebase Remote Config
```bash
# Firebase Console > Remote Config
# Agregar parámetro:
stripe_webhook_secret: whsec_test_XXXXXXXXXXXXX
```

### Opción C: Local .env para testing
```bash
# .env (NO COMMITEAR)
STRIPE_WEBHOOK_SECRET=whsec_test_XXXXXXXXXXXXX
```

---

## 🧪 Paso 6: Probar el Webhook

### Opción A: Desde Stripe Dashboard

1. En la página del webhook endpoint
2. Scroll down a "Event deliveries"
3. Click en "Send test event"
4. Selecciona "charge.succeeded" (o payment_intent.succeeded)
5. Click "Send event"

**Verifica:**
- Status debería ser ✅ **200** (éxito)
- Si es ❌ **400 o 500**, revisar logs

### Opción B: Crear un Pago Real de Prueba

1. **En tu app Flutter:**
   ```bash
   flutter run -d chrome
   ```

2. **Navega a detalle de plaza → Pagar**

3. **Selecciona método: Tarjeta**

4. **Usa tarjeta de prueba exitosa:**
   ```
   Número: 4242 4242 4242 4242
   MM/YY: 12/25
   CVC: 123
   ```

5. **Completa el pago**

6. **Verifica en Stripe Dashboard:**
   - Developers > Webhooks > Event deliveries
   - Deberías ver eventos como `payment_intent.succeeded`

---

## 📊 Ver Eventos Webhook

### En Stripe Dashboard:

1. **Developers > Webhooks**
2. **Click en tu endpoint**
3. **Scroll a "Event deliveries"**
4. Verás lista de eventos con estado:
   ```
   ✅ 200 - Exitoso
   ⚠️ 4xx/5xx - Error
   ⏳ Pendiente - Esperando respuesta
   ```

### Ver detalles del evento:

1. Click en un evento
2. Verás:
   - **Request:** JSON que Stripe envió
   - **Response:** Respuesta de tu servidor
   - **Timestamp:** Hora exacta

---

## 🚨 Troubleshooting

### ❌ Error: "Invalid Signature"

**Causa:** Webhook Signing Secret incorrecto

**Solución:**
```dart
// En functions/stripePayments.js, verifica:
const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
console.log('Secret:', endpointSecret); // Debug

// Debe coincidir exactamente con el de Stripe Dashboard
```

### ❌ Error: "404 Not Found"

**Causa:** URL del endpoint incorrecta o Cloud Function no desplegada

**Solución:**
```bash
# Verificar que la función está desplegada:
firebase deploy --only functions

# Ver logs:
firebase functions:log
```

### ❌ Error: "Connection Refused"

**Causa:** Con ngrok, puerto incorrecto

**Solución:**
```bash
# Verificar que ngrok apunta al puerto correcto:
ngrok http 5001  # Si tu servidor corre en 5001

# O si usas Firebase Emulator:
firebase emulators:start --only functions
```

### ⏳ Webhook no recibe eventos

**Causa:** Endpoint no está activo en Stripe

**Solución:**
1. Ve a Stripe Dashboard > Webhooks
2. Verifica que el endpoint esté **habilitado** (no deshabilitado)
3. Prueba con "Send test event"

---

## 📝 Estructura de tu Cloud Function

```javascript
// functions/stripePayments.js

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    // Verifica la firma del webhook
    event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (error) {
    console.error('Webhook signature verification failed:', error);
    return res.status(400).send(`Webhook Error: ${error.message}`);
  }

  // Procesa el evento
  switch (event.type) {
    case 'payment_intent.succeeded':
      console.log('✅ Pago exitoso:', event.data.object.id);
      // Crear reserva en Firestore
      break;
    
    case 'payment_intent.payment_failed':
      console.log('❌ Pago fallido:', event.data.object.id);
      // Registrar fallo
      break;
    
    case 'charge.refunded':
      console.log('💰 Reembolso procesado:', event.data.object.id);
      // Actualizar estado de reserva
      break;
  }

  res.json({ received: true });
});
```

---

## ✅ Checklist de Configuración Completada

- [ ] Claves de Stripe agregadas a `StripeService.dart`
- [ ] Claves copiadas a `functions/.env.local`
- [ ] Cloud Function desplegada: `firebase deploy --only functions`
- [ ] Webhook endpoint creado en Stripe Dashboard
- [ ] Webhook Signing Secret guardado en Environment Variables
- [ ] Evento de prueba enviado desde Dashboard (resultado ✅)
- [ ] Pago de prueba completado desde la app
- [ ] Evento recibido en Stripe Dashboard

---

## 🎯 Próximos Pasos

1. **Probar flujo completo:**
   ```bash
   flutter run -d chrome
   # Navega a plaza → Pagar → Selecciona método → Ingresa tarjeta 4242...
   ```

2. **Verificar en Firestore:**
   - Colección `payments` → Documento con `status: 'succeeded'`
   - Colección `reservas` → Nueva reserva creada

3. **Ver logs:**
   ```bash
   firebase functions:log
   ```

4. **Monitorear eventos:**
   - Stripe Dashboard > Webhooks > Event deliveries

---

## 🔐 Seguridad en Producción

Cuando cambies a `pk_live_` y `sk_live_`:

1. **Nunca commitear claves de producción:**
   ```bash
   # En .gitignore:
   functions/.env.local
   functions/.env.production
   ```

2. **Usar Firebase Environment Variables:**
   ```bash
   firebase functions:config:set stripe.secret_key="sk_live_XXXXX"
   ```

3. **Habilitar Certificate Pinning en Flutter:**
   ```dart
   // En StripeService.dart
   HttpClient client = HttpClient();
   client.badCertificateCallback = (cert, host, port) => false; // Rechaza certificados inválidos
   ```

4. **Revisar Logs regularmente:**
   - Firebase Console > Functions > Logs

---

**¡Tu webhook está listo para recibir pagos! 🎉**

Próximo paso: [Prueba tu primer pago](STRIPE_INTEGRATION_GUIDE.md#-testing)
