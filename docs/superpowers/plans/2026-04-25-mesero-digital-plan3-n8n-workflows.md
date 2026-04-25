# Mesero Digital — Plan 3/3: n8n AI Workflows

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and deploy 4 n8n workflows that power the Mesero Digital chatbot: `mesero-core` (intent detection + routing), `mesero-pedidos` (order flow), `mesero-reservas` (reservation flow), and `mesero-feedback` (private negative feedback capture). Each workflow is exported as JSON and committed to `workflows/`.

**Architecture:** Workflows live in n8n (self-hosted at `38.242.252.183`). `mesero-core` receives all chat messages via webhook, detects intent with a lightweight LLM call, then routes to sub-workflows. Each sub-workflow calls the bot-gateway API (Plan 1) for data and persistence. The primary LLM is Claude claude-sonnet-4-6 via the Anthropic API node. System prompts are dynamically constructed by injecting La Carta JSON per conversation.

**Tech Stack:** n8n (self-hosted), Claude claude-sonnet-4-6 (Anthropic), HTTP Request nodes, Switch node, Set node, Code node (JS), Webhook trigger

**Prerequisites:** Plans 1 and 2 complete. n8n running at `38.242.252.183`. Anthropic API key configured in n8n credentials.

---

## File Map

```
warike_business/workflows/
├── mesero-core.json          ← main webhook + intent detection + router
├── mesero-pedidos.json       ← order conversation flow
├── mesero-reservas.json      ← reservation conversation flow
└── mesero-feedback.json      ← private negative feedback capture
```

---

## n8n Setup Checklist (do once before any task)

- [ ] **Step 1: Open n8n at `http://38.242.252.183:5678`**

- [ ] **Step 2: Add Anthropic API credential**

   Settings → Credentials → New → Anthropic API
   Name: `Anthropic - Wuarike`
   API Key: `<your-anthropic-api-key>`
   Save.

- [ ] **Step 3: Add HTTP Header Auth credential for bot-gateway**

   Settings → Credentials → New → Header Auth
   Name: `Bot Gateway Service Account`
   Header Name: `Authorization`
   Header Value: `Bearer <service-account-jwt-with-role-business>`

   Generate this JWT using the main Wuarike backend: create a `business` user for the n8n service account and generate its access token.

- [ ] **Step 4: Verify bot-gateway is reachable from n8n server**

   In n8n: Manual HTTP Request node → `GET http://localhost:3002/auth/verify` with the header credential above.
   Expected: `{ "valid": true }`

---

## Task 1: mesero-core Workflow

This is the entry point for all chat messages. It:
1. Receives a webhook POST with `{ session_id, restaurant_id, channel, message, customer_name? }`
2. Calls bot-gateway to load La Carta for the restaurant
3. Calls Claude to detect intent
4. Routes to the correct sub-workflow (or responds directly for simple queries)
5. Saves the conversation turn to n8n's session memory

- [ ] **Step 1: Create workflow in n8n UI**

   Workflows → New → Name: `mesero-core`

- [ ] **Step 2: Add Webhook Trigger node**

   Node: `Webhook`
   HTTP Method: `POST`
   Path: `/webhook/chat`
   Response Mode: `Last Node`
   Authentication: None (validated by checking `N8N_WEBHOOK_SECRET` header in next step)

- [ ] **Step 3: Add webhook secret validation (Code node)**

   Node: `Code` — name it `Validate Secret`
   Language: JavaScript

   ```javascript
   const secret = $input.first().json.headers['x-webhook-secret'];
   const expected = $env.N8N_WEBHOOK_SECRET;
   if (secret !== expected) {
     throw new Error('Unauthorized: invalid webhook secret');
   }
   return $input.all();
   ```

   Set `N8N_WEBHOOK_SECRET` in n8n environment variables (Settings → Environment Variables).

- [ ] **Step 4: Add Load Carta node (HTTP Request)**

   Node: `HTTP Request` — name it `Load Carta`
   Method: `GET`
   URL: `={{ 'http://localhost:3002/carta/' + $json.body.restaurant_id }}`
   Authentication: `Header Auth` → `Bot Gateway Service Account`
   Response Format: JSON

