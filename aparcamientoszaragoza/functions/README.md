# Cloud Functions para Aparcamientos Zaragoza

## Instalación

1. **Instalar dependencias:**
   ```bash
   cd functions
   npm install
   ```

2. **Configurar credenciales de Gmail:**
   
   Para enviar emails, necesitas configurar las credenciales de Gmail:
   
   ```bash
   firebase functions:config:set gmail.email="tu-email@gmail.com" gmail.password="tu-app-password"
   ```
   
   **Importante:** Usa una "App Password" de Gmail, no tu contraseña normal.
   Para crear una App Password:
   - Ve a https://myaccount.google.com/apppasswords
   - Selecciona "Correo" y "Otro (nombre personalizado)"
   - Copia la contraseña generada

3. **Desplegar las funciones:**
   ```bash
   firebase deploy --only functions
   ```

## Funciones disponibles

### `sendSupportEmail` (HTTPS Callable)

Envía emails de soporte desde la app Flutter.

**Parámetros:**
```json
{
  "to": ["email1@example.com", "email2@example.com"],
  "replyTo": "usuario@example.com",
  "subject": "Asunto del email",
  "text": "Contenido en texto plano",
  "html": "<p>Contenido en HTML</p>",
  "userId": "uid-del-usuario",
  "userEmail": "email-del-usuario"
}
```

**Respuesta exitosa:**
```json
{
  "success": true,
  "messageId": "xxx",
  "message": "Email enviado correctamente"
}
```

### `sendMailOnCreate` (Firestore Trigger)

Se activa automáticamente cuando se crea un documento en la colección `mail`.

**Formato del documento:**
```json
{
  "to": ["email@example.com"],
  "replyTo": "usuario@example.com",
  "message": {
    "subject": "Asunto",
    "text": "Texto plano",
    "html": "<p>HTML</p>"
  }
}
```

## Pruebas locales

```bash
npm run serve
```

## Logs

```bash
firebase functions:log
```
