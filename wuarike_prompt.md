# WUARIKE — Lima Food Discovery
## Documento de especificación completo para generación de código con IA

---

## CONTEXTO DEL PROYECTO

Construye una aplicación móvil llamada **Wuarike** — plataforma social de descubrimiento de comida en Lima, Perú. Combina mecánicas de **Foursquare** (mapa, check-ins, gamificación) y **TripAdvisor** (reseñas, fotos, videos, rankings). El usuario puede explorar sin cuenta, pero necesita sesión para interactuar.

---

## STACK TÉCNICO

### Frontend — Flutter
- Flutter 3.x / Dart 3
- Arquitectura: **Feature-first** con Clean Architecture por módulo
- State management: **Riverpod**
- HTTP: **Dio** con interceptores JWT (access + refresh token)
- Navegación: **GoRouter**
- Inyección de dependencias: **get_it**
- Mapas: **flutter_map** (OpenStreetMap / Leaflet)
- Geolocalización: **geolocator** + **geocoding**
- Imágenes: **image_picker** + **cached_network_image**
- Video: **camera** + **video_player** + **chewie** + **video_compress**
- Offline: **Hive**
- Plataformas: Android (SDK 26+) + iOS (13+)

### Backend — NestJS (ya existe en `d:\juan\warikes\backend`)
- NestJS + TypeScript
- PostgreSQL + **PostGIS** (geolocalización)
- TypeORM
- JWT Auth (access + refresh token)
- Cloudinary (fotos y videos)
- Docker + Caddy (reverse proxy)
- VPS: `38.242.252.183`
- Swagger: `http://38.242.252.183/api/docs`

---

## MÓDULOS DEL BACKEND (referencia para consumo desde Flutter)

| Módulo | Ruta base | Descripción |
|--------|-----------|-------------|
| `auth` | `/auth` | Login, registro, JWT, verificación email, social login |
| `users` | `/users` | Perfiles, roles (user/admin/business), follows |
| `places` | `/places` | Locales, geolocalización PostGIS, rareza COMÚN→LEGENDARIO |
| `checkins` | `/checkins` | Check-ins con fotos, likes, comentarios |
| `gamification` | `/gamification` | Badges, puntos, niveles, streaks |
| `missions` | `/missions` | Retos activos para usuarios |
| `ubigeo` | `/ubigeo` | Distritos de Perú |
| `admin` | `/admin` | Verificación de lugares, submissions |

---

## ESTRUCTURA DE CARPETAS FLUTTER

```
lib/
├── core/
│   ├── config/         # env, api_config, app_config
│   ├── di/             # get_it injection container
│   ├── network/        # dio_client, interceptors (JWT)
│   ├── router/         # gorouter config, rutas nombradas
│   ├── theme/          # colores, tipografía, tema global
│   ├── utils/          # helpers, extensions, constants
│   └── widgets/        # widgets globales reutilizables
│
├── features/
│   ├── auth/
│   │   ├── data/       # auth_repository_impl, auth_remote_datasource
│   │   ├── domain/     # auth_repository (abstract), use_cases, entities
│   │   └── presentation/ # screens, providers, widgets
│   │
│   ├── map/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── places/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── checkins/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── reviews/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── videos/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── gamification/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── favorites/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

---

## DISEÑO Y BRANDING

| Token | Valor |
|-------|-------|
| Primario | `#F26122` (naranja Wuarike) |
| Secundario | `#E8453C` (rojo coral) |
| Rating | `#FFB800` (amarillo estrellas) |
| Texto | `#1A1A1A` |
| Fondo | `#FFF5F0` |
| Éxito | `#00BFA5` |
| Tipografía | Poppins (Bold/SemiBold/Regular) |
| Border radius | 12px cards, 24px botones |
| Sombra cards | `BoxShadow` suave, offset (0,4), blur 12 |

### Componentes UI globales obligatorios
- `WuarikeButton` — botón primario naranja con loading state
- `WuarikeCard` — card con sombra para locales
- `WuarikeBottomBar` — tab bar con FAB central rojo (📍)
- `WuarikeAuthGate` — modal/bottom sheet de login que se dispara cuando usuario sin sesión toca acción restringida
- `RarityChip` — chip de color según rareza del lugar
- `StarRating` — widget de estrellas interactivo y solo lectura

---

## FLUJOS DE PANTALLAS

### FLUJO 1 — Splash & Onboarding
```
SplashScreen (fondo naranja, logo, tagline "Descubre los mejores sabores", spinner)
  └─► MapScreen (pantalla principal, modo invitado permitido)
```

### FLUJO 2 — Modo Invitado vs Autenticado
- El usuario puede navegar el mapa, buscar, filtrar, ver fichas, fotos, videos y reseñas **sin cuenta**
- Al intentar: check-in / guardar favorito / escribir reseña / subir foto o video / registrar local →
  se muestra `WuarikeAuthGate` (modal con opciones de login)
