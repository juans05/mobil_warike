# Mesero Digital — Diseño Completo (B2B Dashboard + IA)
**Fecha:** 2026-04-25
**Proyecto:** Wuarike Ecosystem
**Scope:** Dashboard web para restaurantes + chatbot IA orquestado por n8n

---

## 1. Visión General

El **Mesero Digital** es un producto B2B dentro del ecosistema Wuarike. Permite a los restaurantes registrados:

1. **Gestionar su carta** (menú, alérgenos, recomendaciones, maridaje)
2. **Recibir pedidos y reservas** via chatbot IA
3. **Capturar feedback negativo de forma privada** (antes de que se convierta en reseña pública)
4. **Configurar la personalidad del bot** (nombre, tono, idioma)

El canal del chatbot puede ser: WhatsApp, widget web embebido en la carta del local, o la app Wuarike directamente.

---

## 2. Arquitectura — Monorepo Turborepo

### Estructura de carpetas

```
warike_business/
├── apps/
│   ├── dashboard/                        ← Next.js 14 App Router (panel B2B)
│   │   ├── app/
│   │   │   ├── (auth)/
│   │   │   │   ├── login/
│   │   │   │   └── register/
│   │   │   ├── (dashboard)/
│   │   │   │   ├── layout.tsx            ← sidebar + nav principal
│   │   │   │   ├── page.tsx              ← Inicio: 4 KPIs + actividad reciente
│   │   │   │   ├── carta/
│   │   │   │   │   ├── page.tsx          ← lista categorías/platos
│   │   │   │   │   └── [itemId]/
│   │   │   │   │       └── page.tsx      ← wizard edición de plato
│   │   │   │   ├── reservas/
│   │   │   │   │   └── page.tsx          ← calendario + lista
│   │   │   │   ├── pedidos/
│   │   │   │   │   └── page.tsx          ← pedidos activos en tiempo real
│   │   │   │   ├── feedback/
│   │   │   │   │   └── page.tsx          ← tarjetas privadas de queja
│   │   │   │   └── bot/
│   │   │   │       └── page.tsx          ← config personalidad del bot
│   │   │   └── api/
│   │   │       └── webhooks/
│   │   │           └── n8n/route.ts      ← recibe eventos de n8n → push UI
│   │   ├── components/
│   │   │   ├── ui/                       ← shadcn/ui (Button, Card, Badge...)
│   │   │   └── business/
│   │   │       ├── KpiCard.tsx
│   │   │       ├── CartaItemRow.tsx
│   │   │       ├── ReservaCard.tsx
│   │   │       ├── PedidoCard.tsx
│   │   │       └── FeedbackCard.tsx
│   │   └── lib/
│   │       ├── api-client.ts             ← fetch wrapper hacia bot-gateway
│   │       ├── auth.ts                   ← next-auth config
│   │       └── types.ts                  ← re-export desde packages/types
│   │
│   └── bot-gateway/                      ← NestJS (auth + dominio + proxy n8n)
│       └── src/
│           ├── carta/
│           │   ├── carta.module.ts
│           │   ├── carta.service.ts
│           │   ├── carta.controller.ts
│           │   └── entities/carta-item.entity.ts
│           ├── reservas/
│           │   ├── reservas.module.ts
│           │   ├── reservas.service.ts
│           │   └── reservas.controller.ts
│           ├── pedidos/
│           │   ├── pedidos.module.ts
│           │   ├── pedidos.service.ts
│           │   └── pedidos.controller.ts
│           ├── feedback/
│           │   ├── feedback.module.ts
│           │   ├── feedback.service.ts   ← NUNCA expone al canal público
│           │   └── feedback.controller.ts
│           ├── webhooks/
│           │   └── n8n-webhook.controller.ts
│           └── auth/
│               └── jwt-business.guard.ts ← JWT separado del auth principal
│
├── packages/
│   └── types/
│       ├── carta.types.ts
│       ├── reserva.types.ts
│       ├── pedido.types.ts
│       └── feedback.types.ts
│
├── workflows/                            ← exports JSON de n8n (versionados en git)
│   ├── mesero-core.json
│   ├── mesero-pedidos.json
│   ├── mesero-reservas.json
│   └── mesero-feedback.json
│
├── turbo.json
├── package.json
└── .env.example
```

