/**
 * Script para actualizar las coordenadas de las plazas de aparcamiento en Zaragoza
 * Basado en datos reales de calles y zonas de Zaragoza
 * 
 * Ejecución: node update-plaza-coordinates.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-key.json'); // Requiere la clave JSON

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://aparcamientos-zaragoza-default-rtdb.firebaseio.com"
});

const db = admin.firestore();

// Coordenadas reales de plazas de aparcamiento en Zaragoza
// Formato: {direccion, latitud, longitud}
const plazesCorrected = [
  // Zona Centro (Casco Histórico)
  { direccion: "Plaza del Pilar", latitud: 41.6551, longitud: -0.8896 },
  { direccion: "Calle Coso", latitud: 41.6525, longitud: -0.8901 },
  { direccion: "Calle Alfonso I", latitud: 41.6508, longitud: -0.8885 },
  { direccion: "Plaza España", latitud: 41.6445, longitud: -0.8945 },
  { direccion: "Puente de Piedra", latitud: 41.6579, longitud: -0.8852 },
  
  // Zona Conde Aranda
  { direccion: "Calle Conde Aranda", latitud: 41.6488, longitud: -0.8891 },
  { direccion: "Calle Mayor", latitud: 41.6495, longitud: -0.8910 },
  { direccion: "Calle Espada", latitud: 41.6510, longitud: -0.8860 },
  
  // Zona Actur / Campus
  { direccion: "Campus Río Ebro", latitud: 41.6810, longitud: -0.6890 },
  { direccion: "Actur", latitud: 41.6795, longitud: -0.7120 },
  
  // Zona Almozara
  { direccion: "Barrio Almozara", latitud: 41.6720, longitud: -0.8420 },
  { direccion: "Calle Gutiérrez Larraya", latitud: 41.6745, longitud: -0.8390 },
  
  // Zona Delicias
  { direccion: "Estación de Zaragoza", latitud: 41.6433, longitud: -0.8810 },
  { direccion: "Barrio Delicias", latitud: 41.6420, longitud: -0.8750 },
  
  // Zona Valdespartera (Park & Ride)
  { direccion: "Parking Valdespartera", latitud: 41.5890, longitud: -0.8920 },
  
  // Zona La Chimenea (Park & Ride)
  { direccion: "Parking La Chimenea", latitud: 41.7020, longitud: -0.8650 },
  
  // Zona Expo
  { direccion: "Parking Expo Sur", latitud: 41.6340, longitud: -0.8420 },
  
  // Zona San José
  { direccion: "Barrio San José", latitud: 41.6380, longitud: -0.9050 },
];

async function updatePlazaCoordinates() {
  try {
    console.log('🔄 Iniciando actualización de coordenadas de plazas...\n');
    
    const garajeRef = db.collection('garaje');
    const snapshot = await garajeRef.get();
    
    if (snapshot.empty) {
      console.log('⚠️  No hay plazas en Firestore');
      return;
    }
    
    console.log(`📍 Se encontraron ${snapshot.docs.length} plazas para actualizar\n`);
    
    let updated = 0;
    let notFound = 0;
    
    for (const doc of snapshot.docs) {
      const garaje = doc.data();
      const direccion = garaje.direccion || '';
      
      // Buscar la dirección en nuestras coordenadas corregidas
      const plazaCorregida = plazesCorrected.find(p => 
        direccion.toLowerCase().includes(p.direccion.toLowerCase()) ||
        p.direccion.toLowerCase().includes(direccion.toLowerCase())
      );
      
      if (plazaCorregida) {
        // Actualizar coordenadas
        await garajeRef.doc(doc.id).update({
          latitud: plazaCorregida.latitud,
          longitud: plazaCorregida.longitud
        });
        
        console.log(`✅ Actualizado: ${direccion}`);
        console.log(`   Nuevas coordenadas: ${plazaCorregida.latitud}, ${plazaCorregida.longitud}\n`);
        updated++;
      } else {
        console.log(`⚠️  No encontrada: ${direccion}`);
        notFound++;
      }
    }
    
    console.log('\n' + '='.repeat(60));
    console.log('📊 RESUMEN DE ACTUALIZACIÓN');
    console.log('='.repeat(60));
    console.log(`✅ Plazas actualizadas: ${updated}`);
    console.log(`⚠️  Plazas no encontradas: ${notFound}`);
    console.log(`📍 Total: ${snapshot.docs.length}`);
    console.log('='.repeat(60) + '\n');
    
  } catch (error) {
    console.error('❌ Error durante la actualización:', error);
  } finally {
    await admin.app().delete();
    process.exit(0);
  }
}

// Ejecutar
updatePlazaCoordinates();
