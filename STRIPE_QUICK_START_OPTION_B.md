# Stripe Client-Side (Opción B) - Guía Rápida

## ✅ Lo que está configurado:

1. **StripeService simplificado** - Sin dependencia de Cloud Functions
2. **Pantalla de pago funcional** - Con métodos card, Google Pay, Apple Pay
3. **Inicialización automática** - En main.dart
4. **Ruta registrada** - PaymentPage en rutas

---

## 🚀 Pasos para Probar:

### 1️⃣ Instalar dependencias flutter_stripe:

```bash
flutter pub get
```

### 2️⃣ Ejecutar la app:

```bash
flutter run -d chrome
```

### 3️⃣ Navegar a cualquier plaza:

- Toca una plaza de la lista
- En detalles, verás 3 botones: "Horarios", "Normas", **"Pagar"**
- Toca **"Pagar"**

### 4️⃣ Probar con tarjeta de prueba:

En la pantalla de pago:
1. Selecciona **"Tarjeta de Crédito/Débito"**
2. Toca el botón azul **"Pagar..."**
3. Se abre formulario de Stripe
4. Usa tarjeta: `4242 4242 4242 4242` | `12/25` | `123`
5. Completa el pago

---

## 💳 Tarjetas de Prueba:

| Tipo | Número | CVC | Fecha |
|------|--------|-----|-------|
| ✅ Éxito | 4242 4242 4242 4242 | 123 | 12/25 |
| ❌ Fallo | 4000 0000 0000 0002 | 123 | 12/25 |
| ⚠️ 3D Sec | 4000 0025 0000 3155 | 123 | 12/25 |

---

## 📱 Métodos Disponibles (Opción B):

✅ Tarjeta (funciona en web/Android/iOS)
✅ Google Pay (Android/Chrome)
✅ Apple Pay (iOS/Mac)
⚠️ Otros (requieren Cloud Function)

---

## 🔐 Limitaciones (vs Opción A con Cloud Function):

❌ No hay webhooks
❌ No persiste en Firestore automáticamente
❌ Menos seguro (Secret Key en cliente)
✅ Más rápido para testing

---

## 📊 Flujo Actual:

```
Pantalla Pago
    ↓
Seleccionar método (Card/GooglePay/ApplePay)
    ↓
Crear Payment Intent vía API Stripe
    ↓
Procesar pago con Stripe SDK
    ↓
Mostrar confirmación
```

---

## 🎯 Próximos Pasos (Opcional):

Si quieres agregar webhooks y persistencia:

1. Desplegar Cloud Functions (Opción A completa)
2. Guardar pagos en Firestore
3. Crear reservas automáticamente

---

**¡Ya funciona! Prueba a hacer un pago de prueba 🎉**

Tus claves ya están configuradas:
- `pk_test_51SuUod2KaK54WVOoow3ceAdHyLefry0S7wHHA5R0SfjFyB9mVyfwpocCmt0adzDFDiwsaM4diLCht1E98oJV8UWU00H20ta2MQ`