### Flujo de datos

```
Cliente (WhatsApp / Web Widget / Wuarike App)
    │
    ▼ POST /webhook/chat
n8n (orquestador IA)
    │
    ├─ GET /carta/:restaurantId  ──► bot-gateway (NestJS)
    │                                    └─► PostgreSQL (carta JSON)
    │
    ├─ LLM call (Claude sonnet-4-6 / GPT-4o)
    │
    └─ POST /pedidos | /reservas | /feedback  ──► bot-gateway
                                                      │
                                             WebSocket / polling
                                                      │
                                             Dashboard (Next.js) ← dueño del restaurante
```

---

## 3. Esquema JSON — La Carta

```typescript
// packages/types/carta.types.ts

export interface Restaurant {
  id: string;
  name: string;
  wuarike_place_id: string;
  currency: 'PEN' | 'USD';
  timezone: string;
  bot_persona: BotPersona;
  schedule: WeekSchedule;
  reservations: ReservationConfig;
}

export interface BotPersona {
  name: string;                          // ej: "Carlitos"
  tone: 'amigable' | 'formal' | 'divertido';
  language: 'es-PE' | 'es' | 'en';
  greeting: string;
}

export interface CartaItem {
  id: string;
  category_id: string;
  name: string;
  description: string;
  price: number;
  image_url?: string;
  available: boolean;
  prep_time_minutes: number;
  is_chef_recommendation: boolean;
  chef_note?: string;
  tags: string[];
  allergens: string[];                   // ["pescado","gluten","lácteos"...]
  dietary: DietaryInfo;
  pairing: PairingInfo;
  variants: ItemVariant[];
  combo_ids: string[];
}

export interface DietaryInfo {
  is_vegetarian: boolean;
  is_vegan: boolean;
  is_gluten_free: boolean;
  is_lactose_free: boolean;
  is_spicy: boolean;
  spice_level: 0 | 1 | 2 | 3;          // 0=no picante, 3=muy picante
}

export interface PairingInfo {
  drinks: string[];
  pairing_note?: string;
}

export interface ItemVariant {
  id: string;
  name: string;                          // ej: "Sin cebolla", "Extra picante"
  price_delta: number;                   // puede ser 0, positivo o negativo
}

export interface CartaCategory {
  id: string;
  name: string;
  emoji: string;
  sort_order: number;
  available: boolean;
}

export interface Combo {
  id: string;
  name: string;
  item_ids: string[];
  price: number;
  original_price: number;
  available_from: string;               // "12:00"
  available_until: string;              // "15:00"
}

export interface WeekSchedule {
  monday:    DaySchedule;
  tuesday:   DaySchedule;
  wednesday: DaySchedule;
  thursday:  DaySchedule;
  friday:    DaySchedule;
  saturday:  DaySchedule;
  sunday:    DaySchedule;
}

export interface DaySchedule {
  open: string;   // "12:00"
  close: string;  // "22:00"
  closed?: boolean;
}

export interface ReservationConfig {
  enabled: boolean;
  max_party_size: number;
  min_advance_hours: number;
  max_advance_days: number;
  slots: string[];                       // ["12:00","13:00","19:00","20:00"]
}
```

---

## 4. System Prompt — El Cerebro del Mesero Digital

El system prompt se construye dinámicamente en n8n inyectando la carta JSON completa del restaurante.