- Al cerrar el modal, regresa a la pantalla anterior sin perder el estado

### FLUJO 3 — Auth
```
WuarikeAuthGate
  ├─► LoginScreen
  │     ├─► SocialLogin (Google / Facebook / Instagram) → JWT desde backend
  │     └─► EmailLoginScreen
  │           └─► ForgotPasswordScreen
  └─► RegisterScreen
        └─► EmailVerificationScreen
```

### FLUJO 4 — Mapa principal
```
MapScreen
  ├─► SearchBar → SearchScreen → PlaceDetailScreen
  ├─► FilterButton → FiltersBottomSheet
  ├─► MarkerTap → PlaceDetailScreen
  ├─► FAB (+📍) → [auth gate si no hay sesión] → AddPlaceScreen
  └─► BottomBar
        ├─► ExploreTab (mapa)
        ├─► SearchTab
        ├─► FavoritesTab → FavoritesScreen
        └─► ProfileTab → ProfileScreen
```

### FLUJO 5 — Detalle de lugar
```
PlaceDetailScreen
  ├─► PhotoGallery (carrusel)
  ├─► VideosTab → VideoFeedScreen
  ├─► ReviewsTab → ReviewListScreen → WriteReviewScreen [auth gate]
  ├─► CheckInButton → [auth gate] → CheckInScreen
  ├─► SaveButton (❤️) → [auth gate] → guardado inmediato
  └─► ShareButton → sheet nativo de compartir
```

### FLUJO 6 — Check-in
```
CheckInScreen
  ├─► Validación GPS (≤ 500m del local)
  ├─► Selector: ¿Con quién? (solo / pareja / amigos / familia)
  ├─► Campo opcional: ¿Qué pediste hoy?
  ├─► Subir foto opcional
  └─► ConfirmCheckIn → BadgeUnlockScreen (si se desbloquea badge)
```

### FLUJO 7 — Gamificación
```
ProfileScreen
  ├─► LevelProgressBar (nivel actual, XP)
  ├─► BadgesGrid → BadgeDetailScreen
  ├─► MissionsTab → MissionListScreen
  └─► StatsTab (check-ins, reseñas, fotos, videos)
```

---

## PANTALLAS DETALLADAS

### MapScreen
- Mapa a pantalla completa con `flutter_map`
- Barra de búsqueda flotante superior
- Marcadores custom según rareza del lugar (color diferente por rareza)
- Punto azul = ubicación actual del usuario
- Botón de recentrar ubicación
- FAB central rojo con ícono 📍 (agregar lugar)
- Bottom navigation bar transparente sobre el mapa

### SearchScreen
- Input con placeholder *"Buscar restaurantes, platos..."*
- Ícono de filtros (sliders) que abre `FiltersBottomSheet`
- Estado vacío: ícono cubiertos + *"No se encontraron lugares"*
- Resultados: lista de `WuarikeCard` con foto, nombre, categoría, rating, distancia, precio

### FiltersBottomSheet / FiltersScreen
Secciones con scroll:
1. **Ordenar por:** `Relevancia` | `Distancia` | `Valoración` (chips selector único)
2. **Categoría de comida:** Todos | 🛒 Carretilla | 🍽️ Restaurante | 🐟 Cevichería | 🍗 Pollería | 🥢 Chifa *(multi-select)*
3. **Distrito:** Miraflores, San Isidro, Barranco, Surco, La Molina, San Borja, San Miguel, Magdalena, Lince, Jesús María, Pueblo Libre *(multi-select, scroll horizontal)*
4. **Distancia máxima:** Slider 0.5km → 20km, color naranja
5. **Calificación mínima:** Todas | 3.0⭐ | 3.5⭐ | 4.0⭐ | 4.5⭐
6. **Rango de precio:** $ Económico | $$ Moderado | $$$ Caro | $$$$ Muy caro
7. **Amenidades:** WiFi | Estacionamiento | Terraza | Delivery | Reservas | Pet Friendly *(checkboxes)*
8. **Servicios:** A corta distancia a pie | Acepta tarjetas | Bueno para familias | Para llevar
9. Botón **"Aplicar Filtros"** naranja sticky al fondo

### PlaceDetailScreen
- Hero image / carrusel de fotos
- Nombre, categoría, `RarityChip` (rareza del lugar)
- Rating con estrellas y conteo de reseñas
- Botones acción: ❤️ Guardar | ✅ Check-in | 📝 Reseñar | 📤 Compartir
- Info: dirección, horario, teléfono, web
- Mini mapa con ubicación del local
- Tabs: Platos | Fotos | Videos | Reseñas
- Sección "Locales similares cerca"

### FavoritesScreen
- Sección **Lugares Guardados** (contador badge naranja)
  - Estado vacío: corazón outline + *"No tienes lugares guardados"* + *"Toca el corazón en un lugar para guardarlo"*
- Sección **Check-ins Realizados** (contador badge naranja)
  - Estado vacío: badge outline

