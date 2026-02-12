/**
 * Cloud Functions para Aparcamientos Zaragoza
 * 
 * Función: sendSupportEmail
 * Envía emails de soporte a los administradores
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const { defineString } = require("firebase-functions/params");

admin.initializeApp();

// Configuración usando variables de entorno (archivo .env)
const gmailEmail = defineString("GMAIL_EMAIL");
const gmailPassword = defineString("GMAIL_PASSWORD");

// Transporter para enviar emails (se crea en runtime)
let transporter = null;

function getTransporter() {
  if (!transporter) {
    transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: gmailEmail.value(),
        pass: gmailPassword.value(),
      },
    });
  }
  return transporter;
}

/**
 * Cloud Function: sendSupportEmail
 * 
 * Envía un email de soporte a los administradores de la aplicación.
 * 
 * Parámetros esperados:
 * - to: Array de emails destinatarios
 * - replyTo: Email del usuario para responder
 * - subject: Asunto del email
 * - text: Contenido en texto plano
 * - html: Contenido en HTML
 * - userId: ID del usuario que envía
 * - userEmail: Email del usuario que envía
 */
exports.sendSupportEmail = functions.https.onCall(async (data, context) => {
  // Validar que el usuario esté autenticado (opcional pero recomendado)
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Debes iniciar sesión para enviar un mensaje de soporte."
    );
  }

  // Extraer parámetros
  const {
    to,
    replyTo,
    subject,
    text,
    html,
    userId,
    userEmail,
  } = data;

  // Validar parámetros requeridos
  if (!to || !Array.isArray(to) || to.length === 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Se requiere al menos un destinatario."
    );
  }

  if (!subject || subject.trim() === "") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "El asunto es requerido."
    );
  }

  if (!text && !html) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "El mensaje es requerido."
    );
  }

  try {
    // Configurar el email
    const mailOptions = {
      from: `"Aparcamientos Zaragoza" <${gmailEmail.value()}>`,
      to: to.join(", "),
      replyTo: replyTo || userEmail,
      subject: subject,
      text: text,
      html: html,
    };

    // Enviar el email
    const info = await getTransporter().sendMail(mailOptions);

    console.log("Email enviado:", info.messageId);

    // Guardar registro en Firestore (opcional)
    await admin.firestore().collection("support_emails").add({
      to: to,
      replyTo: replyTo,
      subject: subject,
      userId: userId,
      userEmail: userEmail,
      messageId: info.messageId,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "sent",
    });

    return {
      success: true,
      messageId: info.messageId,
      message: "Email enviado correctamente",
    };
  } catch (error) {
    console.error("Error al enviar email:", error);

    // Guardar registro de error
    await admin.firestore().collection("support_emails").add({
      to: to,
      replyTo: replyTo,
      subject: subject,
      userId: userId,
      userEmail: userEmail,
      error: error.message,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "failed",
    });

    throw new functions.https.HttpsError(
      "internal",
      "Error al enviar el email. Por favor, inténtalo de nuevo."
    );
  }
});

/**
 * Función alternativa que escucha cambios en Firestore
 * Se activa cuando se crea un documento en la colección 'mail'
 */
exports.sendMailOnCreate = functions.firestore
  .document("mail/{docId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    if (!data.to || !data.message) {
      console.error("Documento inválido:", context.params.docId);
      return snap.ref.update({ status: "error", error: "Datos inválidos" });
    }

    try {
      const mailOptions = {
        from: `"Aparcamientos Zaragoza" <${gmailEmail.value()}>`,
        to: Array.isArray(data.to) ? data.to.join(", ") : data.to,
        replyTo: data.replyTo,
        subject: data.message.subject,
        text: data.message.text,
        html: data.message.html,
      };

      const info = await getTransporter().sendMail(mailOptions);

      console.log("Email enviado via trigger:", info.messageId);

      return snap.ref.update({
        status: "sent",
        messageId: info.messageId,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      console.error("Error al enviar email via trigger:", error);

      return snap.ref.update({
        status: "error",
        error: error.message,
      });
    }
  });