```
SYSTEM PROMPT — MESERO DIGITAL WUARIKE
───────────────────────────────────────

Eres {{bot_persona.name}}, el mesero digital de {{restaurant.name}}.
Tono: {{bot_persona.tone}}. Idioma: español peruano natural (no excesivamente formal).

## TU MISIÓN
Ayudar al cliente con: (1) explorar la carta, (2) hacer un pedido,
(3) hacer una reserva, (4) resolver dudas sobre alérgenos o ingredientes.

## LA CARTA (contexto completo inyectado)
{{carta_json_completo}}

## REGLAS DURAS (nunca las rompas)
1. Solo hablas sobre este restaurante. No das recetas, no comparas con otros locales.
2. Si el cliente pregunta por un plato NO disponible (available: false), díselo
   claramente y sugiere 1-2 alternativas del mismo estilo de la carta.
3. NUNCA inventes precios, ingredientes ni horarios. Si no está en la carta, di
   "déjame consultarlo con el equipo" y registra la pregunta como gap de carta.
4. Para alérgenos: sé extremadamente preciso. Si el cliente dice tener alergia,
   confirma cada ingrediente antes de recomendar un plato.
5. Si detectas INSATISFACCIÓN (queja, decepción, problema):
   - NO respondas de forma defensiva.
   - Activa flujo FEEDBACK PRIVADO: "Lamento mucho eso. ¿Me permites
     conectarte con el encargado para resolverlo personalmente?"
   - NUNCA sugieras que escriban una reseña pública.
6. Confirma siempre pedidos y reservas con un resumen completo antes de cerrar.
7. Si el cliente pide algo fuera del menú (delivery a otra ciudad, etc.),
   declina amablemente y redirige a lo que sí puedes hacer.

## FORMATO DE RESPUESTA
- Máximo 3 oraciones por turno.
- Usa emojis con moderación (máximo 2 por mensaje).
- Para mostrar la carta: usa listas simples, nunca tablas Markdown.
- Al mostrar precios: siempre incluye la moneda (S/. para soles peruanos).

## CONTEXTO DE SESIÓN (inyectado por n8n en cada llamada)
- Fecha y hora actual Lima: {{current_datetime}}
- Canal de contacto: {{channel}}
- ID de sesión: {{session_id}}
- Nombre del cliente (si disponible): {{customer_name}}
```

---

## 5. Flujos de Conversación

### 5.1 Flujo: Consulta de Carta / Recomendación

```
Cliente: "¿Qué tienen de entrada?" / "¿Qué me recomiendas?"
    │
n8n: detecta intención = consulta_carta
    │
    ▼
LLM: filtra items por categoría / is_chef_recommendation
    Respuesta: lista máx. 4 platos con nombre, precio, emoji de categoría
    │
    ▼
Si cliente pregunta por alérgenos:
    LLM: cruza dietary + allergens del plato específico
    Respuesta: confirmación explícita de cada alérgeno presente/ausente
```

### 5.2 Flujo: Pedido

```
Cliente: "Quiero pedir" / "Me das un ceviche"
    │
n8n: detecta intención = pedido
    │
    ▼
LLM: confirma disponibilidad (available: true + horario actual)
    │
    ▼ si hay variantes
Bot: "¿Lo quieres con o sin cebolla?" (muestra variantes del plato)
    │
    ▼
Bot: "¿Algo más?" → loop hasta cliente dice "no" / "es todo"
    │
    ▼
Bot: resumen completo:
    "Tu pedido:
    - 1x Ceviche Clásico sin cebolla — S/. 28
    - 1x Chicha morada — S/. 8
    Total: S/. 36 | Tiempo estimado: ~20 min
    ¿Confirmo?"
    │
    ├─► Sí → n8n: POST bot-gateway /pedidos
    │         Dashboard: notificación push al dueño
    │         Bot: "¡Pedido #{{id}} confirmado! 🍽️"
    │
    └─► No → Bot: "¿Qué quieres cambiar?"
```

### 5.3 Flujo: Reserva

