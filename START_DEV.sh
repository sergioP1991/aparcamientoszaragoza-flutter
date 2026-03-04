#!/bin/bash

set -e

echo "🚀 Iniciando servidor de desarrollo Flutter..."
echo "📁 Directorio: $(pwd)"
echo ""

# Limpiar compilación anterior
echo "🧹 Limpiando compilación anterior..."
flutter clean

# Obtener dependencias
echo "📦 Descargando dependencias..."
flutter pub get

# Ejecutar en Chrome
echo ""
echo "🌐 Iniciando Firefox en modo desarrollo..."
flutter run -d chrome

echo ""
echo "✅ Servidor listo en http://localhost:50251"
