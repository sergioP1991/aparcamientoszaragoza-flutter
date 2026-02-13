/**
 * Script automático para actualizar coordenadas de plazas en Zaragoza
 * Usa credenciales del SDK de Firebase (no requiere clave de servicio manual)
 * 
 * Ejecución: npx firebase-admin-config update-coordinates-auto.js
 * o usa: firebase emulators:exec "node update-coordinates-auto.js"
 */

const admin = require('firebase-admin');

// Inicializar Firebase Admin SDK con autenticación del emulador o proyecto actual
// Si no hay configuración, use: firebase deploy --only functions:updatePlazaCoordinates
let db;

try {
  // Intenta usar la configuración de firebase-tools
  const functions = require('firebase-functions');
  db = admin.firestore();
} catch (e) {
  // Fallback: inicializar manualmente
  admin.initializeApp();
  db = admin.firestore();
}

// Coordenadas corregidas de plazas de Zaragoza
const plazesCorrected = [
  // Zona Centro
  { direccion: "Plaza del Pilar", latitud: 41.6551, longitud: -0.8896 },
  { direccion: "Calle Coso", latitud: 41.6525, longitud: -0.8901 },
  { direccion: "Calle Alfonso", latitud: 41.6508, longitud: -0.8885 },
  { direccion: "Plaza España", latitud: 41.6445, longitud: -0.8945 },
  { direccion: "Puente de Piedra", latitud: 41.6579, longitud: -0.8852 },
  
  // Zona Conde Aranda
  { direccion: "Conde Aranda", latitud: 41.6488, longitud: -0.8891 },
  { direccion: "Calle Mayor", latitud: 41.6495, longitud: -0.8910 },
  { direccion: "Calle Espada", latitud: 41.6510, longitud: -0.8860 },
  
  // Zona Actur / Campus
  { direccion: "Campus", latitud: 41.6810, longitud: -0.6890 },
  { direccion: "Actur", latitud: 41.6795, longitud: -0.7120 },
  
  // Zona Almozara
  { direccion: "Almozara", latitud: 41.6720, longitud: -0.8420 },
  { direccion: "Gutiérrez", latitud: 41.6745, longitud: -0.8390 },
  
  // Zona Delicias
  { direccion: "Estación", latitud: 41.6433, longitud: -0.8810 },
  { direccion: "Delicias", latitud: 41.6420, longitud: -0.8750 },
  
  // Park & Ride
  { direccion: "Valdespartera", latitud: 41.5890, longitud: -0.8920 },
  { direccion: "Chimenea", latitud: 41.7020, longitud: -0.8650 },
  
  // Expo
  { direccion: "Expo", latitud: 41.6340, longitud: -0.8420 },
  
  // San José
  { direccion: "San José", latitud: 41.6380, longitud: -0.9050 },
];

async function updatePlazaCoordinates() {
  try {
    console.log('🔄 Iniciando actualización de coordenadas...\n');
    
    const garajeRef = db.collection('garaje');
    const snapshot = await garajeRef.get();
    
    if (snapshot.empty) {
      console.log('⚠️  No hay plazas en Firestore');
      process.exit(1);
    }
    
    console.log(`📍 Se encontraron ${snapshot.docs.length} plazas\n`);
    
    let updated = 0;
    let notFound = 0;
    
    for (const doc of snapshot.docs) {
      const garaje = doc.data();
      const direccion = garaje.direccion || '';
      
      const plazaCorregida = plazesCorrected.find(p => 
        direccion.toLowerCase().includes(p.direccion.toLowerCase()) ||
        p.direccion.toLowerCase().includes(direccion.toLowerCase())
      );
      
      if (plazaCorregida) {
        await garajeRef.doc(doc.id).update({
          latitud: plazaCorregida.latitud,
          longitud: plazaCorregida.longitud
        });
        
        console.log(`✅ ${direccion}`);
        console.log(`   → ${plazaCorregida.latitud}, ${plazaCorregida.longitud}\n`);
        updated++;
      } else {
        console.log(`⚠️  No coincide: ${direccion}`);
        notFound++;
      }
    }
    
    console.log('\n' + '='.repeat(60));
    console.log(`✅ Actualizado: ${updated}`);
    console.log(`⚠️  No encontradas: ${notFound}`);
    console.log('='.repeat(60));
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

updatePlazaCoordinates();