```
Cliente: "Quiero reservar una mesa"
    │
n8n: detecta intención = reserva
    │
    ▼
Bot: "¿Para qué fecha?" (valida: no pasado, no > max_advance_days)
    │
    ▼
Bot: "¿A qué hora?" (muestra slots disponibles del día elegido)
    │
    ▼
Bot: "¿Cuántas personas?" (valida: 1 ≤ n ≤ max_party_size)
    │
    ▼
Bot: "¿Tu nombre y teléfono de contacto?"
    │
    ▼
Bot: resumen:
    "Reserva para 4 personas
    📅 Sábado 26 de abril a las 20:00
    Nombre: Juan García | Tel: 999-888-777
    ¿Confirmo?"
    │
    ├─► Sí → n8n: POST bot-gateway /reservas
    │         n8n: envía confirmación por WhatsApp/email al cliente
    │         Dashboard: nueva reserva visible en calendario
    │         Bot: "Reserva #{{id}} confirmada ✅ Te esperamos."
    │
    └─► No → Bot: "¿Qué quieres cambiar?"
```

### 5.4 Flujo: Feedback Negativo Privado *(flujo crítico de retención)*

```
Cliente: expresa queja, insatisfacción o problema
    │
n8n: análisis de sentimiento → score < 0.3 → activa este flujo
    │
    ▼
Bot: "Lamento mucho eso, {{nombre}}. Tu experiencia nos importa
      muchísimo. ¿Me permites conectarte con el encargado para
      resolverlo personalmente?"
    │
    ├─► Acepta
    │       │
    │       ▼
    │   Bot: "¿Puedes contarme brevemente qué pasó?"
    │       │
    │       ▼
    │   n8n: POST bot-gateway /feedback
    │       payload: { canal, session_id, customer_name, message,
    │                  sentiment_score, timestamp, status: "pending" }
    │       │
    │       ▼
    │   Dashboard: tarjeta roja con badge de urgencia al dueño
    │   Bot: "Gracias por contármelo. El encargado te contactará
    │          en menos de 2 horas. 🙏"
    │
    └─► Rechaza
            │
            ▼
        n8n: POST bot-gateway /feedback (registro anónimo)
            payload: { canal, session_id, message, sentiment_score,
                       timestamp, anonymous: true, status: "noted" }
        Bot: "Entiendo. ¿Hay algo más en lo que te pueda ayudar?"

INVARIANTE: el feedback NUNCA se publica en Wuarike ni se sugiere
al cliente que escriba una reseña pública.
```

---

## 6. Arquitectura de Workflows n8n

### Workflow 1: mesero-core (orquestador principal)

```
Trigger: Webhook POST /webhook/chat
    Body: { session_id, restaurant_id, channel, message, customer_name? }
    │
    ├─ Node: Verificar JWT de sesión (HTTP → bot-gateway /auth/verify)
    ├─ Node: Cargar historial conversación (memoria de sesión en n8n)
    ├─ Node: Cargar La Carta (HTTP GET → bot-gateway /carta/:restaurant_id)
    │
    ├─ Node: Detectar intención (LLM call — modelo ligero)
    │         Output: { intent, confidence, entities }
    │         intenciones: consulta_carta | pedido | reserva | queja | saludo | otro
    │
    ├─ Router (Switch node):
    │   ├─► consulta_carta  → Node: LLM con carta inyectada → respuesta
    │   ├─► pedido          → Execute Workflow: mesero-pedidos
    │   ├─► reserva         → Execute Workflow: mesero-reservas
    │   ├─► queja           → Execute Workflow: mesero-feedback
    │   ├─► saludo          → Node: respuesta de bienvenida
    │   └─► otro            → Node: respuesta fallback + log gap
    │
    └─ Node: Guardar turno en historial de sesión
             Response: { message, session_id, intent }
```

### Workflow 2: mesero-pedidos
- Valida disponibilidad en tiempo real (HTTP GET /carta/:id/availability)
- Loop de conversación multi-turno (memoria de sesión)
- Construye objeto Order con items + variantes + total
- POST /pedidos → bot-gateway
- Notificación push al dashboard via webhook

