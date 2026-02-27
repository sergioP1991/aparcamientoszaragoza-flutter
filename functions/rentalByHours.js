const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Asegurarse de que Firebase esté inicializado
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Procesa alquileres por horas expirados
 * Se ejecuta cada minuto para:
 * 1. Marcar alquileres como vencidos cuando llega la hora
 * 2. Enviar notificación de vencimiento
 * 3. Marcar alquileres como multa pendiente después de 5 minutos
 * 4. Enviar notificación de multa potencial
 */
exports.processHourlyRentals = functions
  .region('europe-west1')
  .pubsub.schedule('every 1 minutes')
  .onRun(async (context) => {
    console.log('🕐 Iniciando procesamiento de alquileres por horas...');
    
    try {
      const now = new Date();
      
      // 1. Buscar alquileres activos que ya vencieron
      const expiredRentals = await db
        .collection('alquileres')
        .where('tipo', '==', 2) // Alquiler por horas
        .where('estado', '==', 'EstadoAlquilerPorHoras.activo')
        .where('fechaVencimiento', '<=', now)
        .get();

      console.log(`📋 Encontrados ${expiredRentals.docs.length} alquileres vencidos`);

      // Procesar alquileres vencidos
      for (const doc of expiredRentals.docs) {
        const rental = doc.data();
        
        try {
          // Actualizar estado a vencido
          await doc.ref.update({
            estado: 'EstadoAlquilerPorHoras.vencido',
            tiempoUsado: rental.duracionContratada,
            precioTotal: rental.duracionContratada * rental.precioMinuto,
            notificacionVencimientoEnviada: true,
          });

          console.log(`✅ Alquiler ${doc.id} marcado como vencido`);

          // Enviar notificación de vencimiento
          await sendExpiredNotification(rental, doc.id);
        } catch (error) {
          console.error(`❌ Error procesando alquiler ${doc.id}:`, error);
        }
      }

      // 2. Buscar alquileres vencidos que ya pasaron el margen de 5 minutos
      const penaltyRentals = await db
        .collection('alquileres')
        .where('tipo', '==', 2) // Alquiler por horas
        .where('estado', '==', 'EstadoAlquilerPorHoras.vencido')
        .where('notificacionMultaEnviada', '==', false)
        .get();

      console.log(`📋 Encontrados ${penaltyRentals.docs.length} alquileres en margen de multa`);

      // Procesar alquileres con multa pendiente
      for (const doc of penaltyRentals.docs) {
        const rental = doc.data();
        const expiredTime = new Date(rental.fechaVencimiento.toDate());
        const marginTime = new Date(expiredTime.getTime() + 5 * 60 * 1000); // 5 minutos
        
        if (now >= marginTime) {
          try {
            // Actualizar estado a multa pendiente
            await doc.ref.update({
              estado: 'EstadoAlquilerPorHoras.multa_pendiente',
              notificacionMultaEnviada: true,
            });

            console.log(`⚠️ Alquiler ${doc.id} marcado como multa pendiente`);

            // Enviar notificación de multa potencial
            await sendPenaltyNotification(rental, doc.id);
          } catch (error) {
            console.error(`❌ Error procesando multa ${doc.id}:`, error);
          }
        }
      }

      console.log('✨ Procesamiento de alquileres completado');
      return null;
    } catch (error) {
      console.error('❌ Error en processHourlyRentals:', error);
      return null;
    }
  });

/**
 * Libera una plaza por horas (llamado desde la app)
 */
