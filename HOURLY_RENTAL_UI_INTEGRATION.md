# 🕐 Guía de Integración en UI - Sistema de Alquiler por Horas

## Dónde Agregar los Botones

### 1. En la Pantalla de Detalle de Plaza (`detailsGarage_screen.dart`)

Busca la sección donde están los botones de acción y agrega un nuevo botón:

```dart
// En la función _buildActionButtons() o similar, agregar:

Row(
  children: [
    // Botón de alquiler normal (si existe)
    if (plaza.rentIsNormal)
      Expanded(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, RentPage.routeName, 
              arguments: plaza.idPlaza);
          },
          child: const Text('Alquilar (Mensual)'),
        ),
      ),
    const SizedBox(width: 12),
    
    // NUEVO: Botón de alquiler por horas
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        onPressed: () {
          Navigator.pushNamed(context, RentByHoursScreen.routeName,
            arguments: plaza.idPlaza);
        },
        child: const Text('⏱️ Por Horas'),
      ),
    ),
  ],
)
```

### 2. En la Pantalla de Home (`home_screen.dart`)

Agregar un botón flotante o en el AppBar para ver alquileres activos:

```dart
// En el AppBar o en FloatingActionButton:

// Opción 1: FloatingActionButton
floatingActionButton: FloatingActionButton(
  backgroundColor: Colors.blue,
  onPressed: () {
    Navigator.pushNamed(context, ActiveRentalsScreen.routeName);
  },
  child: const Icon(Icons.timer),
  tooltip: 'Mis Alquileres Activos',
),

// Opción 2: Botón en el AppBar
actions: [
  IconButton(
    icon: const Icon(Icons.timer),
    onPressed: () {
      Navigator.pushNamed(context, ActiveRentalsScreen.routeName);
    },
    tooltip: 'Alquileres Activos',
  ),
]
```

### 3. En la Pantalla de Mis Garajes/Perfil (`settings_screen.dart`)

Agregar una opción para ver alquileres:

```dart
// En el menú de settings, agregar:

_buildSettingsItem(
  Icons.timer,
  'Mis Alquileres Activos',
  '',
  onTap: () {
    Navigator.pushNamed(context, ActiveRentalsScreen.routeName);
  },
),
```

---

## Imports Necesarios

Agregar estos imports en los archivos donde se agreguen los botones:

```dart
import 'package:aparcamientoszaragoza/Screens/rent_by_hours/rent_by_hours_screen.dart';
import 'package:aparcamientoszaragoza/Screens/active_rentals/active_rentals_screen.dart';
```

---

## Rutas en main.dart

Asegúrate de que estas rutas estén definidas en `main.dart`:

```dart
routes: {
  // ... otras rutas ...
  RentByHoursScreen.routeName: (context) => const RentByHoursScreen(),
  ActiveRentalsScreen.routeName: (context) => const ActiveRentalsScreen(),
  // ... más rutas ...
}
```

---

## Localización (i18n)

Para agregar textos localizados en `lib/l10n/app_es.arb` y `app_en.arb`:

```json
{
  "rentByHours": "Alquilar por Horas",
  "activeRentals": "Alquileres Activos",
  "selectDuration": "Selecciona la duración",
  "durationHours": "{count, plural, =1{1 hora} other{{count} horas}}",
  "@durationHours": {
    "description": "Duración en horas",
    "placeholders": {
      "count": {
        "type": "int",
        "example": "2"
      }
    }
  },
  "estimatedPrice": "Precio estimado",
  "expirationTime": "Hora de vencimiento",
  "safetyMargin": "Margen de seguridad",
  "potentialPenalty": "Multa potencial",
  "releaseNow": "Liberar Ahora",
  "confirmRental": "Confirmar Alquiler",
  "timeRemaining": "Tiempo restante",
  "timeUsed": "Tiempo usado",
  "pricePerMinute": "Precio por minuto",
  "totalEstimated": "Total estimado",
  "rentalExpired": "Alquiler vencido",
  "penaltyPending": "Multa pendiente",
  "releaseMargin": "Margen de 5 minutos",
  "releaseMarginDescription": "Libera la plaza ahora para evitar multa",
  "penaltyAlert": "⚠️ MULTA PENDIENTE",
  "penaltyAlertDescription": "Has pasado el margen. Se te aplicará una multa"
}
```

---

## Flujo de Navegación

```
Home Screen
    ↓
    └─→ [Click Plaza]
            ↓
            Details Garage Screen
                ↓
                ├─→ [Alquilar Mensual] → Rent Screen
                │
                └─→ [⏱️ Por Horas] → Rent By Hours Screen
                        ↓
                        [Selecciona duración]
                        ↓
                        [Confirmar] → Active Rentals Screen
                                ↓
                                [Monitoreo en tiempo real]
                                ↓
                                ├─→ [Liberar Ahora] → Pago
                                │
                                └─→ [Esperar a vencimiento] → Automático
```

---

## Notificaciones en la UI

Para mostrar notificaciones de alquileres que están por vencer:

```dart
// En home_screen.dart, agregar en initState:
@override
void initState() {
  super.initState();
  
  // Escuchar alquileres activos
  FirebaseFirestore.instance
    .collection('alquileres')
    .where('tipo', isEqualTo: 2) // Alquileres por horas
    .where('estado', isIn: ['EstadoAlquilerPorHoras.vencido', 'EstadoAlquilerPorHoras.multa_pendiente'])
    .where('idArrendatario', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
    .snapshots()
    .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Mostrar badge o notificación en la UI
        _showRentalNotification(snapshot.docs);
      }
    });
}

void _showRentalNotification(List<QueryDocumentSnapshot> rentals) {
  // Mostrar Snackbar o dialogo
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('⚠️ Tienes ${rentals.length} alquiler(es) que requieren atención'),
      action: SnackBarAction(
        label: 'Ver',
        onPressed: () {
          Navigator.pushNamed(context, ActiveRentalsScreen.routeName);
        },
      ),
    ),
  );
}
```

---

## Testing en Desarrollo

Para probar sin esperar a que venza el tiempo real:

```dart
// En rental_by_hours_provider.dart, puedes agregar:

// Para testing: crear alquiler con duración muy corta
static Future<String?> createTestRental({
  required int plazaId,
  int durationSeconds = 60, // 1 minuto para testing
}) async {
  return createRental(
    plazaId: plazaId,
    durationMinutes: (durationSeconds ~/ 60).clamp(1, 1000),
    pricePerMinute: 0.05, // Precio bajo para testing
  );
}
```

---

## Iconografía Recomendada

| Elemento | Icono | Color |
|----------|-------|-------|
| Alquiler por Horas | `Icons.timer` | Naranja |
| Alquileres Activos | `Icons.access_time` | Azul |
| Tiempo Restante | `Icons.schedule` | Verde |
| Vencido | `Icons.timer_off` | Naranja |
| Multa | `Icons.warning` | Rojo |
| Liberar | `Icons.check_circle` | Verde |

---

## Diseño Responsive

Los componentes están diseñados para ser responsive:

```dart
// En screens pequeños, ajustar el grid de duraciones:
GridView.count(
  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
  // ... rest of grid
)
```

---

## Próximos Pasos

1. Agregar los imports en los archivos necesarios
2. Agregar los botones en las pantallas (detalle, home, settings)
3. Actualizar rutas en main.dart
4. Agregar textos localizados en i18n
5. Probar navegación
6. Desplegar Cloud Functions cuando esté listo

---

**Fecha**: 27 de febrero de 2026