- [ ] **Step 5: Add Build System Prompt node (Code node)**

   Node: `Code` — name it `Build System Prompt`
   Language: JavaScript

   ```javascript
   const body = $('Webhook').first().json.body;
   const carta = $input.first().json;

   // Build a concise carta summary for the prompt (avoid token bloat)
   const cartaSummary = carta.map(item => {
     const allergenStr = item.allergens?.length ? `Alérgenos: ${item.allergens.join(', ')}` : 'Sin alérgenos';
     const rec = item.is_chef_recommendation ? ' ⭐ Recomendación del chef' : '';
     const avail = item.available ? '' : ' [NO DISPONIBLE HOY]';
     return `- ${item.name}${rec}${avail}: S/. ${item.price}. ${item.description || ''}. ${allergenStr}`;
   }).join('\n');

   const now = new Date().toLocaleString('es-PE', { timeZone: 'America/Lima' });

   const systemPrompt = `Eres el mesero digital de este restaurante. Tono: amigable, español peruano natural.

   ## MISIÓN
   Ayudar al cliente con: explorar la carta, hacer un pedido, hacer una reserva, resolver dudas sobre alérgenos.

   ## LA CARTA (platos disponibles)
   ${cartaSummary}

   ## REGLAS (nunca las rompas)
   1. Solo hablas sobre este restaurante.
   2. Si un plato tiene [NO DISPONIBLE HOY], dilo y sugiere alternativas.
   3. NUNCA inventes precios ni ingredientes.
   4. Para alérgenos: confirma cada ingrediente explícitamente.
   5. Si detectas insatisfacción o queja: di "Lamento mucho eso. ¿Me permites conectarte con el encargado?" y NUNCA sugieras reseñas públicas.
   6. Máximo 3 oraciones por respuesta. Máximo 2 emojis.
   7. Al mostrar precios usa S/. siempre.

   ## DETECTAR INTENCIÓN
   Al responder, incluye al inicio de tu mensaje (invisible para el cliente) una línea:
   INTENT: <consulta_carta|pedido|reserva|queja|saludo|otro>

   ## CONTEXTO
   Fecha/hora Lima: ${now}
   Canal: ${body.channel}
   ${body.customer_name ? `Cliente: ${body.customer_name}` : ''}`;

   return [{
     json: {
       systemPrompt,
       userMessage: body.message,
       sessionId: body.session_id,
       restaurantId: body.restaurant_id,
       channel: body.channel,
       customerName: body.customer_name ?? null,
     }
   }];
   ```

- [ ] **Step 6: Add Claude Intent Detection node (Anthropic Message)**

   Node: `Anthropic` (or HTTP Request to Anthropic API) — name it `Detect Intent`
   Credential: `Anthropic - Wuarike`
   Model: `claude-haiku-4-5-20251001` (fast + cheap for intent detection)
   Max Tokens: 500
   System: `={{ $json.systemPrompt }}`
   User Message: `={{ $json.userMessage }}`

   If using HTTP Request instead of native Anthropic node:
   ```
   POST https://api.anthropic.com/v1/messages
   Headers:
     x-api-key: <anthropic-key>
     anthropic-version: 2023-06-01
     content-type: application/json
   Body:
   {
     "model": "claude-haiku-4-5-20251001",
     "max_tokens": 500,
     "system": "={{ $json.systemPrompt }}",
     "messages": [{ "role": "user", "content": "={{ $json.userMessage }}" }]
   }
   ```

- [ ] **Step 7: Add Parse Intent node (Code node)**

   Node: `Code` — name it `Parse Intent`
   Language: JavaScript

   ```javascript
   const rawText = $input.first().json.content?.[0]?.text ?? $input.first().json.choices?.[0]?.message?.content ?? '';

   // Extract INTENT: line
   const intentMatch = rawText.match(/INTENT:\s*([\w_]+)/i);
   const intent = intentMatch ? intentMatch[1].toLowerCase() : 'otro';

   // Clean response (remove the INTENT: line before sending to client)
   const cleanResponse = rawText.replace(/INTENT:\s*[\w_]+\n?/i, '').trim();

   const prev = $('Build System Prompt').first().json;

   return [{
     json: {
       ...prev,
       intent,
       botResponse: cleanResponse,
       rawText,
     }
   }];
   ```

