#!/bin/bash

# Script para liberar todos los alquileres usando Firebase CLI
# Propósito: Hacer que todas las plazas vuelvan a estar disponibles
# 
# Prerequisitos:
# - Firebase CLI instalado: npm install -g firebase-tools
# - Estar autenticado: firebase login
# 
# Uso:
# chmod +x functions/release-all-rentals.sh
# ./functions/release-all-rentals.sh

set -e

PROJECT_ID="aparcamientos-zaragoza"
COLLECTION="alquileres_por_horas"

echo "🚀 Liberando todos los alquileres activos..."
echo "   Proyecto: $PROJECT_ID"
echo "   Colección: $COLLECTION"
echo ""

# Nota: Firestore no tiene una forma nativa de hacer batch updates desde CLI
# Se recomienda usar la Cloud Function en su lugar:
# firebase functions:call releaseAllRentals --project=$PROJECT_ID

if command -v firebase &> /dev/null; then
  echo "✅ Firebase CLI encontrado"
  echo ""
  echo "Para liberar todos los alquileres, ejecute:"
  echo ""
  echo "  firebase functions:call releaseAllRentals --project=$PROJECT_ID"
  echo ""
  echo "O acceda a Firebase Console manualmente:"
  echo "  https://console.firebase.google.com/project/$PROJECT_ID/functions"
  echo ""
else
  echo "❌ Firebase CLI no instalado."
  echo "Instálalo con: npm install -g firebase-tools"
  exit 1
fi