### Workflow 3: mesero-reservas
- Valida fecha/hora contra slots y schedule del restaurante
- POST /reservas → bot-gateway
- Send email/WhatsApp confirmación (SMTP node o Twilio node en n8n)

### Workflow 4: mesero-feedback
- Registra objeto Feedback (privado, nunca público)
- Activa alerta en dashboard via POST /webhooks/feedback-alert
- Si cliente acepta contacto: incluye datos de contacto en payload
- Si anónimo: registra igualmente con anonymous: true

---

## 7. UX Dashboard — Especificaciones Móvil-First

### Principios de diseño
- **Ultra-simple:** el dueño del restaurante no es técnico. Cada pantalla tiene UNA acción primaria.
- **Información urgente arriba:** feedback sin resolver y pedidos activos siempre visibles.
- **Hereda Wuarike:** misma paleta de colores, misma tipografía (Poppins).
- **Mobile-first:** diseñado para pantallas de 375px, funciona en desktop sin cambios disruptivos.

### Paleta del Dashboard

| Token        | Valor       | Uso                                    |
|--------------|-------------|----------------------------------------|
| `primary`    | `#F26122`   | Botones CTA, FAB, highlights activos   |
| `danger`     | `#E8453C`   | Alertas feedback, estados de error     |
| `success`    | `#00BFA5`   | Pedido confirmado, reserva ok          |
| `warning`    | `#FFB800`   | Reserva pendiente, plato agotado       |
| `surface`    | `#FFFFFF`   | Cards y paneles                        |
| `background` | `#F7F8FA`   | Fondo de página                        |
| `text`       | `#1A1A1A`   | Texto principal (Poppins SemiBold)     |
| `muted`      | `#6B7280`   | Texto secundario (Poppins Regular)     |

### Navegación principal (sidebar colapsable en móvil)

```
🏠  Inicio          ← landing tras login
🍽️   Mi Carta        ← CRUD menú
📅  Reservas        ← calendario + lista
🛎️   Pedidos         ← tiempo real
💬  Feedback   🔴3  ← badge rojo si hay sin leer
🤖  Mi Bot          ← configurar personalidad
⚙️   Ajustes         ← datos del restaurante, integraciones
```

### Pantalla: Inicio

```
┌────────────────────────────────────────┐
│  Buenos días, El Rincón Criollo ☀️      │
│  Viernes 25 de abril                   │
├──────────────┬─────────────────────────┤
│  12          │  S/. 840                │
│  Pedidos hoy │  Ventas estimadas hoy   │
├──────────────┼─────────────────────────┤
│  3           │  ⚠️ 2                   │
│  Reservas    │  Feedback sin resolver  │
│  confirmadas │  → tap para ver         │
└──────────────┴─────────────────────────┘

Actividad reciente (scroll)
─────────────────────────────────────────
🛎️  Pedido #047 — Mesa 3 — S/. 56     14:32
📅  Reserva para 4 personas — 20:00   14:15
💬  Nuevo feedback recibido           13:55  ← rojo
🛎️  Pedido #046 — Para llevar — S/.32 13:40
✅  Reserva #012 confirmada           13:20
```

### Pantalla: Mi Carta

- Lista de categorías como acordeón expandible
- Cada plato muestra: nombre, precio, foto thumbnail, toggle ON/OFF de disponibilidad
- Toggle de disponibilidad cambia estado instantáneamente (PATCH /carta/:itemId sin formulario)
- Platos agotados aparecen con opacidad reducida y badge "Agotado"
- FAB naranja `+` abre wizard de 3 pasos para agregar plato:
  - **Paso 1:** Nombre + Precio + Categoría
  - **Paso 2:** Alérgenos (chips multi-select) + Info dietética (toggles)
  - **Paso 3:** Foto (opcional) + Nota del chef (opcional)

### Pantalla: Feedback Privado