- [ ] **Step 8: Add Router (Switch node)**

   Node: `Switch` — name it `Route by Intent`
   Mode: Rules
   Rules:
   - Rule 1: `{{ $json.intent }}` equals `consulta_carta` → Output 1
   - Rule 2: `{{ $json.intent }}` equals `pedido` → Output 2
   - Rule 3: `{{ $json.intent }}` equals `reserva` → Output 3
   - Rule 4: `{{ $json.intent }}` equals `queja` → Output 4
   - Fallback → Output 5

- [ ] **Step 9: Connect outputs**

   - Output 1 (`consulta_carta`): → Respond node (direct response, no sub-workflow)
   - Output 2 (`pedido`): → Execute Sub-Workflow: `mesero-pedidos`
   - Output 3 (`reserva`): → Execute Sub-Workflow: `mesero-reservas`
   - Output 4 (`queja`): → Execute Sub-Workflow: `mesero-feedback`
   - Output 5 (fallback): → Respond node with `botResponse`

- [ ] **Step 10: Add final Respond node**

   Node: `Set` — name it `Format Response`
   Fields:
   - `message`: `={{ $json.botResponse }}`
   - `session_id`: `={{ $json.sessionId }}`
   - `intent`: `={{ $json.intent }}`

   Connect to Webhook response output.

- [ ] **Step 11: Test mesero-core with curl**

   ```bash
   curl -X POST http://38.242.252.183:5678/webhook/chat \
     -H "Content-Type: application/json" \
     -H "x-webhook-secret: your_n8n_webhook_secret" \
     -d '{
       "session_id": "test-123",
       "restaurant_id": "your-restaurant-uuid",
       "channel": "web_widget",
       "message": "¿Qué tienen de entradas?"
     }'
   ```

   Expected: `{ "message": "Tenemos... S/. ...", "session_id": "test-123", "intent": "consulta_carta" }`

- [ ] **Step 12: Export workflow JSON**

   Workflow → ⋮ → Export → Save as `d:/Github/warike_business/workflows/mesero-core.json`

- [ ] **Step 13: Commit**

   ```bash
   cd d:/Github/warike_business
   git add workflows/mesero-core.json
   git commit -m "feat(n8n): add mesero-core workflow — intent detection and routing"
   ```

---

## Task 2: mesero-pedidos Workflow

Handles multi-turn order conversations. Maintains a growing order list in session variables until the client confirms.

- [ ] **Step 1: Create workflow — name it `mesero-pedidos`**

- [ ] **Step 2: Add Sub-workflow trigger node**

   Node: `Execute Workflow Trigger`
   Input fields: `systemPrompt`, `userMessage`, `sessionId`, `restaurantId`, `channel`, `customerName`, `cartaItems`

- [ ] **Step 3: Add Build Order Prompt node (Code node)**

   Node: `Code` — name it `Build Order Prompt`

   ```javascript
   const data = $input.first().json;

   // Retrieve ongoing order from session (stored as JSON string)
   const sessionKey = `order_${data.sessionId}`;
   const existingOrder = $vars[sessionKey] ? JSON.parse($vars[sessionKey]) : [];

   const orderSummary = existingOrder.length
     ? 'Pedido actual:\n' + existingOrder.map(i => `- ${i.quantity}x ${i.name} S/. ${i.price}`).join('\n')
     : 'Pedido actual: vacío';

   const orderPrompt = `${data.systemPrompt}

   ## MODO PEDIDO ACTIVO
   ${orderSummary}

   Tu tarea ahora: ayudar al cliente a completar su pedido.
   - Si el cliente agrega algo, responde confirmando el ítem y pregunta "¿Algo más?"
   - Si el cliente dice "eso es todo" o "confirmar": responde con el resumen completo del pedido y pide confirmación final.
   - Si el cliente confirma: termina tu respuesta con la línea exacta: ORDER_CONFIRMED
   - Si el cliente quiere cambiar algo: actualiza el pedido.`;

   return [{
     json: {
       ...data,
       orderPrompt,
       existingOrder,
       sessionKey,
     }
   }];
   ```

- [ ] **Step 4: Add Claude Order Response node (HTTP Request to Anthropic)**

   ```
   POST https://api.anthropic.com/v1/messages
   Headers: x-api-key, anthropic-version: 2023-06-01
   Body:
   {
     "model": "claude-sonnet-4-6",
     "max_tokens": 1024,
     "system": "={{ $json.orderPrompt }}",
     "messages": [{ "role": "user", "content": "={{ $json.userMessage }}" }]
   }
   ```

