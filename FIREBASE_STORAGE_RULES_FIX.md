# 🔐 Firebase Storage Security Rules - Fix para Imágenes No Visibles

## ❌ Problema Actual

```
❌ FirebaseStorageImage: Sin datos o datos nulos. Error: null
❌ [FirebaseImageService] ERROR CRÍTICO descargando...
   🔐 Probable causa: SECURITY RULES está bloqueando acceso
```

Las imágenes se **suben exitosamente** a Firebase Storage (`garajes/1773223843125/imagen_2.jpg`), pero **no se descargan** porque las Security Rules no permiten lectura.

---

## ✅ Solución: Actualizar Security Rules

### **Paso 1: Abrir Firebase Console**
- Ir a: https://console.firebase.google.com
- Proyecto: `aparcamientodisponible`
- Sección: **Storage** → **Rules**

### **Paso 2: Reemplazar las Reglas**

**Opción A: Permitir lectura pública (RECOMENDADO para MVP)**
```firestore
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Permitir lectura pública de imágenes en /garajes
    match /garajes/{allPaths=**} {
      allow read;  // ← Cualquiera puede leer
      allow write: if request.auth != null;  // Solo usuarios autenticados pueden escribir
    }
    
    // Resto de archivos privados
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Opción B: Solo usuarios autenticados (MÁS SEGURO)**
```firestore
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /garajes/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Opción C: Usuario solo puede leer/escribir sus propias imágenes**
```firestore
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /garajes/{plazaId}/{allPaths=**} {
      // Leer: propietario o si es pública
      allow read: if request.auth != null || isPublic();
      
      // Escribir: solo propietario
      allow write: if owned();
    }
  }
}

function owned() {
  return request.auth.uid == get(/databases/$(database)/documents/garaje/$(resource.name)).data.propietarioId;
}

function isPublic() {
  return true;  // Por ahora todas son públicas
}
```

### **Paso 3: Publicar las Reglas**
1. Click en **Publish**
2. Aceptar el cambio
3. Esperar 1-2 minutos a que se actualicen

---

## 🧪 Verificar que Funciona

### **Desde Console del Navegador:**
```javascript
// DevTools → Console → Ejecutar
flutter run -d chrome
```

Deberías ver los logs:
```
===============================================
✅ [FirebaseStorageImage] Widget iniciado
   plazaId: 1773223843125
   index: 0
===============================================
🖼️ [FirebaseImageService] Intentando descargar: garajes/1773223843125/imagen_0.jpg
📊 [FirebaseImageService] Metadata: Size=8481, ContentType=image/jpeg
⏳ [FirebaseImageService] Iniciando descarga de bytes...
✅ [FirebaseImageService] Imagen descargada exitosamente: garajes/1773223843125/imagen_0.jpg (8481 bytes)
✅ FirebaseStorageImage: Imagen descargada (8481 bytes). Mostrando...
🎬 Iniciando animación de fade-in
```

### **En el Carrusel:**
- Navega a detalle de plaza
- Las imágenes deberían aparecer ahora en el carrusel
- Desliza para ver diferentes imágenes
- Cada una debería cargar con fade-in suave

---

## 🔍 Si Aún No Funciona

Revisa los logs en consola. Si ves:

### **❌ Error: "Permission denied"**
```
🔐 Probable causa: SECURITY RULES de Firebase Storage está bloqueando acceso
```
→ Las reglas no están copiadas correctamente. Verifica que pusiste la regla `allow read;` para `/garajes`

### **❌ Error: "Storage bucket not found"**
```
❌ ref.getData() retornó NULL
```
→ El bucket de Storage no está habilitado. Ve a **Storage** en Firebase Console y habilítalo.

### **❌ Error: "not found" o "404"**
```
🔍 Probable causa: Archivo NO EXISTE en Storage o ruta incorrecta
```
→ Verifica que:
1. La plaza ID es correcta (`1773223843125`)
2. Las imágenes existen: Abre **Storage** y busca `/garajes/1773223843125/`
3. El nombre es exacto: `imagen_0.jpg`, `imagen_1.jpg`, etc.

### **❌ Error: "User authentication required"**
```
🔐 Probable causa: Usuario NO AUTENTICADO y reglas requieren auth
```
→ Si usas "Opción B" más segura, asegúrate que el usuario está logueado:
```dart
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // Usuario no está logueado, necesita login primero
}
```

---

## 📋 Checklist de Verificación

- [ ] Abriste Firebase Console → Storage
- [ ] Copiaste las reglas de seguridad (Opción A recomendada)
- [ ] Hiciste click en **Publish**
- [ ] Esperaste 1-2 minutos
- [ ] Ejecutaste `flutter run -d chrome`
- [ ] Navegaste a detalle de plaza con imágenes
- [ ] Las imágenes aparecen en el carrusel con fade-in

---

## 🆘 Soporte

Si sigues viendo `❌ Sin datos o datos nulos`, copia-pega estos logs:

```javascript
// En consola del navegador (F12):
firebase.storage().ref('garajes/1773223843125/imagen_0.jpg').getBytes(10*1024*1024)
  .then(bytes => console.log('✅ Descargó:', bytes.length, 'bytes'))
  .catch(err => console.error('❌ Error:', err.message, err.code));
```

Si ves `permission-denied`, definitivamente es tema de Security Rules.