exports.releaseHourlyRental = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    // Verificar autenticación
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
    }

    const { rentalId, plazaId } = data;

    if (!rentalId) {
      throw new functions.https.HttpsError('invalid-argument', 'rentalId es requerido');
    }

    try {
      const rentalDoc = await db.collection('alquileres').doc(rentalId).get();
      
      if (!rentalDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Alquiler no encontrado');
      }

      const rental = rentalDoc.data();

      // Verificar que el usuario es el arrendatario
      if (rental.idArrendatario !== context.auth.uid) {
        throw new functions.https.HttpsError('permission-denied', 'No tienes permiso para liberar este alquiler');
      }

      // Calcular tiempo usado
      const startTime = new Date(rental.fechaInicio.toDate());
      const now = new Date();
      const minutesUsed = Math.floor((now - startTime) / (1000 * 60));

      // Calcular precio final
      const finalPrice = minutesUsed * rental.precioMinuto;

      // Actualizar alquiler
      await rentalDoc.ref.update({
        estado: 'EstadoAlquilerPorHoras.liberado',
        fechaLiberacion: now,
        tiempoUsado: minutesUsed,
        precioTotal: finalPrice,
      });

      console.log(`✅ Alquiler ${rentalId} liberado. Tiempo usado: ${minutesUsed} minutos. Precio: ${finalPrice}€`);

      // Registrar actividad
      const user = await admin.auth().getUser(context.auth.uid);
      await db.collection('historial_actividad').add({
        userId: context.auth.uid,
        tipo: 'liberacion_alquiler_horas',
        descripcion: `Liberó plaza de aparcamiento`,
        plazaId: plazaId,
        alquilerId: rentalId,
        minutosUsados: minutesUsed,
        precioFinal: finalPrice,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        minutesUsed: minutesUsed,
        finalPrice: finalPrice,
        message: `Has liberado la plaza. Has usado ${minutesUsed} minutos. Debes pagar ${finalPrice}€`,
      };
    } catch (error) {
      console.error('Error liberando alquiler:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

/**
 * Obtiene el estado actual de un alquiler
 */
exports.getRentalStatus = functions
  .region('europe-west1')
  .https.onCall(async (data, context) => {
    // Verificar autenticación
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
    }

    const { rentalId } = data;

    if (!rentalId) {
      throw new functions.https.HttpsError('invalid-argument', 'rentalId es requerido');
    }

    try {
      const rentalDoc = await db.collection('alquileres').doc(rentalId).get();
      
      if (!rentalDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Alquiler no encontrado');
      }

      const rental = rentalDoc.data();

      // Verificar que el usuario es el arrendatario
      if (rental.idArrendatario !== context.auth.uid) {
        throw new functions.https.HttpsError('permission-denied', 'No tienes permiso para ver este alquiler');
      }

      const now = new Date();
      const expiredTime = new Date(rental.fechaVencimiento.toDate());
      const startTime = new Date(rental.fechaInicio.toDate());
      const minutesUsed = Math.floor((now - startTime) / (1000 * 60));
      const minutesRemaining = Math.max(0, Math.floor((expiredTime - now) / (1000 * 60)));

      return {
        rentalId,
        estado: rental.estado,
        minutesUsed,
        minutesRemaining,
        durationContracted: rental.duracionContratada,
        pricePerMinute: rental.precioMinuto,
        estimatedPrice: minutesUsed * rental.precioMinuto,
        isExpired: now >= expiredTime,
        isInPenaltyMargin: now >= expiredTime && now < new Date(expiredTime.getTime() + 5 * 60 * 1000),
        hasPenalty: now >= new Date(expiredTime.getTime() + 5 * 60 * 1000),
      };
    } catch (error) {
      console.error('Error obteniendo estado del alquiler:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

/**
 * Envía notificación cuando un alquiler vence
 */
async function sendExpiredNotification(rental, rentalId) {
  try {
    const userDoc = await admin.auth().getUser(rental.idArrendatario);
    
    // Crear documento de notificación
    await db.collection('notificaciones').add({
      userId: rental.idArrendatario,
      tipo: 'alquiler_vencido',
      titulo: '⏰ Tu alquiler ha vencido',
      mensaje: `Tu alquiler de la plaza ${rental.idPlaza} ha vencido. Por favor libérala ahora para evitar una multa.`,
      plazaId: rental.idPlaza,
      rentalId: rentalId,
      leida: false,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`📧 Notificación de vencimiento enviada a ${userDoc.email}`);

    // TODO: Integrar con Firebase Cloud Messaging para notificación push
    // await admin.messaging().sendToDevice(deviceTokens, {
    //   notification: {
    //     title: '⏰ Tu alquiler ha vencido',
    //     body: `Plaza ${rental.idPlaza} debe ser liberada`,
    //   },
    //   data: {
    //     rentalId: rentalId,
    //     type: 'expired_rental',
    //   },
    // });
  } catch (error) {
    console.error('Error enviando notificación de vencimiento:', error);
  }
}

/**
 * Envía notificación cuando hay multa pendiente
 */
async function sendPenaltyNotification(rental, rentalId) {
  try {
    const userDoc = await admin.auth().getUser(rental.idArrendatario);
    
    // Crear documento de notificación
    await db.collection('notificaciones').add({
      userId: rental.idArrendatario,
      tipo: 'multa_pendiente',
      titulo: '⚠️ Multa Pendiente',
      mensaje: `Has pasado el margen de 5 minutos para liberar la plaza ${rental.idPlaza}. Si no la liberas ahora, se te aplicará una multa.`,
      plazaId: rental.idPlaza,
      rentalId: rentalId,
      leida: false,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`📧 Notificación de multa enviada a ${userDoc.email}`);

    // TODO: Integrar con Firebase Cloud Messaging para notificación push más urgente
  } catch (error) {
    console.error('Error enviando notificación de multa:', error);
  }
}