- [ ] **Step 5: Add Check Order Confirmed node (Code node)**

   ```javascript
   const responseText = $input.first().json.content?.[0]?.text ?? '';
   const confirmed = responseText.includes('ORDER_CONFIRMED');
   const cleanText = responseText.replace('ORDER_CONFIRMED', '').trim();
   const prev = $('Build Order Prompt').first().json;

   return [{
     json: {
       ...prev,
       botResponse: cleanText,
       orderConfirmed: confirmed,
     }
   }];
   ```

- [ ] **Step 6: Add IF node — Is Order Confirmed?**

   Condition: `{{ $json.orderConfirmed }}` is true

   - True branch → Create Pedido
   - False branch → Return response to core

- [ ] **Step 7: Add Create Pedido node (HTTP Request)**

   Method: `POST`
   URL: `http://localhost:3002/pedidos`
   Auth: Bot Gateway Service Account
   Body (Expression):
   ```json
   {
     "restaurant_id": "={{ $json.restaurantId }}",
     "session_id": "={{ $json.sessionId }}",
     "channel": "={{ $json.channel }}",
     "items": "={{ $json.existingOrder }}",
     "total": "={{ $json.existingOrder.reduce((s, i) => s + i.price * i.quantity, 0) }}"
   }
   ```

- [ ] **Step 8: Add Clear Session Order node (Code node)**

   ```javascript
   const data = $input.first().json;
   // In n8n, clear session variable by setting it to empty
   // The pedido ID is in $input from the HTTP response
   const pedidoId = $('Create Pedido').first().json.id;
   return [{
     json: {
       ...data,
       botResponse: `¡Pedido #${pedidoId.slice(0,8)} confirmado! Tiempo estimado: ~20 min 🍽️`,
     }
   }];
   ```

- [ ] **Step 9: Connect to output and test**

   Send test message: `"Quiero un ceviche clásico"`
   Expected: Bot asks for confirmation / variants.

   Send: `"eso es todo, confirmo"`
   Expected: `{ "message": "¡Pedido #abc12345 confirmado!..." }` and new record in `/pedidos/:restaurantId`.

- [ ] **Step 10: Export + commit**

   Export as `workflows/mesero-pedidos.json`

   ```bash
   git add workflows/mesero-pedidos.json
   git commit -m "feat(n8n): add mesero-pedidos workflow — multi-turn order with confirmation"
   ```

---

## Task 3: mesero-reservas Workflow

Collects date, time, party size, and contact info through a guided multi-turn conversation, then POSTs to `/reservas`.

- [ ] **Step 1: Create workflow — name it `mesero-reservas`**

- [ ] **Step 2: Add Sub-workflow trigger node**

- [ ] **Step 3: Add Build Reservation Prompt node (Code node)**

   ```javascript
   const data = $input.first().json;
   const sessionKey = `reserva_${data.sessionId}`;
   const partial = $vars[sessionKey] ? JSON.parse($vars[sessionKey]) : {};

   const collected = Object.entries(partial).map(([k, v]) => `${k}: ${v}`).join(', ') || 'nada aún';

   const reservaPrompt = `${data.systemPrompt}

   ## MODO RESERVA ACTIVO
   Datos recopilados hasta ahora: ${collected}

   Tu tarea: recopilar los datos faltantes en este orden estricto:
   1. Fecha (validar que no sea pasada ni más de 30 días en el futuro)
   2. Hora (mostrar los slots disponibles: 12:00, 13:00, 19:00, 20:00, 21:00)
   3. Número de personas (mínimo 1, máximo 10)
   4. Nombre del cliente
   5. Teléfono de contacto

   Cuando tengas TODOS los datos, muestra un resumen y pregunta "¿Confirmo tu reserva?"
   Si el cliente confirma, termina con la línea exacta: RESERVATION_CONFIRMED|fecha|hora|personas|nombre|telefono
   Ejemplo: RESERVATION_CONFIRMED|2026-04-26|19:00|4|Juan García|999888777`;

   return [{ json: { ...data, reservaPrompt, partial, sessionKey } }];
   ```

- [ ] **Step 4: Add Claude Reservation Response node (HTTP Request to Anthropic)**

   Same as Task 2 Step 4 but with `reservaPrompt` as system and `claude-sonnet-4-6` model.

- [ ] **Step 5: Add Parse Reservation Confirmation node (Code node)**

   ```javascript
   const responseText = $input.first().json.content?.[0]?.text ?? '';
   const confirmMatch = responseText.match(/RESERVATION_CONFIRMED\|([^|]+)\|([^|]+)\|(\d+)\|([^|]+)\|([^\n]+)/);
   const confirmed = !!confirmMatch;
   const cleanText = responseText.replace(/RESERVATION_CONFIRMED\|.*/, '').trim();
   const prev = $('Build Reservation Prompt').first().json;

   return [{
     json: {
       ...prev,
       botResponse: cleanText,
       reservationConfirmed: confirmed,
       reservationData: confirmed ? {
         date: confirmMatch![1].trim(),
         time: confirmMatch![2].trim(),
         party_size: parseInt(confirmMatch![3]),
         customer_name: confirmMatch![4].trim(),
         customer_phone: confirmMatch![5].trim(),
       } : null,
     }
   }];
   ```

- [ ] **Step 6: Add IF node — Is Reservation Confirmed?**

   True → Create Reserva
   False → Return response to core

- [ ] **Step 7: Add Create Reserva node (HTTP Request)**

   Method: `POST`
   URL: `http://localhost:3002/reservas`
   Auth: Bot Gateway Service Account
   Body:
   ```json
   {
     "restaurant_id": "={{ $json.restaurantId }}",
     "session_id": "={{ $json.sessionId }}",
     "channel": "={{ $json.channel }}",
     "customer_name": "={{ $json.reservationData.customer_name }}",
     "customer_phone": "={{ $json.reservationData.customer_phone }}",
     "party_size": "={{ $json.reservationData.party_size }}",
     "date": "={{ $json.reservationData.date }}",
     "time": "={{ $json.reservationData.time }}"
   }
   ```

