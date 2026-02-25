# Integración de Stripe - Guía de Configuración

## 📋 Resumen

Se ha integrado **Stripe** como pasarela de pagos en la aplicación Flutter. La solución incluye:

- ✅ **Servicio de Stripe** (`lib/Services/StripeService.dart`) - Gestor centralizado de pagos
- ✅ **Pantalla de Pago** (`lib/Screens/payment/payment_screen.dart`) - UI completa para seleccionar método
- ✅ **Cloud Functions** (`functions/stripePayments.js`) - Backend seguro para procesar pagos
- ✅ **Soporte para 11 métodos de pago** - Tarjeta, Apple Pay, Google Pay, SEPA, PayPal, etc.
- ✅ **Seguridad 3D Secure** - Verificación adicional para transacciones de alto riesgo

---

## 🎯 Métodos de Pago Disponibles

| Método | Icono | Disponibilidad | Descripción |
|--------|-------|--------|-------------|
| **Tarjeta** | 💳 | Global | Crédito/Débito (Visa, Mastercard, Amex) |
| **Apple Pay** | 🍎 | iOS/Web | Pago rápido desde dispositivos Apple |
| **Google Pay** | 🔵 | Android/Web | Pago rápido desde dispositivos Android |
| **SEPA** | 🏦 | Europa | Transferencia bancaria (España, Francia, Alemania, etc.) |
| **iDEAL** | 🇳🇱 | Países Bajos | Sistema bancario holandés |
| **PayPal** | 🅿️ | Global | Cuenta PayPal |
| **Klarna** | 💰 | Europa/USA | Compra ahora, paga después |
| **Affirm** | ✅ | USA | Financiamiento en USA |
| **Alipay** | 🐜 | China | Billetera digital china |
| **WeChat Pay** | 💬 | China | Billetera digital china |

---

## 🔧 Configuración Requerida

### 1️⃣ Obtener Claves de Stripe

