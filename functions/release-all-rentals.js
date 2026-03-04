#!/usr/bin/env node

/**
 * Script para liberar todos los alquileres activos en Firestore
 * Propósito: Hacer que todas las plazas vuelvan a estar disponibles
 * 
 * Uso:
 * node functions/release-all-rentals.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-key.json');

// Inicializar Firebase
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://aparcamientos-zaragoza.firebaseio.com'
});

const db = admin.firestore();

async function releaseAllRentals() {
  try {
    console.log('🚀 Iniciando liberación de todos los alquileres...\n');

    // Buscar todos los documentos con estado 'activo'
    const snapshot = await db.collection('alquileres_por_horas')
      .where('estado', '==', 'EstadoAlquilerPorHoras.activo')
      .get();

    console.log(`📍 Encontrados ${snapshot.size} alquileres activos\n`);

    if (snapshot.empty) {
      console.log('✅ No hay alquileres activos. Todas las plazas ya están disponibles.');
      process.exit(0);
    }

    let successCount = 0;
    let errorCount = 0;
    const batch = db.batch();

    // Iterar sobre cada documento
    snapshot.docs.forEach((doc) => {
      const data = doc.data();
      console.log(`📋 Procesando alquiler: ${doc.id}`);
      console.log(`   Plaza: ${data.idPlaza}, Arrendatario: ${data.idArrendatario}`);
      console.log(`   Estado anterior: ${data.estado}`);

      // Actualizar el estado a 'liberado'
      batch.update(doc.ref, {
        estado: 'EstadoAlquilerPorHoras.liberado',
        fechaLiberacion: admin.firestore.Timestamp.now(),
        tiempoUsado: data.duracionContratada || 0,
        precioCalculado: (data.duracionContratada || 0) * (data.precioMinuto || 0)
      });

      successCount++;
    });

    // Ejecutar el batch
    await batch.commit();
    console.log(`\n✅ Se liberaron exitosamente ${successCount} alquileres`);
    console.log('📍 Todas las plazas ahora están disponibles para nuevos alquileres\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error al liberar alquileres:', error);
    process.exit(1);
  }
}

// Ejecutar
releaseAllRentals();