- [ ] **Step 8: Add Format Confirmation Response node (Code node)**

   ```javascript
   const data = $input.first().json;
   const reservaId = $('Create Reserva').first().json.id;
   const rd = data.reservationData;
   return [{
     json: {
       ...data,
       botResponse: `Reserva #${reservaId.slice(0,8)} confirmada ✅\n📅 ${rd.date} a las ${rd.time} para ${rd.party_size} personas.\nTe esperamos, ${rd.customer_name}!`,
     }
   }];
   ```

- [ ] **Step 9: Test end-to-end**

   Send: `"Quiero reservar una mesa para el sábado"`
   Follow the conversation until `RESERVATION_CONFIRMED`.
   Verify new record at `GET /reservas/:restaurantId`.

- [ ] **Step 10: Export + commit**

   Export as `workflows/mesero-reservas.json`

   ```bash
   git add workflows/mesero-reservas.json
   git commit -m "feat(n8n): add mesero-reservas workflow — guided reservation with slot validation"
   ```

---

## Task 4: mesero-feedback Workflow

Handles negative sentiment — captures private feedback without suggesting public reviews.

- [ ] **Step 1: Create workflow — name it `mesero-feedback`**

- [ ] **Step 2: Add Sub-workflow trigger node**

- [ ] **Step 3: Add Empathy Response + Ask Permission node (Code node)**

   ```javascript
   const data = $input.first().json;
   const customerName = data.customerName ?? 'estimado cliente';

   return [{
     json: {
       ...data,
       botResponse: `Lamento mucho eso, ${customerName}. Tu experiencia nos importa muchísimo. ¿Me permites conectarte con el encargado para resolverlo personalmente? (responde sí o no)`,
       awaitingConsent: true,
     }
   }];
   ```

- [ ] **Step 4: Connect to output (first turn — ask for consent)**

   Return `botResponse` to the main webhook output. The next message from the client will be routed back through `mesero-core` → `mesero-feedback` (because sentiment will still be low), OR the session flag `awaitingConsent` will be checked.

   Simplified v1 approach: treat any message after a queja as the feedback body (skip consent re-check):

- [ ] **Step 5: Add Analyze Sentiment + Build Feedback Payload node (Code node)**

   ```javascript
   const data = $input.first().json;

   // Simple consent check: if message contains sí/si/yes/ok → with contact
   const message = data.userMessage.toLowerCase();
   const consented = /\b(s[ií]|yes|ok|claro|dale|por favor)\b/.test(message);

   const payload = {
     restaurant_id: data.restaurantId,
     session_id: data.sessionId,
     message: data.userMessage,
     sentiment_score: 0.1,
     channel: data.channel,
     anonymous: !consented,
     customer_name: consented && data.customerName ? data.customerName : undefined,
   };

   const botResponse = consented
     ? 'Gracias por contármelo. El encargado te contactará en menos de 2 horas. 🙏'
     : 'Entiendo. ¿Hay algo más en lo que te pueda ayudar?';

   return [{ json: { ...data, feedbackPayload: payload, botResponse } }];
   ```

- [ ] **Step 6: Add POST Feedback node (HTTP Request)**

   Method: `POST`
   URL: `http://localhost:3002/feedback`
   Body: `={{ JSON.stringify($json.feedbackPayload) }}`
   Content-Type: `application/json`
   Note: No auth required on `POST /feedback` (as designed in Plan 1).