```
┌────────────────────────────────────────┐
│  💬 Feedback Privado          2 nuevos │
├────────────────────────────────────────┤
│  🔴 Sin resolver                       │
│  ─────────────────────────────────────│
│  ┌──────────────────────────────────┐  │
│  │ WhatsApp · hace 45 min           │  │
│  │ "El ceviche llegó aguado y sin   │  │
│  │  limón, muy decepcionado..."     │  │
│  │ [Ver completo]  [✓ Resuelto]     │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │ Web Widget · hace 2h             │  │
│  │ "Esperé 40 min y nadie tomó mi   │  │
│  │  orden. Pésimo servicio."        │  │
│  │ [Ver completo]  [✓ Resuelto]     │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ✅ Resueltos (historial)              │
└────────────────────────────────────────┘
```

**Invariante de privacidad:** No existe ningún botón ni acción que publique este feedback en Wuarike.

### Pantalla: Configurar Bot

Formulario simple de 4 campos:
1. **Nombre del bot** (text input) — ej: "Carlitos"
2. **Tono** (selector: Amigable / Formal / Divertido)
3. **Mensaje de bienvenida** (textarea, máx 200 chars)
4. **Preview en vivo** — burbuja de chat que muestra el greeting con los cambios aplicados

---

## 8. Stack Tecnológico

### Dashboard (apps/dashboard)
- **Framework:** Next.js 14 App Router
- **Lenguaje:** TypeScript
- **UI:** shadcn/ui + Tailwind CSS
- **Auth:** next-auth (JWT, compatible con backend Wuarike)
- **Estado servidor:** React Query (TanStack Query)
- **Estado cliente:** Zustand (solo para UI state)
- **Tiempo real:** polling cada 30s para pedidos activos (WebSocket en v2)

### Bot Gateway (apps/bot-gateway)
- **Framework:** NestJS + TypeScript
- **ORM:** TypeORM + PostgreSQL (misma instancia que backend Wuarike)
- **Auth:** JWTs emitidos por el auth principal de Wuarike, validados en bot-gateway con un guard que verifica `role: business` y `audience: warike-business`. No hay un servicio de auth separado.
- **Validación:** class-validator + class-transformer

### Orquestador IA
- **n8n:** self-hosted en VPS existente (`38.242.252.183`)
- **LLM primario:** Claude claude-sonnet-4-6 (Anthropic) con prompt caching para la carta
- **LLM fallback:** GPT-4o-mini (detección de intención, modelo ligero)
- **Memoria de sesión:** n8n session variables (TTL 30 min por conversación)

### Monorepo
- **Turborepo** para build orchestration
- **pnpm workspaces** para gestión de dependencias

---

## 9. Integraciones con Wuarike Principal

| Integración | Dirección | Descripción |
|-------------|-----------|-------------|
| `wuarike_place_id` | warike_business → Wuarike Backend | El restaurante se asocia al lugar existente en Wuarike |
| Auth `role: business` | Wuarike Backend → warike_business | El JWT del negocio proviene del auth principal |
| La Carta → PlaceDetail | warike_business → Wuarike App | El menú del restaurante se puede mostrar en la ficha del lugar en la app móvil (v2) |
| Feedback → Reviews | **BLOQUEADO DELIBERADAMENTE** | El feedback privado NUNCA fluye al sistema de reseñas públicas |

---

## 10. Decisiones de Diseño y Rationale

| Decisión | Alternativa descartada | Razón |
|----------|------------------------|-------|
| n8n como orquestador IA | Microservicio custom | n8n permite iterar flujos sin deployer código; los workflows se versionan como JSON |
| Monorepo Turborepo | Repos separados | Tipos TypeScript compartidos entre dashboard y gateway eliminan duplicación |
| Feedback privado completamente aislado | Integrado con reviews | Un restaurante nunca usaría el bot si el feedback negativo se publicara automáticamente |
| Carta como JSON en DB | Archivos estáticos | Permite edición en tiempo real desde el dashboard y consulta eficiente por n8n |
| Polling 30s para pedidos activos | WebSocket desde v1 | Reduce complejidad de infraestructura; WebSocket se implementa en v2 si hay demanda |
