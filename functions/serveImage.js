const functions = require('firebase-functions');
const admin = require('firebase-admin');

const bucket = admin.storage().bucket();

/**
 * Cloud Function que actúa como proxy para servir imágenes de Firebase Storage
 * Evita problemas de CORS al servir desde el dominio de Firebase Hosting
 * 
 * Uso: https://region-projectid.cloudfunctions.net/serveImage?plazaId=1234&index=0
 */
exports.serveImage = functions.https.onRequest(async (req, res) => {
  try {
    const { plazaId, index = 0 } = req.query;

    if (!plazaId) {
      return res.status(400).json({ error: 'plazaId requerido' });
    }

    const fileName = `imagen_${index}.jpg`;
    const filePath = `garajes/${plazaId}/${fileName}`;
    const file = bucket.file(filePath);

    // Verificar que el archivo existe
    const [exists] = await file.exists();
    if (!exists) {
      return res.status(404).json({ error: 'Imagen no encontrada' });
    }

    // Descargar el archivo
    const [fileBuffer] = await file.download();

    // Configurar headers CORS
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.set('Cache-Control', 'public, max-age=3600');
    res.set('Content-Type', 'image/jpeg');

    res.send(fileBuffer);
  } catch (error) {
    console.error('Error sirviendo imagen:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * Manejo de requests OPTIONS para CORS preflight
 */
exports.serveImageCors = functions.https.onRequest((req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  res.sendStatus(200);
});
