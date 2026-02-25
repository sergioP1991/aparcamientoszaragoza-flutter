/**
 * Cloud Function para procesar pagos con Stripe
 * 
 * Requisitos:
 * 1. npm install stripe
 * 2. Configurar STRIPE_SECRET_KEY en Environment Variables
 * 3. Habilitar Firebase Authentication y Cloud Firestore
 * 
 * Deploy:
 * firebase deploy --only functions:createPaymentIntent,functions:retrievePaymentIntent
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Inicializar Firebase Admin
admin.initializeApp();
const db = admin.firestore();

/**
 * Crear un Payment Intent para un pago con Stripe
 * 
 * POST /createPaymentIntent
 * Body: {
 *   amount: number (en centavos),
 *   currency: string (ej: 'eur'),
 *   userId: string,
 *   plazaId: number,
 *   paymentMethod: string (ej: 'card'),
 *   description: string,
 *   idempotency_key: string (opcional)
 * }
 */
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  // Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }

  const {
    amount,
    currency = 'eur',
    userId,
    plazaId,
    paymentMethod,
    description,
    idempotency_key,
  } = data;

  // Validaciones
  if (!amount || amount < 100) { // Mínimo 1€
    throw new functions.https.HttpsError('invalid-argument', 'Monto inválido (mínimo 1€)');
  }

  if (!userId || userId !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'No tienes permiso para este pago');
  }

  try {
    // Crear Payment Intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount), // Asegurar que es un entero
      currency: currency.toLowerCase(),
      payment_method_types: [paymentMethod],
      description: description || `Alquiler Plaza #${plazaId}`,
      metadata: {
        userId,
        plazaId,
        timestamp: new Date().toISOString(),
      },
      // Configuración de 3D Secure si es tarjeta
      ...(paymentMethod === 'card' && {
        confirmation_method: 'automatic',
        confirm: false, // Manual confirmation en cliente
      }),
    }, {
      idempotencyKey: idempotency_key,
    });

    // Guardar el pago en Firestore para auditoría
    await db.collection('payments').doc(paymentIntent.id).set({
      userId,
      plazaId,
      amount,
      currency,
      paymentMethod,
      status: paymentIntent.status,
      paymentIntentId: paymentIntent.id,
      clientSecret: paymentIntent.client_secret,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      metadata: paymentIntent.metadata,
    });

    return {
      client_secret: paymentIntent.client_secret,
      payment_intent_id: paymentIntent.id,
      status: paymentIntent.status,
    };
  } catch (error) {
    console.error('Error en createPaymentIntent:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Recuperar el estado de un Payment Intent
 * 
 * POST /retrievePaymentIntent
 * Body: {
 *   client_secret: string,
 *   payment_intent_id: string (alternativa a client_secret)
 * }
 */
exports.retrievePaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }

  const { client_secret, payment_intent_id } = data;

  if (!client_secret && !payment_intent_id) {
    throw new functions.https.HttpsError('invalid-argument', 'Se requiere client_secret o payment_intent_id');
  }

  try {
    // Extraer el ID del client_secret si es necesario
    const intentId = payment_intent_id || client_secret.split('_secret_')[0];

    // Recuperar el Payment Intent
    const paymentIntent = await stripe.paymentIntents.retrieve(intentId);

    // Verificar que el usuario tenga permiso para ver este pago
    const paymentDoc = await db.collection('payments').doc(intentId).get();
    if (paymentDoc.exists && paymentDoc.data().userId !== context.auth.uid) {
      throw new functions.https.HttpsError('permission-denied', 'No tienes permiso para ver este pago');
    }

    return {
      id: paymentIntent.id,
      status: paymentIntent.status,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency.toUpperCase(),
      payment_method_types: paymentIntent.payment_method_types,
      charges: paymentIntent.charges.data.map(charge => ({
        id: charge.id,
        status: charge.status,
        amount: charge.amount,
        payment_method_details: charge.payment_method_details,
      })),
    };
  } catch (error) {
    console.error('Error en retrievePaymentIntent:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Webhook para eventos de Stripe
 * 
 * Configurar en Stripe Dashboard:
 * 1. Ir a Developers > Webhooks
 * 2. Agregar endpoint: https://region-projectid.cloudfunctions.net/stripeWebhook
 * 3. Seleccionar eventos: payment_intent.succeeded, payment_intent.payment_failed
 * 4. Copiar Signing Secret a Environment Variables
 * 
 * Eventos soportados:
 * - payment_intent.succeeded: Pago completado
 * - payment_intent.payment_failed: Pago fallido
 * - charge.refunded: Reembolso procesado
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  if (!endpointSecret) {
    return res.status(500).send('Webhook secret not configured');
  }

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (error) {
    console.error('Webhook signature verification failed:', error);
    return res.status(400).send(`Webhook Error: ${error.message}`);
  }

  try {
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event.data.object);
        break;

      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event.data.object);
        break;

      case 'charge.refunded':
        await handleChargeRefunded(event.data.object);
        break;

      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook handler error:', error);
    res.status(500).send('Webhook handler error');
  }
});

/**
 * Manejar pago exitoso
 */
async function handlePaymentIntentSucceeded(paymentIntent) {
  const { id, metadata, amount, currency } = paymentIntent;

  console.log(`Payment Intent ${id} succeeded`);

  // Actualizar estado del pago en Firestore
  await db.collection('payments').doc(id).update({
    status: 'succeeded',
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Crear reserva en la colección 'reservas'
  if (metadata.userId && metadata.plazaId) {
    await db.collection('reservas').add({
      userId: metadata.userId,
      plazaId: parseInt(metadata.plazaId),
      paymentIntentId: id,
      amount: amount / 100, // Convertir de centavos
      currency: currency.toUpperCase(),
      status: 'confirmed',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 días
      ),
    });
  }

  // Enviar confirmación por email (opcional)
  // await sendPaymentConfirmationEmail(metadata.userId, id, amount);
}

/**
 * Manejar pago fallido
 */
async function handlePaymentIntentFailed(paymentIntent) {
  const { id, metadata, last_payment_error } = paymentIntent;

  console.log(`Payment Intent ${id} failed:`, last_payment_error.message);

  // Actualizar estado del pago
  await db.collection('payments').doc(id).update({
    status: 'failed',
    error: last_payment_error.message,
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Notificar al usuario (opcional)
  // await notifyPaymentFailure(metadata.userId, last_payment_error.message);
}

/**
 * Manejar reembolso
 */
async function handleChargeRefunded(charge) {
  const { payment_intent, amount, refund_status } = charge;

  console.log(`Charge ${charge.id} refunded. Amount: ${amount / 100}`);

  // Actualizar estado de la reserva
  const reservasSnapshot = await db
    .collection('reservas')
    .where('paymentIntentId', '==', payment_intent)
    .get();

  reservasSnapshot.forEach(doc => {
    doc.ref.update({
      status: 'refunded',
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
      refundAmount: amount / 100,
    });
  });
}

// Nota: Para usar en desarrollo local:
// 1. firebase emulators:start
// 2. firebase functions:shell
// 3. payment = firebase.functions().httpsCallable('createPaymentIntent');
