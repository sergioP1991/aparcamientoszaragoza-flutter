#!/bin/bash
# Script para actualizar coordenadas de plazas mediante Firebase CLI
# Uso: ./update-coordinates.sh

echo "🔄 Actualizando coordenadas de plazas de aparcamiento en Zaragoza..."
echo ""

# Array de plazas con sus coordenadas corregidas
declare -A plazas=(
  ["Plaza del Pilar"]="41.6551,-0.8896"
  ["Calle Coso"]="41.6525,-0.8901"
  ["Calle Alfonso I"]="41.6508,-0.8885"
  ["Plaza España"]="41.6445,-0.8945"
  ["Puente de Piedra"]="41.6579,-0.8852"
  ["Calle Conde Aranda"]="41.6488,-0.8891"
  ["Calle Mayor"]="41.6495,-0.8910"
  ["Calle Espada"]="41.6510,-0.8860"
  ["Campus Río Ebro"]="41.6810,-0.6890"
  ["Actur"]="41.6795,-0.7120"
  ["Barrio Almozara"]="41.6720,-0.8420"
  ["Calle Gutiérrez Larraya"]="41.6745,-0.8390"
  ["Estación de Zaragoza"]="41.6433,-0.8810"
  ["Barrio Delicias"]="41.6420,-0.8750"
  ["Parking Valdespartera"]="41.5890,-0.8920"
  ["Parking La Chimenea"]="41.7020,-0.8650"
  ["Parking Expo Sur"]="41.6340,-0.8420"
  ["Barrio San José"]="41.6380,-0.9050"
)

echo "📊 Plazas a actualizar: ${#plazas[@]}"
echo ""

# Mostrar instrucciones
echo "⚠️  IMPORTANTE: Para actualizar correctamente, debes:"
echo "1. Acceder a la consola de Firebase: https://console.firebase.google.com"
echo "2. Ir a tu proyecto 'aparcamientos-zaragoza'"
echo "3. Abrir Firestore Database"
echo "4. Ir a la colección 'garaje'"
echo ""

# Mostrar coordenadas
echo "📍 COORDENADAS A ACTUALIZAR:"
echo "==========================================="
for plaza in "${!plazas[@]}"; do
  coords="${plazas[$plaza]}"
  lat=$(echo $coords | cut -d',' -f1)
  lon=$(echo $coords | cut -d',' -f2)
  echo "Plaza: $plaza"
  echo "  Latitud:  $lat"
  echo "  Longitud: $lon"
  echo ""
done

echo "==========================================="
echo ""
echo "✅ Para actualizar, copia estas coordenadas en Firestore"
echo "   o usa Firebase Admin SDK con las coordenadas anteriores"