### ProfileScreen
- Foto + nombre + bio
- Nivel actual con barra de progreso XP
- Stats: check-ins | reseñas | fotos | videos
- Grid de badges obtenidos
- Misiones activas
- Botón de logout (solo si hay sesión)

### WuarikeAuthGate (modal)
- Ícono cuchillo × cuchara sobre círculo rosa pálido
- Título: *"¡Únete a la Caza de Wuarikes!"*
- Subtítulo: *"Guarda tus favoritos, sube de nivel y desbloquea recompensas legendarias."*
- Botón blanco borde: **Continuar con Google**
- Botón azul: **Continuar con Facebook**
- Botón rosa/rojo: **Continuar con Instagram**
- Separador: *"O con email"*
- Botón coral: **Usar correo electrónico**
- Botón X arriba izquierda para cerrar y volver

---

## SISTEMA DE RAREZA DE LUGARES

| Rareza | Color chip | Criterio sugerido |
|--------|-----------|-------------------|
| COMÚN | Gris | Lugar nuevo sin verificar |
| POCO COMÚN | Verde | Verificado + 5+ check-ins |
| RARO | Azul | Verificado + 20+ check-ins + 4⭐+ |
| ÉPICO | Morado | Verificado + 50+ check-ins + 4.5⭐+ |
| LEGENDARIO | Dorado ✨ | Verificado + 100+ check-ins + 4.8⭐+ |

---

## GAMIFICACIÓN

### Niveles de usuario
| Nivel | Nombre | Requisito |
|-------|--------|-----------|
| 1 | Cazador Novato | Registro |
| 2 | Explorador | 5 check-ins |
| 3 | Conocedor | 15 check-ins + 3 reseñas |
| 4 | Gourmet | 30 check-ins + 10 reseñas |
| 5 | Maestro Wuarike | 100 check-ins + 25 reseñas |

### Puntos por acción
| Acción | Puntos |
|--------|--------|
| Check-in | +10 |
| Check-in con foto | +20 |
| Reseña escrita | +15 |
| Reseña con foto | +25 |
| Video subido | +50 |
| Reseña votada como útil | +5 |
| Nuevo lugar registrado (verificado) | +100 |

### Badges destacados
- 🥇 Primer Check-in
- 🦁 Wuarike Cevichero (5 check-ins en cevicherías)
- 🌟 Crítico Estrella (10 reseñas con +10 votos útiles)
- 🗺️ Explorador de Distritos (check-in en 5 distritos)
- 📹 Camarógrafo Wuarike (3 videos subidos)
- 👑 Alcalde (más check-ins en un local = badge especial en ese lugar)

---

## REGLAS DE NEGOCIO IMPORTANTES

1. **Check-in geolocalizado:** validar que el usuario esté a ≤ 500 metros del local antes de permitir el check-in (usar `geolocator` para calcular distancia).
2. **Acceso sin sesión:** el mapa, la búsqueda y la vista de detalle son completamente accesibles sin login. El `WuarikeAuthGate` solo se dispara en acciones de escritura.
3. **Roles de usuario:**
   - `user` → experiencia estándar
   - `business` → puede editar su propio local directamente
   - `admin` → acceso a panel de verificación y moderación
4. **Lugares verificados:** un lugar en estado `pending` muestra un banner amarillo de "Pendiente de verificación" en su ficha.
5. **JWT refresh:** el cliente Dio debe tener interceptor que detecte 401 y ejecute el refresh token automáticamente antes de reintentar la petición.
6. **Imágenes:** comprimir antes de subir a Cloudinary (máx. 1MB por foto). Videos: máx. 60 segundos, comprimir antes de subir.

---

## ORDEN DE IMPLEMENTACIÓN RECOMENDADO

```
1. core/  →  theme, di, network (Dio + JWT interceptor), router
2. feature/auth  →  splash, login, registro, auth gate
3. feature/map  →  mapa principal, marcadores, ubicación
4. feature/places  →  búsqueda, filtros, detalle de lugar
5. feature/checkins  →  flujo check-in con validación GPS
6. feature/reviews  →  escribir y listar reseñas
7. feature/favorites  →  guardar y listar favoritos
8. feature/videos  →  subir y ver videos del local
9. feature/gamification  →  badges, niveles, misiones
10. feature/profile  →  perfil completo, stats, settings
```

---

## NOTAS PARA EL AGENTE DE IA

- El backend **ya existe y está en producción**. Solo debes consumir la API REST.
- Consulta el Swagger en `http://38.242.252.183/api/docs` para ver los endpoints exactos, DTOs y respuestas antes de implementar cada feature.
- No generes código de backend. Solo código Flutter.
- Usa siempre `const` constructors donde sea posible.
- Todos los textos de la UI deben estar en **español**.
- Implementa manejo de errores en cada petición (estado de loading, error y datos).
- Cada feature debe tener su propio `Provider` (Riverpod) aislado.
- No uses `setState` directamente en pantallas; toda la lógica va en providers o notifiers.
