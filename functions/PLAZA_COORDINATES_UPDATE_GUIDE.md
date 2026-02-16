/**
 * GUÍA DE ACTUALIZACIÓN DE COORDENADAS DE PLAZAS DE ZARAGOZA
 * 
 * UBICACIONES CORRECTAS BASADAS EN SKILL DE APARCAMIENTOS ZARAGOZA
 * Período 2025-2030
 */

// Abrir consola de Firebase: https://console.firebase.google.com
// Ir a: aparcamientos-zaragoza > Firestore Database > Colección 'garaje'

// PLAZAS CON COORDENADAS CORREGIDAS PARA ZARAGOZA
// =====================================================

// 1. ZONA CENTRO (Casco Histórico - dentro de ZBE Fase 1)
// Plaza del Pilar (Centro turístico principal)
// Buscar en 'garaje' donde direccion contiene "Pilar"
// Actualizar: latitud = 41.6551, longitud = -0.8896

// Calle Coso (Vía principal)
// Buscar: direccion contiene "Coso"
// Actualizar: latitud = 41.6525, longitud = -0.8901

// Calle Alfonso I (Centro comercial)
// Buscar: direccion contiene "Alfonso"
// Actualizar: latitud = 41.6508, longitud = -0.8885

// Plaza España (Centro administrativo)
// Buscar: direccion contiene "España"
// Actualizar: latitud = 41.6445, longitud = -0.8945

// Puente de Piedra (Acceso al Pilar)
// Buscar: direccion contiene "Puente"
// Actualizar: latitud = 41.6579, longitud = -0.8852

// 2. ZONA CONDE ARANDA (Límite ZBE)
// Calle Conde Aranda (Frontera de la ZBE)
// Buscar: direccion contiene "Conde Aranda"
// Actualizar: latitud = 41.6488, longitud = -0.8891

// Calle Mayor (Acceso a zona histórica)
// Buscar: direccion contiene "Mayor"
// Actualizar: latitud = 41.6495, longitud = -0.8910

// Calle Espada
// Buscar: direccion contiene "Espada"
// Actualizar: latitud = 41.6510, longitud = -0.8860

// 3. ACTUR / CAMPUS RÍO EBRO (Zona Norte - Gratuita)
// Campus Río Ebro (Universidad)
// Buscar: direccion contiene "Campus"
// Actualizar: latitud = 41.6810, longitud = -0.6890

// Actur (Barrio residencial)
// Buscar: direccion contiene "Actur"
// Actualizar: latitud = 41.6795, longitud = -0.7120

// 4. LA ALMOZARA (Zona blanca gratuita)
// Barrio Almozara
// Buscar: direccion contiene "Almozara"
// Actualizar: latitud = 41.6720, longitud = -0.8420

// Calle Gutiérrez Larraya
// Buscar: direccion contiene "Gutiérrez"
// Actualizar: latitud = 41.6745, longitud = -0.8390

// 5. DELICIAS (Zona blanca cerca estación)
// Estación de Zaragoza
// Buscar: direccion contiene "Estación" OR "Delicias"
// Actualizar: latitud = 41.6433, longitud = -0.8810

// Barrio Delicias
// Buscar: direccion contiene "Delicias"
// Actualizar: latitud = 41.6420, longitud = -0.8750

// 6. PARK & RIDE - LÍNEA 1 TRANVÍA
// Valdespartera (Acceso Sur)
// Buscar: direccion contiene "Valdespartera"
// Actualizar: latitud = 41.5890, longitud = -0.8920
// NOTA: Tarifa bonificada 0,06€/hora si se usa tranvía

// La Chimenea (Acceso Norte)
// Buscar: direccion contiene "Chimenea"
// Actualizar: latitud = 41.7020, longitud = -0.8650
// NOTA: Tarifa bonificada 0,06€/hora si se usa tranvía

// 7. ZONA EXPO (Parking Sur - Gratuito)
// Parking Expo Sur
// Buscar: direccion contiene "Expo"
// Actualizar: latitud = 41.6340, longitud = -0.8420
// NOTA: ~5.600 plazas disponibles

// 8. SAN JOSÉ (Zona blanca gratuita)
// Barrio San José
// Buscar: direccion contiene "San José"
// Actualizar: latitud = 41.6380, longitud = -0.9050

// =====================================================
// PASOS PARA ACTUALIZAR EN FIRESTORE:
// =====================================================

/*
1. Abrir https://console.firebase.google.com
2. Seleccionar proyecto: aparcamientos-zaragoza
3. Ir a Firestore Database
4. Abrir colección: garaje
5. Para cada documento:
   a) Hacer clic en el documento
   b) Editar campo 'latitud' con el valor correcto
   c) Editar campo 'longitud' con el valor correcto
   d) Guardar cambios

O ALTERNATIVA CON FIREBASE CLI:

firebase emulators:start --import=./backup
// Luego actualizar documentos
firebase emulators:export ./backup
*/

// =====================================================
// RESUMEN DE ZONAS (por skill de aparcamientos zaragoza)
// =====================================================

/*
ZONA AZUL (ESRO) - Alta rotación
- Máximo 120 minutos visitantes
- Tarifa: 0,25€ (25 min), 0,70€ (1 h), 1,45€ (2 h)
- Horarios: L-V 9:00-14:00 y 17:00-20:00
- Sábados/domingos/festivos: GRATUITO

ZONA NARANJA (ESRE) - Prioridad residentes
- Máximo 60 minutos visitantes
- Tarifa: 0,25€ (25 min), 0,75€ (45 min), 1,15€ (1 h)
- Horarios: L-V 9:00-14:00 y 17:00-20:00
- Sábados/domingos/festivos: GRATUITO

ZONA DE BAJAS EMISIONES (ZBE) - Casco Histórico
- Activa desde diciembre 2025
- Horarios: L-V 8:00-20:00
- Permitidas etiquetas: 0, ECO, C, B
- Margen de salida: 15 minutos si entran sin permiso

APARCAMIENTOS DISUASORIOS (Park & Ride)
- Valdespartera (Sur): 0,06€/h con tranvía
- La Chimenea (Norte): 0,06€/h con tranvía

ZONAS BLANCAS (GRATUITAS)
- Macanaz: ~200 plazas, 10 min del Pilar
- Expo/Parking Sur: ~5.600 plazas
- Actur/Campus: Gratuito + vigilancia
- La Almozara, Delicias, San José

ACCESIBILIDAD (PMR)
- Tarjeta Azul: GRATIS sin límite de tiempo en ORA
- Plan de 1.505 plazas reservadas en vía pública
*/