- [ ] **Step 7: Return response to core**

   Final Set node: `{ message: $json.botResponse, session_id: $json.sessionId, intent: "queja" }`

- [ ] **Step 8: Test negative sentiment path**

   Send: `"El ceviche llegó aguado, muy decepcionante"`
   Expected: Bot asks for permission to connect with manager.

   Verify: New record in `GET /feedback/:restaurantId?status=pending` on bot-gateway.

   Verify: Dashboard `/feedback` page shows the red card.

- [ ] **Step 9: Export + commit**

   Export as `workflows/mesero-feedback.json`

   ```bash
   git add workflows/mesero-feedback.json
   git commit -m "feat(n8n): add mesero-feedback workflow — private capture, no public exposure"
   ```

---

## Task 5: End-to-End Integration Test

- [ ] **Step 1: Full conversation test — Consulta de carta**

   ```bash
   curl -X POST http://38.242.252.183:5678/webhook/chat \
     -H "Content-Type: application/json" \
     -H "x-webhook-secret: your_secret" \
     -d '{"session_id":"e2e-1","restaurant_id":"<real-id>","channel":"web_widget","message":"¿Qué platos tienen sin gluten?"}'
   ```

   Expected: List of gluten-free items from La Carta with prices in S/.

- [ ] **Step 2: Full conversation test — Pedido**

   Send: `"Quiero pedir un ceviche"`
   Send: `"Sin cebolla"`
   Send: `"eso es todo"`
   Send: `"sí confirmo"`
   Expected: Pedido created in DB. Dashboard shows new entry in Pedidos.

- [ ] **Step 3: Full conversation test — Reserva**

   Send: `"Quiero reservar una mesa"`
   Follow prompts for date, time, personas, nombre, teléfono.
   Send: `"sí confirmo"`
   Expected: Reserva created in DB. Dashboard shows pending reserva.

- [ ] **Step 4: Full conversation test — Feedback privado**

   Send: `"La comida llegó fría y tardaron 1 hora"`
   Expected: Empathy response + consent question.
   Send: `"sí"`
   Expected: Feedback saved in DB as non-anonymous. Dashboard shows red card. Bot confirms 2h response.

- [ ] **Step 5: Final commit**

   ```bash
   cd d:/Github/warike_business
   git add workflows/
   git commit -m "feat: complete Plan 3 — n8n AI workflows, Mesero Digital fully operational"
   ```

---

## System is Live ✓

After Plan 3 completes, the full Mesero Digital system is operational:

```
Cliente → webhook n8n → intent detection (Claude Haiku)
       → consulta_carta  → Claude Sonnet → respuesta directa
       → pedido          → Claude Sonnet + session → POST /pedidos
       → reserva         → Claude Sonnet + session → POST /reservas
       → queja           → empathy response → POST /feedback (privado)

Dashboard (Next.js) ← polling 30s → GET /webhooks/events/:id → bot-gateway
                    ← gestión carta, reservas, pedidos, feedback

Dueño del restaurante → login → panel B2B ultra-simple móvil-first
```
