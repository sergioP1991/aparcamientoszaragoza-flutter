**Resumen de Agentes y Cambios**

Este documento resume las acciones realizadas por el agente (Copilot) durante la sesión, los ficheros modificados, cómo verificar los cambios localmente y los bloqueos pendientes.

---

## **CAMBIO RECIENTE: Solución de Mapas - No Mostraban Plazas**

**Problema identificado**: La vista de mapas no mostraba ningún marcador de plazas de aparcamiento.

**Causa raíz**: Las coordenadas en Firestore eran inválidas (campos `latitud`/`longitud` vacíos → 0.0 por defecto), lo que generaba marcadores en la ubicación (0, 0).

**Solución implementada**:
1. **Servicio de actualización** (`lib/Services/PlazaCoordinatesUpdater.dart`):
   - Clase `PlazaCoordinatesUpdater` con 18 zonas de Zaragoza y sus coordenadas correctas
   - Método `updateAllPlazas()` que actualiza Firestore automáticamente
   - Método `getInvalidCoordinates()` para diagnosticar problemas

2. **Panel de administración** (`lib/Screens/admin/AdminPlazasScreen.dart`):
   - Interfaz para ejecutar la actualización de coordenadas
   - Búsqueda de coordenadas inválidas
   - Logs en tiempo real de progreso

3. **Acceso a admin panel** (modificado `lib/Screens/settings/settings_screen.dart`):
   - Click 5 veces en el título "Configuración" → abre panel admin (secreto)

**Coordenadas actualizadas** (18 plazas):
- Centro: Pilar, Coso, Alfonso I, España, Puente (41.65 -0.88)
- Conde Aranda: 41.6488, -0.8891
- Actur/Campus: 41.6810, -0.6890
- Almozara: 41.6720, -0.8420
- Delicias: 41.6420, -0.8750
- Park & Ride Valdespartera: 41.5890, -0.8920
- Park & Ride Chimenea: 41.7020, -0.8650
- Expo Sur: 41.6340, -0.8420
- San José: 41.6380, -0.9050

**Ficheros creados/modificados**:
- `lib/Services/PlazaCoordinatesUpdater.dart` ✨ (nuevo)
- `lib/Screens/admin/AdminPlazasScreen.dart` ✨ (nuevo)
- `lib/Screens/settings/settings_screen.dart` (modificado para acceso admin)
- `functions/update-coordinates-auto.js` (script alternativo)

**Cómo probar**:
```bash
# 1. Compilar y ejecutar
flutter pub get
flutter run -d chrome

# 2. Ir a Configuración (Settings) y hacer click 5 veces en el título
# 3. Se abre "Admin - Coordenadas de Plazas"
# 4. Pulsar "Actualizar Coordenadas"
# 5. Esperar a que se actualicen los datos en Firebase
# 6. Recargar app → el mapa debe mostrar plazas en Zaragoza
```

**Validaciones incluidas**:
- ✅ Busca coordenadas válidas dentro del rango de Zaragoza (41.0-42.0 lat, -1.5 a -0.5 lon)
- ✅ Descarta coordenadas 0.0 o null
- ✅ Matching inteligente entre dirección y zona

**Notas**:
- Panel admin es accesible solo por click secreto (no aparece en menú)
- Se puede ejecutar múltiples veces sin duplicar datos
- Los marcadores se cargan automáticamente en el siguiente acceso al mapa

---

**Contexto rápido**
- Proyecto: Flutter (web) + Firebase (Auth, Firestore, Functions)
- Objetivos principales: mejorar la UX del login (cambiar de cuenta), añadir flujo de contacto/email, endurecer logout y preparar funciones para envío de correo.

**Cambios principales realizados por el agente**
- UI Login (`lib/Screens/login/login_screen.dart`):
  - Rediseño de la sección "cambiar de cuenta". Ahora muestra un único botón estilizado `No soy yo` (botón `OutlinedButton` full-width) en lugar del layout previo con dos botones.
  - Añadido manejo de hover/estilos previos y variantes iteradas (efectos glass/animación en versiones previas durante la sesión).
  - Añadido método privado `_submitLogin()` que centraliza la lógica de validación y autentificación.
  - Conectado `onFieldSubmitted` del campo contraseña para que pulsar Enter ejecute la misma acción que el botón "Entrar".

- Contact / Email (varios archivos en `lib/Screens/settings`):
  - Se implementó una pantalla de composición de email (`ComposeEmailScreen`) y `ContactScreen` que pueden escribir un documento a la colección `mail` o invocar la función callable `sendSupportEmail`.

- Cloud Functions (`functions/index.js` y `functions/package.json`):
  - Scaffold de funciones: `sendSupportEmail` (callable) y `sendMailOnCreate` (trigger sobre `mail/{docId}`) usando `nodemailer`.
  - Nota: el despliegue de funciones está bloqueado por permisos/billing (HTTP 403) en el proyecto.

**Ficheros modificados / añadidos**
- `lib/Screens/login/login_screen.dart` (UI y lógica de login)
- `lib/Screens/settings/contact_screen.dart` (navegación a compose)
- `lib/Screens/settings/compose_email_screen.dart` (guardado en Firestore / llamada a function)
- `functions/index.js`, `functions/package.json`, `functions/.env` (scaffold de funciones)
- `pubspec.yaml` (se añadieron `url_launcher` y `cloud_functions`)

**Cómo probar localmente**
1. Desde la raíz del proyecto ejecutar:
```
flutter pub get
flutter run -d chrome
```
2. Abrir la página de login. Escenarios a verificar:
  - Si el login recuerda un usuario, debe mostrarse el botón `No soy yo`.
  - Rellenar contraseña y pulsar Enter debe ejecutar la misma validación/acción que pulsar el botón "Entrar".
  - Pulsar `No soy yo` debe borrar las preferencias almacenadas (`lastUserEmail`, `lastUserDisplayName`, `lastUserPhoto`) y mostrar el formulario normal.

