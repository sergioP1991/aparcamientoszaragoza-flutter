# 🅿️ Aparcamientos Zaragoza

> **Aplicación multiplataforma para gestión y búsqueda de aparcamientos en Zaragoza**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Descripción

Aparcamientos Zaragoza es una aplicación moderna construida con **Flutter** que permite a los usuarios:

- 🗺️ **Ver mapas interactivos** con 16+ plazas de aparcamiento distribuidas por la ciudad
- 🔍 **Buscar aparcamientos** por ubicación, tipo de vehículo y disponibilidad
- ❤️ **Marcar favoritos** para acceso rápido
- 📱 **Alquilar plazas** directamente desde la app
- 💬 **Comentar y calificar** experiencias
- 🌙 **Tema oscuro/claro** adaptable

---

## ✨ Características Principales

### 🎯 Funcionalidades
- ✅ Visualización de 16 plazas de aparcamiento georreferenciadas
- ✅ Filtros avanzados: tipo vehículo, estado (libre/ocupado), precio
- ✅ Sistema de favoritos sincronizado con Firebase
- ✅ Perfil de usuario con historial de alquileres
- ✅ Formulario de contacto y soporte por email
- ✅ Autenticación por Firebase Auth
- ✅ Búsqueda y ordenamiento por precio

### 🗺️ Coordenadas Actualizadas (Zaragoza 2025)

| Zona | Dirección | Lat | Lon |
|------|-----------|-----|-----|
| Centro | Plaza del Pilar | 41.6551 | -0.8896 |
| Centro | Calle Coso | 41.6525 | -0.8901 |
| Centro | Calle Alfonso I | 41.6508 | -0.8885 |
| Centro | Plaza España | 41.6445 | -0.8945 |
| Centro | Puente de Piedra | 41.6579 | -0.8852 |
| Conde Aranda | Calle Conde Aranda | 41.6488 | -0.8891 |
| Actur/Campus | Campus Río Ebro | 41.6810 | -0.6890 |
| Almozara | Barrio Almozara | 41.6720 | -0.8420 |
| Delicias | Estación Zaragoza | 41.6433 | -0.8810 |
| Park & Ride | Valdespartera | 41.5890 | -0.8920 |
| Park & Ride | La Chimenea | 41.7020 | -0.8650 |
| Expo | Parking Expo Sur | 41.6340 | -0.8420 |
| San José | Barrio San José | 41.6380 | -0.9050 |
| Otros | Plaza 1 Moises | 41.6450 | -0.8920 |
| Otros | Calle Ibon Catieras | 41.6320 | -0.9040 |

---

## 🚀 Comenzar

### Requisitos Previos

