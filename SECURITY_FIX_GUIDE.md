# Guía: Remover Secretos de Stripe y Resolver GitHub Push Protection

## 📋 Problema Identificado

GitHub Push Protection ha detectado una **Stripe Test API Secret Key** hardcodeada en el repositorio:

- **Ubicación**: `lib/Services/StripeService.dart` línea 71
- **Clave detectada**: `sk_test_51SuUod2KaK54WVOo...` (secreto)
- **Estado**: BLOQUEADO para push

## ⚠️ Por Qué Es Crítico

- Las claves secretas de Stripe **NUNCA** deben estar en el repositorio
- Si alguien obtiene esta clave, puede:
  - Cobrar a través de tu cuenta Stripe
  - Crear reembolsos fraudulentos
  - Acceder a información de pagos

## ✅ Cambios Ya Realizados

1. ✅ Removido secreto de `lib/Services/StripeService.dart`
   - Reemplazado con `REMOVE_ME_USE_ENVIRONMENT_VARIABLES`
   
2. ✅ Actualizado `.gitignore`
   - Agregadas entradas `.env`, `.env.local`, `.env.secrets`
   - Esto previene futuros accidentes

## 🔧 Solución: Pasos a Seguir

### Opción A: Reescribir Historial (RECOMENDADO)

El secreto también existe en commits anteriores. Para limpiarlo completamente:

#### Paso 1: Usar el script automático

```bash
chmod +x REMOVE_SECRETS.sh
./REMOVE_SECRETS.sh
```

El script hará:
- Instalar `git-filter-repo` (si es necesario)
- Remover el secreto de todos los commits del historial
- Mantener el resto del contenido intacto

#### Paso 2: Push forzado

Después de que el script termine:

```bash
git push origin main --force-with-lease
```

⚠️ `--force-with-lease` es más seguro que `--force`:
- Rechaza si hay cambios remotos en el servidor
- Previene sobrescribir trabajo de otros colaboradores

#### Paso 3: Notificar a colaboradores

Si otros desarrolladores clonan el repo:

```bash
# Ellos deben hacer:
git clone https://github.com/sergioP1991/aparcamientoszaragoza-flutter.git
```

No pueden usar `git pull` después del rewrite; necesitan un nuevo clone.

---

### Opción B: Manual con git filter-branch

Si prefieres más control:

```bash
# Instalar git-filter-repo
pip install git-filter-repo

# Crear archivo de secretos a remover
cat > /tmp/secrets.txt << EOF
sk_test_51SuUod2KaK54WVOoDRRDNKAb4BoDBWT6pycLg45iSQIMDIrR1kfWd3GP9K1pDdAubZqChuHIA24o7MsmukcTFC53009adHE2Hl==>[REDACTED]
EOF

# Remover secretos
git filter-repo --replace-text /tmp/secrets.txt

# Push forzado
git push origin main --force-with-lease
```

---

## 🔒 Mejores Prácticas para el Futuro

### 1. Configurar Variables de Entorno

**NO hagas esto** ❌:
```dart
static const String secretKey = 'sk_test_...';  // ¡MAL!
```

**Haz esto sí** ✅:
```dart
// En producción, usar Firebase Remote Config:
static final secretKey = FirebaseRemoteConfig.instance.getString('stripe_secret_key');

// O en desarrollo, cargar de .env (ignorado por git):
// static const String secretKey = String.fromEnvironment('STRIPE_SECRET_KEY');
```

### 2. Usar `.env` para Desarrollo Local

**Crear `.env` (ignorado por `.gitignore`)**:
```
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_SECRET_KEY=sk_test_xxx
FIREBASE_PROJECT_ID=aparcamientos-zaragoza
```

**Cargar en main.dart**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

### 3. GitHub Actions - Secretos Seguros

**NO commitear claves** ❌.

**Usar GitHub Secrets** ✅:
```yaml
# En .github/workflows/deploy.yml
env:
  STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
```

---

## 🧪 Verificar que Funcionó

### 1. Confirmar que el secreto fue removido

```bash
# Ver últimos commits
git log --all --oneline | head -20

# Buscar el secreto en el historial (debe estar vacío)
git log --all -S "sk_test_51SuUod" --source --all
```

### 2. Verificar en GitHub

Después de hacer push:
1. Ir a: https://github.com/sergioP1991/aparcamientoszaragoza-flutter
2. Abrir un nuevo pull request al branch main
3. Si no hay errores de "Push Protection", ¡está arreglado!

### 3. Verificar en GitHub Security Settings

1. Ir a: Settings > Security > Push protection
2. Debería mostrar que la Secret Key ya no está detectada

---

## 📊 Cronograma

| Paso | Tiempo | Descripción |
|------|--------|------------|
| 1. Ejecutar script | 2-5 min | `./REMOVE_SECRETS.sh` |
| 2. Push forzado | 30 seg | `git push --force-with-lease` |
| 3. Notificar colaboradores | Inmediatamente | Comunicar del rewrite |
| 4. Verificación | 5 min | Confirmar en GitHub |

---

## 🆘 Si Algo Sale Mal

### Error: "fatal: working tree has unstaged changes"

```bash
# Hacer stash de cambios
git stash

# Intentar de nuevo
./REMOVE_SECRETS.sh

# Recuperar cambios
git stash pop
```

### Error: "Your branch has diverged"

Si otros han hecho push mientras reescribías:

```bash
# Obtener cambios remotos
git fetch origin

# Hacer rebase en lugar de merge
git rebase origin/main

# Push forzado (cuidado: si hay conflictos, resolver primero)
git push origin main --force-with-lease
```

### El secreto fue detectado de nuevo

```bash
# Verificar que está removido del Dart
grep -r "sk_test_" lib/

# Si encuentra algo, removerlo manualmente y hacer commit
git add .
git commit -m "Remove hardcoded secrets from code"
git push origin main
```

---

## 📚 Referencias

- [GitHub Push Protection Docs](https://docs.github.com/code-security/secret-scanning/working-with-secret-scanning-and-push-protection)
- [git-filter-repo Official](https://github.com/newren/git-filter-repo)
- [Stripe Security Best Practices](https://stripe.com/docs/security)
- [Flutter Environment Variables](https://flutter.dev/docs/development/environment-variables)

---

## 🎯 Resumen de Solución

```bash
# 1. Commit de cambios de código (ya hecho)
git add .
git commit -m "chore: remove hardcoded Stripe secrets and update .gitignore"

# 2. Reescribir historial
chmod +x REMOVE_SECRETS.sh
./REMOVE_SECRETS.sh

# 3. Push forzado
git push origin main --force-with-lease

# 4. Verificar
git log --all -S "sk_test" --source  # Debe estar vacío
```

✅ **LISTO**: Tu repositorio estará seguro y GitHub Push Protection dejará pasar.

---

**Fecha de creación**: 4 de marzo de 2026  
**Estado**: Guía de Recuperación de Seguridad
