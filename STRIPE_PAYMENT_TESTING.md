# 💳 Testing de Pagos con Stripe en Web

## 🧪 Tarjetas de Prueba

### Tarjeta Visa (Éxito)
- **Número**: `4242 4242 4242 4242`
- **Mes/Año**: `12/25` (cualquier fecha futura)
- **CVC**: `123`
- **Resultado**: ✅ Pago exitoso

### Tarjeta Rechazada
- **Número**: `4000 0000 0000 0002`
- **Mes/Año**: `12/25`
- **CVC**: `123`
- **Resultado**: ❌ Pago rechazado

### Tarjeta 3D Secure
- **Número**: `4000 0025 0000 3155`
- **Mes/Año**: `12/25`
- **CVC**: `123`
- **Resultado**: ⚠️ Requiere autenticación 3D Secure

## 🔄 Flujo de Pago en Web

1. **Usuario selecciona "Alquilar"** en detalles de plaza
2. **Selecciona método de pago**: Tarjeta, Apple Pay, Google Pay, PayPal
3. **Click en "Confirmar Pago"**
4. Se abre diálogo "Procesando pago..."
5. La app:
   - Crea un `PaymentIntent` en Stripe
   - Obtiene el `clientSecret`
   - Confirma el pago via API REST
   - Muestra resultado al usuario

## 📋 Cómo Probar

### Paso 1: Abrir la app
```
http://localhost:50251
```

### Paso 2: Navegar a una plaza
1. Ir a **Home** → seleccionar cualquier plaza
2. Ir a **Detalles** → click en **Alquilar**

### Paso 3: Seleccionar fechas
- En la pantalla de alquiler, seleccionar fechas (si es alquiler especial)
- Ver el resumen con total a pagar

### Paso 4: Procesar pago
1. En la sección **"Selecciona método de pago"**:
   - ✅ Seleccionar **Tarjeta**
   - Click en **"Confirmar Pago"**

### Paso 5: Ingresar tarjeta de prueba
Cuando se abra el formulario de pago:
- Número: `4242 4242 4242 4242`
- Fecha: `12/25`
- CVC: `123`
- Nombre: Cualquier nombre
- Email: Cualquier email

### Paso 6: Verificar resultado
- ✅ Si ves "¡Éxito!" → El pago fue procesado
- ❌ Si ves error → Revisa los logs en F12 → Console

## 🔍 Debugging

### Ver logs en Chrome
1. Presiona **F12** para abrir DevTools
2. Ir a **Console**
3. Buscar mensajes que comienzan con:
   - `🔑` (creación de intent)
   - `💳` (procesamiento de pago)
   - `✅` (éxito)
   - `❌` (error)

### Ejemplo de flujo exitoso
```
🔑 createPaymentIntent: Creando intent real en Stripe...
💰 Monto: 45.00 eur
📡 Respuesta de Stripe: 201
✅ Payment Intent creado: pi_1234567890
🌐 processCardPayment (WEB): Confirmando PaymentIntent con Stripe...
📡 Respuesta de confirmación: 200
✅ Estado del pago: succeeded
💳 Resultado de pago: succeeded
✅ Pago exitoso: pi_1234567890
```

## ⚠️ Errores Comunes

### Error: "401 Unauthorized"
- **Causa**: Autenticación incorrecta con Stripe
- **Solución**: Verificar que se está usando `Basic Auth` con Secret Key

### Error: "400 Bad Request"
- **Causa**: Parámetros inválidos en la solicitud
- **Solución**: Revisar los logs para ver qué parámetro es inválido

### Error: "Pago requiere confirmación adicional"
- **Causa**: Se necesita 3D Secure (tarjeta `4000 0025 0000 3155`)
- **Solución**: En producción, redirigir a `return_url` para completar 3D Secure

## 🚀 Próximos Pasos

1. **Integrar Stripe Elements** para formulario de tarjeta más seguro
2. **Agregar manejo de 3D Secure** para pagos autenticados
3. **Integrar webhooks** para confirmar pagos en backend
4. **Mover Secret Key a Cloud Functions** (no hardcodearla en app)

## 📚 Referencias

- [Stripe Testing Cards](https://stripe.com/docs/testing)
- [Payment Intents API](https://stripe.com/docs/payments/payment-intents)
- [3D Secure / SCA](https://stripe.com/docs/payments/3d-secure)