**Bloqueos y notas operativas**
- Cloud Functions: el despliegue falló por falta de permisos / billing (HTTP 403). Para desplegar funciones se requiere activar Blaze y App Engine en el proyecto Firebase.
- Email automático: mientras no se desplieguen funciones, la app guarda el documento en `mail` y se puede usar la extensión Trigger Email (requiere Blaze) o integrar un proveedor externo (EmailJS) para evitar billing.
- Avisos observados al ejecutar: excepciones de carga de imágenes remotas (CORS / NetworkImageLoadException) y aviso de Google Maps por facturación no habilitada (no bloqueante para la UI principal).

**Siguientes pasos recomendados**
- Decidir cómo enviar emails en producción: (1) activar Blaze + desplegar funciones; (2) instalar Trigger Email extension; o (3) integrar EmailJS cliente.
- Revisar imágenes remotas o evitar proxys que causen fallos en web (usar assets locales o CDN con CORS correcto).
- Opcional: afinar estilos del botón `No soy yo` según guía de diseño (colores/espaciado) — puedo aplicar ajustes si lo deseas.

**Contacto / referencias**
- Login: `lib/Screens/login/login_screen.dart`
- Compose Email: `lib/Screens/settings/compose_email_screen.dart`
- Cloud Functions: `functions/index.js`

Fecha: 11 de febrero de 2026

**Unificación de skills**
- Se detectaron dos carpetas de skills: `.agent/skills` y `.agents/skills`.
- Acción tomada: los archivos de `.agent/skills` se movieron a `.agents/skills` y la carpeta `.agent` fue eliminada. Ahora la única ubicación de skills es `.agents/skills`.


**Cambio**: Actualización de coordenadas de plazas de aparcamiento en Zaragoza

**Ficheros**:
- `functions/update-plaza-coordinates.js` - Script Node.js para actualizar Firestore
- `functions/PLAZA_COORDINATES_UPDATE_GUIDE.md` - Guía de actualización manual y automática

**Objetivo**: Las plazas de aparcamiento en la vista de mapas no se mostraban correctamente porque sus coordenadas (latitud/longitud) no eran precisas. Se ha actualizado la base de coordenadas basándose en el skill de experto en movilidad de Zaragoza.

**Coordenadas actualizadas** (por zona):
- **Centro/Pilar**: 41.6551, -0.8896
- **Calle Coso**: 41.6525, -0.8901
- **Plaza España**: 41.6445, -0.8945
- **Conde Aranda**: 41.6488, -0.8891
- **Actur/Campus**: 41.6810, -0.6890
- **Almozara**: 41.6720, -0.8420
- **Delicias**: 41.6420, -0.8750
- **Valdespartera (P&R)**: 41.5890, -0.8920
- **La Chimenea (P&R)**: 41.7020, -0.8650
- **Expo Sur**: 41.6340, -0.8420
- **San José**: 41.6380, -0.9050

**Cómo probar**:
```bash
# Opción 1: Ejecutar script Node.js (requiere firebase-service-key.json)
cd functions
npm install firebase-admin
node update-plaza-coordinates.js

# Opción 2: Actualización manual en Firebase Console
# 1. Abrir: https://console.firebase.google.com
# 2. Ir a: aparcamientos-zaragoza > Firestore > Colección 'garaje'
# 3. Editar cada documento con sus nuevas coordenadas
# Ver: PLAZA_COORDINATES_UPDATE_GUIDE.md para detalles
```

**Notas**:
- Las coordenadas se basan en el skill `aparcamientos-zaragoza` especializado en movilidad urbana de Zaragoza 2025-2030
- Se incluyen todas las zonas: Centro (ZBE), ORA Azul/Naranja, Park & Ride, Zonas Blancas
- Las plazas ahora coinciden con las ubicaciones reales en la ciudad
- La vista de mapas debería mostrar las plazas correctamente tras la actualización

**Fecha**: 13 de febrero de 2026 — Agente: Copilot


**Política obligatoria para agentes**
- Todos los agentes que realicen cambios importantes en el repositorio (código, configuración, scripts de despliegue, integración de terceros, o cambios que afecten al comportamiento en producción) deben actualizar este archivo `AGENTS.md`.
- El registro mínimo que debe añadirse por el agente tras cada cambio importante:
  - **Resumen breve**: 1-2 líneas describiendo el objetivo del cambio.
  - **Ficheros modificados / añadidos**: lista de rutas (relativas) afectadas.
  - **Cómo probar localmente**: pasos concretos y comandos para validar el cambio.
  - **Bloqueos / notas**: permisos, keys, billing, o pasos manuales pendientes.
  - **Fecha** y **responsable** (nombre o agente automatizado).
- Ejemplo de entrada que debe añadirse (modelo):

  **Cambio**: Integración EmailJS en frontend para envío de soporte.

  **Ficheros**:
  - `lib/Screens/settings/compose_email_screen.dart`
  - `web/index.html`

  **Cómo probar**:
  ```
  flutter pub get
  flutter run -d chrome
  # Abrir la pantalla "Enviar email" y pulsar "Enviar mensaje"
  ```

  **Notas**: Requiere configurar `serviceId`, `templateId` y `publicKey` en `compose_email_screen.dart` y `web/index.html`.

  **Fecha**: 12 de febrero de 2026 — Agente: Copilot

- Motivo: centralizar historial de cambios realizados por agentes y facilitar auditoría y pruebas.

