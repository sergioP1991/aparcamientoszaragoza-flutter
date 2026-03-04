#!/bin/bash

# Script para remover secretos de Stripe del historial de git
# IMPORTANTE: Este script reescribe el historial de git
# Todos los colaboradores necesitarán hacer re-clone o git pull --rebase

set -e

echo "🔐 Removiendo secretos de Stripe del historial de git..."
echo ""
echo "⚠️  ADVERTENCIA: Este script reescribe el historial de git."
echo "Todos los colaboradores necesitarán hacer un nuevo clone del repositorio."
echo ""
read -p "¿Deseas continuar? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operación cancelada."
    exit 1
fi

# Paso 1: Instalar git-filter-repo si no está disponible
if ! command -v git filter-repo &> /dev/null; then
    echo "📦 Instalando git-filter-repo..."
    pip install git-filter-repo
fi

# Paso 2: Crear archivo de reemplazo de secretos
cat > /tmp/secrets-to-remove.txt << 'EOF'
sk_test_51SuUod2KaK54WVOoDRRDNKAb4BoDBWT6pycLg45iSQIMDIrR1kfWd3GP9K1pDdAubZqChuHIA24o7MsmukcTFC53009adHE2Hl==>[REDACTED]
EOF

# Paso 3: Ejecutar git filter-repo
echo "🔄 Reescribiendo historial de git..."
git filter-repo --replace-text /tmp/secrets-to-remove.txt

# Paso 4: Limpiar archivo temporal
rm /tmp/secrets-to-remove.txt

echo ""
echo "✅ Secretos removidos del historial de git."
echo ""
echo "🚀 Pasos siguientes:"
echo "1. Hacer push forzado: git push origin main --force-with-lease"
echo "2. Notificar a todos los colaboradores que hagan un nuevo clone"
echo "3. Verificar en GitHub que los secretos fueron removidos"
echo ""
echo "📝 Para verificar localmente:"
echo "   git log --all --oneline | head -20"
echo ""
