# 🚀 Solución de CORS para Firebase Storage

## Problema Identificado
Las imágenes de Firebase Storage fallaban con error HTTP 412 (Precondition Failed) en web por restricciones CORS.

## Solución Implementada
Se creó una **Cloud Function proxy** (`serveImage`) que:
- Descarga imágenes desde Firebase Storage
- Sirve con headers CORS correctos
- Funciona en web sin problemas CORS

## Componentes Agregados

### 1. Cloud Function: `functions/serveImage.js`
```javascript
exports.serveImage = functions.https.onRequest(async (req, res) => {
  // Recibe: ?plazaId=1234&index=0
  // Retorna imagen con headers CORS
})
```

### 2. Servicio: `lib/Services/ImageProxyService.dart`
```dart
ImageProxyService.getProxyUrl(originalUrl)
// En web: convierte a URL proxy
// En mobile: retorna URL original de Firebase Storage
```

### 3. Widgets Actualizados
- `PlazaImageLoader` - usa proxy en web
- `NetworkImageLoader` - usa proxy en web

## 🔧 Instalación

### Step 1: Desplegar Cloud Function

```bash
cd functions
firebase deploy --only functions:serveImage
```

Anota la URL que retorna, por ejemplo:
```
Function URL (serveImage):
https://us-central1-aparcamientodisponible.cloudfunctions.net/serveImage
```

### Step 2: Actualizar ImageProxyService
En `lib/Services/ImageProxyService.dart`, línea 7, reemplaza:
```dart
static const String _cloudFunctionUrl = 'https://us-central1-aparcamientodisponible.cloudfunctions.net/serveImage';
```

Por tu URL real de Cloud Functions (región-proyecto-cloudfunctions).

### Step 3: Recompilar
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## ✅ Verificación

### En Web (Chrome)
- Las imágenes deberían cargar sin errores CORS
- Console debería mostrar:
  ```
  🖼️ Carousel - imageUrls.length: X
  🖼️ Carousel - Usando URLs de FIREBASE
  ```

### En Mobile (Android/iOS)
- Las imágenes cargan directamente desde Firebase Storage
- Sin cambios en comportamiento

## 📊 Flujo de Carga

```
Web:
  URL Firebase Storage
  ↓
  ImageProxyService.getProxyUrl()
  ↓
  Cloud Function proxy
  ↓
  Imagen con headers CORS ✅

Mobile:
  URL Firebase Storage
  ↓
  ImageProxyService.getProxyUrl()
  ↓
  URL original (sin cambios)
  ↓
  Imagen desde Firebase Storage ✅
```

## 🔍 Troubleshooting

### Error: "Function not found"
- Verifica que `firebase deploy --only functions:serveImage` completó OK
- Espera 1-2 minutos a que la función se propague
- Verifica la URL exacta en Firebase Console → Functions

### Error: "Image not found (404)"
- Verifica que el plazaId e índice son correctos
- Confirma que los archivos existen en Firebase Storage

### Error: "Permission denied"
- Verifica Firebase Storage Security Rules permiten lectura pública:
  ```
  allow read: if true;  // Temporal para testing
  allow write: if request.auth != null;
  ```

## 🔐 Seguridad (Producción)

Para mayor seguridad, añade autenticación a la Cloud Function:

```javascript
if (!req.headers.authorization) {
  return res.status(401).json({ error: 'Unauthorized' });
}
// Validar token...
```

Y en `ImageProxyService`, incluye el token:
```dart
headers: {
  'Authorization': 'Bearer $accessToken'
}
```

## 📝 Notas

- La solución usa `getProxyUrl()` que detecta automáticamente web vs mobile
- En web, convierte URLs de Firebase Storage a URLs proxy
- En mobile, mantiene URLs diretas (sin problemas CORS)
- Los tokens firmados en URLs se respetan en la Cloud Function