- **Flutter** 3.x+ ([Descargar](https://flutter.dev/docs/get-started/install))
- **Dart** 3.x+ (incluido con Flutter)
- **Git**
- Navegador web (Chrome recomendado)

### Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/usuario/aparcamientos-zaragoza.git
cd aparcamientos-zaragoza

# 2. Instalar dependencias
flutter pub get

# 3. Generar código (si es necesario)
flutter pub run build_runner build
```

### Ejecución

```bash
# Ejecutar en Chrome (web)
flutter run -d chrome

# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS
flutter run -d ios
```

La aplicación estará disponible en **http://localhost**

---

## 🏗️ Arquitectura

### Estructura del Proyecto

```
lib/
├── main.dart                     # Punto de entrada
├── Models/                       # Modelos de datos
│   ├── garaje.dart             # Plaza de aparcamiento
│   ├── alquiler.dart           # Contrato de alquiler
│   ├── auth.dart               # Usuario
│   └── favorite.dart           # Marcadores
├── Screens/                     # Pantallas UI
│   ├── home/                   # Pantalla principal
│   ├── login/                  # Autenticación
│   ├── settings/               # Configuración
│   ├── detailsGarage/         # Detalles de plaza
│   └── ...
├── Services/                    # Servicios (APIs, Firebase)
│   ├── PlazaCoordinatesUpdater.dart
│   └── ...
├── Widgets/                     # Widgets reutilizables
└── Values/                      # Constantes y estilos
```

### Stack Tecnológico

| Tecnología | Propósito |
|------------|-----------|
| **Flutter** | Framework multiplataforma UI |
| **Dart** | Lenguaje de programación |
| **Firebase** | Backend (Auth, Firestore) |
| **Google Maps** | Visualización de mapas |
| **Riverpod** | State management |
| **EmailJS** | Envío de emails |

---

## 🔧 Configuración Firebase

### Firestore Collections

```
garaje/
├── idPlaza: number
├── direccion: string
├── latitud: number
├── longitud: number
├── propietario: string (uid)
├── precio: number
├── alquiler: Alquiler
└── ...

favorites/
├── userId: string
├── idPlaza: string
└── timestamp: date

alquileres/
├── idPlaza: number
├── usuarioId: string
├── fechaInicio: date
└── fechaFin: date
```

---

## 📱 Pantallas Principales

### 🏠 Home
- Lista de plazas con filtros
- Vista de mapa interactivo con 16 marcadores
- Búsqueda por dirección

### 📍 Detalles
- Información completa de la plaza
- Galería de fotos
- Comentarios de usuarios
- Botón de alquiler

### ⚙️ Configuración
- Idioma (ES/EN)
- Tema (Claro/Oscuro)
- Alertas de reserva
- Formulario de contacto

### 👤 Perfil
- Historial de alquileres
- Plazas publicadas
- Favoritos

---

## 🌐 Localización

La aplicación soporta:

- 🇪🇸 **Español**
- 🇬🇧 **Inglés**

Los archivos de localización están en `lib/l10n/`:
- `app_es.arb` (Español)
- `app_en.arb` (Inglés)

---

## 📧 Contacto y Soporte

### Formulario de Contacto
Accesible desde **Configuración → Ayuda y Soporte**

- **Email**: soporte@aparcamientos-zaragoza.com
- **Destinatarios**: 
  - moisesvs@gmail.com
  - sergio1991hortas@gmail.com

### Enviado mediante EmailJS
Integración de third-party para envío de emails sin backend

---

## 🚨 Troubleshooting

### ❌ Error: "Tried to build dirty widget"
**Solución:**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### ❌ Error: "Cannot hit test render box"
**Solución:** Espera a que cargue completamente la app en Chrome

### ❌ Mapa no muestra plazas
**Solución:** Verifica que:
1. Las coordenadas en Firestore sean válidas (41.0-42.0 lat, -1.5 a -0.5 lon)
2. No haya filtros activos ocultando las plazas
3. Google Maps API esté habilitada

---

## 📊 Estadísticas

- **Plazas totales**: 16+
- **Zonas cubiertas**: 12
- **Lenguajes soportados**: 2
- **Tamaño de APK**: ~50 MB (Android)
- **Usuarios objetivo**: Residentes de Zaragoza

---

## 🔐 Seguridad

- ✅ Autenticación Firebase con 2FA
- ✅ Firestore Security Rules
- ✅ Validación de datos en cliente y servidor
- ✅ Encriptación HTTPS

---

## 📄 Licencia

Este proyecto está bajo licencia **MIT**. Ver archivo [LICENSE](LICENSE) para detalles.

---

## 👥 Contribuidores

- **Sergio Hortas** - Desarrollo principal
- **Moisés García** - Diseño y UX

---

## 🎯 Roadmap

- [ ] Integración de pago con Stripe
- [ ] Notificaciones push
- [ ] Soporte para más ciudades españolas
- [ ] Versión de escritorio (Windows/macOS)
- [ ] API REST pública
- [ ] Análisis de precios históricos

---

## 📞 Contacto

**Email**: sergio1991hortas@gmail.com  
**GitHub**: [Aparcamientos Zaragoza](https://github.com/usuario/aparcamientos-zaragoza)

---

<div align="center">

**Hecho con ❤️ en Zaragoza**

![Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Powered%20by-Firebase-FFCA28?style=for-the-badge&logo=firebase)

</div>