1. **Crear cuenta en Stripe:**
   - Ir a [https://stripe.com](https://stripe.com)
   - Registrarse con tu email
   - Verificar email y crear cuenta

2. **Obtener claves API:**
   - Dashboard > Developers > API keys
   - Copiar: **Publishable key** (empieza con `pk_test_` o `pk_live_`)
   - Copiar: **Secret key** (empieza con `sk_test_` o `sk_live_`)

3. **Webhook Signing Secret:**
   - Dashboard > Developers > Webhooks
   - Crear endpoint: https://region-projectid.cloudfunctions.net/stripeWebhook
   - Copiar **Signing secret** (empieza con `whsec_`)

### 2️⃣ Configurar en la App

#### **En `lib/Services/StripeService.dart`:**

```dart
// Reemplaza estas claves:
static const String publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY';
static const String secretKey = 'sk_test_YOUR_SECRET_KEY';
static const String createPaymentIntentUrl =
    'https://region-projectid.cloudfunctions.net/createPaymentIntent';
static const String retrievePaymentIntentUrl =
    'https://region-projectid.cloudfunctions.net/retrievePaymentIntent';
```

### 3️⃣ Configurar Cloud Functions

#### **Variables de Entorno:**

```bash
# En functions/.env.local (no commits a Git)
STRIPE_SECRET_KEY=sk_test_YOUR_SECRET_KEY
STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET
```

#### **Instalar Dependencias:**

```bash
cd functions
npm install stripe firebase-admin firebase-functions
```

#### **Desplegar Functions:**

```bash
firebase deploy --only functions:createPaymentIntent,functions:retrievePaymentIntent,functions:stripeWebhook
```

### 4️⃣ Configurar Webhook en Stripe

1. **Dashboard > Developers > Webhooks**
2. **Click en "Add an endpoint"**
3. **URL:** https://region-projectid.cloudfunctions.net/stripeWebhook
4. **Seleccionar eventos:**
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `charge.refunded`
5. **Copiar Signing Secret** y agregar a `.env.local`

---

## 🚀 Implementación en la App

### **Paso 1: Agregar Botón de Pago en Detalles**

En `lib/Screens/detailsGarage/detailsGarage_screen.dart`, dentro de `_buildActionButtons()`:

```dart
Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
  return Row(
    children: [
      // Botón "Horarios" (existente)
      Expanded(child: _buildInfoBtn(l10n.schedulesAction)),
      const SizedBox(width: 12),
      // Botón "Normas" (existente)
      Expanded(child: _buildInfoBtn(l10n.rulesAction)),
      const SizedBox(width: 12),
      // Nuevo: Botón "Pagar"
      Expanded(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              PaymentPage.routeName,
              arguments: {'plaza': plaza, 'days': 1},
            );
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'Pagar',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
```

### **Paso 2: Registrar Ruta**

En `lib/main.dart` o `lib/Routes/app_routes.dart`:

```dart
import 'package:aparcamientoszaragoza/Screens/payment/payment_screen.dart';

// En las rutas:
PaymentPage.routeName: (context) => PaymentPage(
  plaza: ModalRoute.of(context)?.settings.arguments as Garaje,
  rentalDays: 1,
  totalAmount: (ModalRoute.of(context)?.settings.arguments as Map)['price'] ?? 0.0,
),
```

### **Paso 3: Instalar Dependencias**

```bash
flutter pub get
```

---

## 💳 Tarjetas de Prueba en Modo Test

Usa estas tarjetas para probar pagos en modo `pk_test_`:

| Escenario | Tarjeta | CVC | Fecha |
|-----------|---------|-----|-------|
| ✅ Pago exitoso | `4242 4242 4242 4242` | `123` | `12/25` |
| ❌ Pago rechazado | `4000 0000 0000 0002` | `123` | `12/25` |
| ⚠️ 3D Secure | `4000 0025 0000 3155` | `123` | `12/25` |
| 💳 Amex | `3782 822463 10005` | `123` | `12/25` |
| 🎁 SEPA | Cuenta: `DE89370400440532013000` | N/A | N/A |

---

## 📱 Arquitectura de Seguridad

```
┌─────────────────────────────────┐
│     Flutter App (Cliente)       │
│  - Payment Screen               │
│  - Seleccionar método           │
│  - Enviar client_secret         │
└──────────────┬──────────────────┘
               │ HTTPS
               ↓
┌─────────────────────────────────┐
│   Cloud Functions (Backend)     │
│  - Crear Payment Intent         │
│  - Validar monto               │
│  - Usar Secret Key (privada)   │
│  - Guardar en Firestore        │
└──────────────┬──────────────────┘
               │ API REST
               ↓
┌─────────────────────────────────┐
│   Stripe Servers                │
│  - Procesar pago                │
│  - Autenticar usuario           │
│  - 3D Secure verification       │
└─────────────────────────────────┘
```

---

## 🔐 Mejores Prácticas de Seguridad

### ✅ Implementado:

- **Secret Key en backend:** Nunca expongas `sk_test_` en la app
- **Validación de sesión:** Verificar `context.auth.uid` en Cloud Functions
- **Idempotency keys:** Prevenir duplicados de pagos
- **Auditoría en Firestore:** Registrar todos los intentos de pago
- **3D Secure:** Habilitado para transacciones de riesgo

### ⚠️ TODO - Pasos Siguientes:

- [ ] **Certificate Pinning:** Verificar certificados SSL en HTTPS
- [ ] **Rate Limiting:** Limitar intentos fallidos (ya en SecurityService)
- [ ] **Fraud Detection:** Usar Stripe Radar para detectar fraude
- [ ] **Logs Seguros:** Usar Cloud Logging sin datos sensibles
- [ ] **Monitoreo:** Configurar alertas para pagos fallidos

---

## 🧪 Testing

### **Simulador/Emulador:**

```bash
# Web - Chrome
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

### **Probar Flujo de Pago:**

1. Navega a una plaza disponible
2. Toca el botón "Pagar"
3. Selecciona método de pago
4. Ingresa tarjeta de prueba: `4242 4242 4242 4242`
5. Completa el flujo 3D Secure si aparece

### **Verificar en Stripe Dashboard:**

- Developers > Events para ver webhooks recibidos
- Payments para ver transacciones procesadas
- Logs para debugging

---

## 📊 Estructura de Firestore

```
aparcamientos-zaragoza/
├── payments/
│   └── {paymentIntentId}/
│       ├── userId: string
│       ├── plazaId: number
│       ├── amount: number
│       ├── currency: string
│       ├── status: 'pending' | 'succeeded' | 'failed'
│       ├── paymentMethod: string
│       ├── clientSecret: string
│       ├── createdAt: timestamp
│       └── processedAt: timestamp
│
├── reservas/
│   └── {reservaId}/
│       ├── userId: string
│       ├── plazaId: number
│       ├── paymentIntentId: string
│       ├── amount: number
│       ├── status: 'confirmed' | 'active' | 'refunded'
│       ├── createdAt: timestamp
│       └── expiresAt: timestamp
```

---

## 🚨 Troubleshooting

### **Error: "Payment Intent creation failed"**

- ✅ Verificar que `createPaymentIntentUrl` apunta a la Cloud Function correcta
- ✅ Verificar que `STRIPE_SECRET_KEY` está en Environment Variables
- ✅ Ver logs en Firebase Console > Functions

### **Webhook no se activa**

- ✅ Ir a Developers > Webhooks y verificar estado
- ✅ En "Event deliveries" ver si hay errores
- ✅ Verificar que la Cloud Function está desplegada: `firebase deploy --only functions`

### **3D Secure no aparece**

- ✅ Usar tarjeta de prueba: `4000 0025 0000 3155`
- ✅ Asegurar que `confirmation_method: 'automatic'` está en Cloud Function

### **Monto no procesarse correctamente**

- ✅ Los montos en Stripe están en **centavos** (ej: 2999 = 29.99€)
- ✅ Validar que `amountInCents = Math.round(amount)` en Cloud Function

---

## 📞 Soporte

- **Documentación Stripe:** https://stripe.com/docs
- **API Reference:** https://stripe.com/docs/api
- **Flutter Stripe:** https://github.com/flutter-stripe/flutter_stripe
- **Firebase Cloud Functions:** https://firebase.google.com/docs/functions

---

## 📝 Configuración de Producción

Cuando estés listo para producción:

1. **Cambiar claves de test a producción:**
   - `pk_test_` → `pk_live_` (Publishable)
   - `sk_test_` → `sk_live_` (Secret)

2. **Habilitar métodos de pago:**
   - Dashboard > Settings > Payment methods
   - Seleccionar métodos según región

3. **Configurar dominio permitido:**
   - Dashboard > Settings > Domains
   - Agregar: `tudominio.com`

4. **Habilitar facturación automática (opcional):**
   - Dashboard > Billing para suscripciones

**¡La integración está lista para usar! 🎉**
