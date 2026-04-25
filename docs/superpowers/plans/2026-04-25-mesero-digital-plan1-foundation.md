# Mesero Digital — Plan 1/3: Foundation (Monorepo + Types + Bot-Gateway)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the `warike_business` Turborepo monorepo with shared TypeScript types and a fully-functional NestJS bot-gateway API that n8n and the Next.js dashboard can call to manage La Carta, Reservas, Pedidos, and Feedback Privado.

**Architecture:** Monorepo at `d:/Github/warike_business/`. `packages/types` exports shared TS interfaces used by both `apps/bot-gateway` and `apps/dashboard`. The bot-gateway is a NestJS app with a dedicated PostgreSQL database (`warike_business`) on the same server as WARIKE_BACKEND, using JWT tokens issued by the main Wuarike auth service (validates `role: business`).

**Tech Stack:** Node.js 20, pnpm 9, Turborepo 2, NestJS 10, TypeORM 0.3, PostgreSQL 15, Jest 29, class-validator 0.14, @nestjs/jwt 10, @nestjs/passport 10

---

> This is Plan 1 of 3. Plan 2 covers the Next.js dashboard. Plan 3 covers the n8n AI workflows.

---

## File Map

```
d:/Github/warike_business/
├── package.json
├── pnpm-workspace.yaml
├── turbo.json
├── .env.example
├── .gitignore
│
├── packages/types/
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts
│       ├── restaurant.types.ts
│       ├── carta.types.ts
│       ├── reserva.types.ts
│       ├── pedido.types.ts
│       └── feedback.types.ts
│
└── apps/bot-gateway/
    ├── package.json
    ├── tsconfig.json
    ├── nest-cli.json
    ├── src/data-source.ts
    ├── src/main.ts
    ├── src/app.module.ts
    ├── src/auth/
    │   ├── auth.module.ts
    │   ├── jwt-business.guard.ts
    │   ├── jwt-business.guard.spec.ts
    │   ├── jwt-business.strategy.ts
    │   └── auth.controller.ts
    ├── src/restaurants/entities/restaurant.entity.ts
    ├── src/carta/
    │   ├── carta.module.ts
    │   ├── carta.controller.ts
    │   ├── carta.service.ts
    │   ├── carta.service.spec.ts
    │   ├── dto/create-carta-item.dto.ts
    │   ├── dto/update-carta-item.dto.ts
    │   └── entities/
    │       ├── carta-category.entity.ts
    │       └── carta-item.entity.ts
    ├── src/reservas/
    │   ├── reservas.module.ts
    │   ├── reservas.controller.ts
    │   ├── reservas.service.ts
    │   ├── reservas.service.spec.ts
    │   ├── dto/create-reserva.dto.ts
    │   └── entities/reserva.entity.ts
    ├── src/pedidos/
    │   ├── pedidos.module.ts
    │   ├── pedidos.controller.ts
    │   ├── pedidos.service.ts
    │   ├── dto/create-pedido.dto.ts
    │   └── entities/pedido.entity.ts
    ├── src/feedback/
    │   ├── feedback.module.ts
    │   ├── feedback.controller.ts
    │   ├── feedback.service.ts
    │   ├── feedback.service.spec.ts
    │   ├── dto/create-feedback.dto.ts
    │   └── entities/feedback.entity.ts
    └── src/webhooks/
        ├── webhooks.module.ts
        ├── webhooks.controller.ts
        └── webhooks.service.ts
```

---

## Task 1: Init Monorepo

**Files:**
- Create: `d:/Github/warike_business/package.json`
- Create: `d:/Github/warike_business/pnpm-workspace.yaml`
- Create: `d:/Github/warike_business/turbo.json`
- Create: `d:/Github/warike_business/.env.example`
- Create: `d:/Github/warike_business/.gitignore`

- [ ] **Step 1: Create root directory and init git**

```bash
mkdir d:/Github/warike_business
cd d:/Github/warike_business
git init
```

- [ ] **Step 2: Create `package.json`**

```json
{
  "name": "warike-business",
  "version": "0.0.1",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "test": "turbo run test",
    "lint": "turbo run lint"
  },
  "devDependencies": {
    "turbo": "^2.0.0",
    "typescript": "^5.4.0"
  }
}
```

- [ ] **Step 3: Create `pnpm-workspace.yaml`**

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

- [ ] **Step 4: Create `turbo.json`**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["^build"]
    },
    "lint": {}
  }
}
```

- [ ] **Step 5: Create `.env.example`**

```
# PostgreSQL — same server as WARIKE_BACKEND, separate database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password_here
DB_DATABASE=warike_business

# JWT — same SECRET as WARIKE_BACKEND (tokens issued by main auth service)
JWT_SECRET=your_jwt_secret_here
JWT_AUDIENCE=warike-business

# Bot Gateway port (WARIKE_BACKEND uses 3001)
BOT_GATEWAY_PORT=3002

# n8n webhook secret (used to authenticate calls from n8n)
N8N_WEBHOOK_SECRET=your_n8n_webhook_secret_here
```

- [ ] **Step 6: Create `.gitignore`**

```
node_modules/
dist/
.turbo/
*.env
!*.env.example
.env.local
```

- [ ] **Step 7: Install root deps**

```bash
pnpm install
```

Expected: `node_modules/` created at root with `turbo` installed.

- [ ] **Step 8: Commit**

```bash
git add .
git commit -m "chore: init warike_business monorepo with Turborepo + pnpm workspaces"
```

---

## Task 2: packages/types

**Files:**
- Create: `packages/types/package.json`
- Create: `packages/types/tsconfig.json`
- Create: `packages/types/src/restaurant.types.ts`
- Create: `packages/types/src/carta.types.ts`
- Create: `packages/types/src/reserva.types.ts`
- Create: `packages/types/src/pedido.types.ts`
- Create: `packages/types/src/feedback.types.ts`
- Create: `packages/types/src/index.ts`

- [ ] **Step 1: Create `packages/types/package.json`**

```json
{
  "name": "@warike-business/types",
  "version": "0.0.1",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc"
  },
  "devDependencies": {
    "typescript": "^5.4.0"
  }
}
```

- [ ] **Step 2: Create `packages/types/tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "./dist",
    "declaration": true
  },
  "include": ["src/**/*"]
}
```

- [ ] **Step 3: Create `packages/types/src/restaurant.types.ts`**

```typescript
export type BotTone = 'amigable' | 'formal' | 'divertido';
export type Currency = 'PEN' | 'USD';
export type BotLanguage = 'es-PE' | 'es' | 'en';

export interface BotPersona {
  name: string;
  tone: BotTone;
  language: BotLanguage;
  greeting: string;
}

export interface DaySchedule {
  open: string;
  close: string;
  closed?: boolean;
}

export interface WeekSchedule {
  monday: DaySchedule;
  tuesday: DaySchedule;
  wednesday: DaySchedule;
  thursday: DaySchedule;
  friday: DaySchedule;
  saturday: DaySchedule;
  sunday: DaySchedule;
}

export interface ReservationConfig {
  enabled: boolean;
  max_party_size: number;
  min_advance_hours: number;
  max_advance_days: number;
  slots: string[];
}
```

- [ ] **Step 4: Create `packages/types/src/carta.types.ts`**

```typescript
export interface DietaryInfo {
  is_vegetarian: boolean;
  is_vegan: boolean;
  is_gluten_free: boolean;
  is_lactose_free: boolean;
  is_spicy: boolean;
  spice_level: 0 | 1 | 2 | 3;
}

export interface PairingInfo {
  drinks: string[];
  pairing_note?: string;
}

export interface ItemVariant {
  id: string;
  name: string;
  price_delta: number;
}

export interface CartaCategory {
  id: string;
  name: string;
  emoji: string;
  sort_order: number;
  available: boolean;
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
  allergens: string[];
  dietary: DietaryInfo;
  pairing: PairingInfo;
  variants: ItemVariant[];
  combo_ids: string[];
}

export interface Combo {
  id: string;
  name: string;
  item_ids: string[];
  price: number;
  original_price: number;
  available_from: string;
  available_until: string;
}
```

- [ ] **Step 5: Create `packages/types/src/reserva.types.ts`**

```typescript
export type ReservaStatus = 'pending' | 'confirmed' | 'cancelled';

export interface CreateReservaPayload {
  restaurant_id: string;
  customer_name: string;
  customer_phone: string;
  party_size: number;
  date: string;
  time: string;
  session_id: string;
  channel: string;
}

export interface Reserva extends CreateReservaPayload {
  id: string;
  status: ReservaStatus;
  created_at: string;
}
```

- [ ] **Step 6: Create `packages/types/src/pedido.types.ts`**

```typescript
export type PedidoStatus = 'pending' | 'confirmed' | 'preparing' | 'ready' | 'cancelled';
export type Channel = 'whatsapp' | 'web_widget' | 'wuarike_app';

export interface PedidoLineItem {
  item_id: string;
  variant_id?: string;
  quantity: number;
  unit_price: number;
  item_name: string;
}

export interface CreatePedidoPayload {
  restaurant_id: string;
  session_id: string;
  channel: Channel;
  items: PedidoLineItem[];
  total: number;
}

export interface Pedido extends CreatePedidoPayload {
  id: string;
  status: PedidoStatus;
  created_at: string;
}
```

- [ ] **Step 7: Create `packages/types/src/feedback.types.ts`**

```typescript
export type FeedbackStatus = 'pending' | 'noted' | 'resolved';

export interface CreateFeedbackPayload {
  restaurant_id: string;
  session_id?: string;
  message: string;
  sentiment_score: number;
  channel: string;
  anonymous: boolean;
  customer_name?: string;
  customer_phone?: string;
}

export interface Feedback extends CreateFeedbackPayload {
  id: string;
  status: FeedbackStatus;
  created_at: string;
}
```

- [ ] **Step 8: Create `packages/types/src/index.ts`**

```typescript
export * from './restaurant.types';
export * from './carta.types';
export * from './reserva.types';
export * from './pedido.types';
export * from './feedback.types';
```

- [ ] **Step 9: Install and build types package**

```bash
cd d:/Github/warike_business
pnpm install
cd packages/types && pnpm build
```

Expected: `packages/types/dist/` created with `.js` + `.d.ts` files. No TypeScript errors.

- [ ] **Step 10: Commit**

```bash
cd d:/Github/warike_business
git add packages/types/
git commit -m "feat(types): add shared TypeScript interfaces for all domain entities"
```

---

## Task 3: bot-gateway NestJS Scaffold

**Files:**
- Create: `apps/bot-gateway/` (NestJS project)
- Modify: `apps/bot-gateway/src/main.ts`
- Modify: `apps/bot-gateway/src/app.module.ts`
- Create: `apps/bot-gateway/src/data-source.ts`

- [ ] **Step 1: Scaffold NestJS app**

```bash
cd d:/Github/warike_business/apps
npx @nestjs/cli new bot-gateway --package-manager pnpm --skip-git
```

When prompted select `pnpm`. Expected: `apps/bot-gateway/` created with `src/app.module.ts`, `src/main.ts`, etc.

- [ ] **Step 2: Install bot-gateway dependencies**

```bash
cd apps/bot-gateway
pnpm add @nestjs/typeorm typeorm pg @nestjs/jwt @nestjs/passport passport passport-jwt class-validator class-transformer @nestjs/config @nestjs/mapped-types
pnpm add -D @types/passport-jwt @types/pg
```

- [ ] **Step 3: Add workspace types to `apps/bot-gateway/package.json`**

In the `dependencies` section add:
```json
"@warike-business/types": "workspace:*"
```

Then run:
```bash
cd d:/Github/warike_business
pnpm install
```

Expected: `@warike-business/types` resolves from `packages/types`.

- [ ] **Step 4: Replace `apps/bot-gateway/src/main.ts`**

```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors();
  const port = process.env.BOT_GATEWAY_PORT ?? 3002;
  await app.listen(port);
  console.log(`Bot Gateway running on port ${port}`);
}
bootstrap();
```

- [ ] **Step 5: Replace `apps/bot-gateway/src/app.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USERNAME', 'postgres'),
        password: config.get('DB_PASSWORD'),
        database: config.get('DB_DATABASE', 'warike_business'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: false,
        migrations: [__dirname + '/migrations/*{.ts,.js}'],
        migrationsRun: true,
      }),
    }),
  ],
})
export class AppModule {}
```

- [ ] **Step 6: Create `apps/bot-gateway/src/data-source.ts`** (for TypeORM CLI)

```typescript
import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';
dotenv.config();

export default new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? 5432),
  username: process.env.DB_USERNAME ?? 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE ?? 'warike_business',
  entities: ['src/**/*.entity.ts'],
  migrations: ['src/migrations/*.ts'],
});
```

- [ ] **Step 7: Add migration scripts to `apps/bot-gateway/package.json` scripts section**

```json
"typeorm": "typeorm-ts-node-commonjs",
"migration:generate": "pnpm typeorm migration:generate -d src/data-source.ts",
"migration:run": "pnpm typeorm migration:run -d src/data-source.ts"
```

- [ ] **Step 8: Create `.env` in bot-gateway (gitignored)**

```bash
cp d:/Github/warike_business/.env.example d:/Github/warike_business/apps/bot-gateway/.env
```

Edit `apps/bot-gateway/.env` with real values from WARIKE_BACKEND's `.env` (same `JWT_SECRET`, same DB host/user/password, database = `warike_business`).

- [ ] **Step 9: Create the `warike_business` database**

```bash
psql -U postgres -h localhost -c "CREATE DATABASE warike_business;"
```

Expected: `CREATE DATABASE`

- [ ] **Step 10: Verify NestJS starts and connects to DB**

```bash
cd apps/bot-gateway && pnpm run start:dev
```

Expected: `Bot Gateway running on port 3002` with no TypeORM connection errors.

- [ ] **Step 11: Commit**

```bash
cd d:/Github/warike_business
git add apps/bot-gateway/
git commit -m "feat(bot-gateway): scaffold NestJS with TypeORM, ConfigModule, global ValidationPipe"
```

---

## Task 4: Auth Guard (JWT Business)

**Files:**
- Create: `apps/bot-gateway/src/auth/jwt-business.strategy.ts`
- Create: `apps/bot-gateway/src/auth/jwt-business.guard.ts`
- Create: `apps/bot-gateway/src/auth/jwt-business.guard.spec.ts`
- Create: `apps/bot-gateway/src/auth/auth.module.ts`
- Create: `apps/bot-gateway/src/auth/auth.controller.ts`

- [ ] **Step 1: Write failing test**

Create `apps/bot-gateway/src/auth/jwt-business.guard.spec.ts`:

```typescript
import { JwtBusinessGuard } from './jwt-business.guard';
import { Reflector } from '@nestjs/core';

describe('JwtBusinessGuard', () => {
  let guard: JwtBusinessGuard;

  beforeEach(() => {
    guard = new JwtBusinessGuard(new Reflector());
  });

  it('should be defined', () => {
    expect(guard).toBeDefined();
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd apps/bot-gateway
pnpm test -- --testPathPattern=jwt-business.guard
```

Expected: FAIL — `Cannot find module './jwt-business.guard'`

- [ ] **Step 3: Create `src/auth/jwt-business.strategy.ts`**

```typescript
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

export interface JwtBusinessPayload {
  sub: string;
  email: string;
  role: string;
  aud?: string;
}

@Injectable()
export class JwtBusinessStrategy extends PassportStrategy(Strategy, 'jwt-business') {
  constructor(config: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: config.get<string>('JWT_SECRET'),
      audience: config.get<string>('JWT_AUDIENCE', 'warike-business'),
    });
  }

  validate(payload: JwtBusinessPayload): JwtBusinessPayload {
    if (payload.role !== 'business' && payload.role !== 'admin') {
      throw new UnauthorizedException('Insufficient role: business or admin required');
    }
    return payload;
  }
}
```

- [ ] **Step 4: Create `src/auth/jwt-business.guard.ts`**

```typescript
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtBusinessGuard extends AuthGuard('jwt-business') {}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
pnpm test -- --testPathPattern=jwt-business.guard
```

Expected: PASS — `JwtBusinessGuard should be defined`

- [ ] **Step 6: Create `src/auth/auth.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { JwtBusinessStrategy } from './jwt-business.strategy';

@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('JWT_SECRET'),
      }),
    }),
  ],
  providers: [JwtBusinessStrategy],
  exports: [JwtModule, PassportModule],
})
export class AuthModule {}
```

- [ ] **Step 7: Create `src/auth/auth.controller.ts`** (verify endpoint for n8n)

```typescript
import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { JwtBusinessGuard } from './jwt-business.guard';
import { JwtBusinessPayload } from './jwt-business.strategy';

@Controller('auth')
export class AuthController {
  @Get('verify')
  @UseGuards(JwtBusinessGuard)
  verify(@Request() req: { user: JwtBusinessPayload }) {
    return { valid: true, user: req.user };
  }
}
```

- [ ] **Step 8: Register AuthModule and AuthController in `app.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { AuthController } from './auth/auth.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USERNAME', 'postgres'),
        password: config.get('DB_PASSWORD'),
        database: config.get('DB_DATABASE', 'warike_business'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: false,
        migrations: [__dirname + '/migrations/*{.ts,.js}'],
        migrationsRun: true,
      }),
    }),
    AuthModule,
  ],
  controllers: [AuthController],
})
export class AppModule {}
```

- [ ] **Step 9: Commit**

```bash
cd d:/Github/warike_business
git add apps/bot-gateway/src/auth/
git commit -m "feat(bot-gateway): add JWT business guard — validates role:business tokens"
```

---

## Task 5: Database Entities + Migration

**Files:**
- Create: `apps/bot-gateway/src/restaurants/entities/restaurant.entity.ts`
- Create: `apps/bot-gateway/src/carta/entities/carta-category.entity.ts`
- Create: `apps/bot-gateway/src/carta/entities/carta-item.entity.ts`
- Create: `apps/bot-gateway/src/reservas/entities/reserva.entity.ts`
- Create: `apps/bot-gateway/src/pedidos/entities/pedido.entity.ts`
- Create: `apps/bot-gateway/src/feedback/entities/feedback.entity.ts`

- [ ] **Step 1: Create `src/restaurants/entities/restaurant.entity.ts`**

```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { BotPersona, WeekSchedule, ReservationConfig } from '@warike-business/types';

@Entity('restaurants')
export class Restaurant {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  wuarike_place_id: string;

  @Column()
  owner_user_id: string;

  @Column({ default: 'PEN' })
  currency: string;

  @Column({ default: 'America/Lima' })
  timezone: string;

  @Column({ type: 'jsonb', nullable: true })
  bot_persona: BotPersona;

  @Column({ type: 'jsonb', nullable: true })
  schedule: WeekSchedule;

  @Column({ type: 'jsonb', nullable: true })
  reservations_config: ReservationConfig;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
```

- [ ] **Step 2: Create `src/carta/entities/carta-category.entity.ts`**

```typescript
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Restaurant } from '../../restaurants/entities/restaurant.entity';

@Entity('carta_categories')
export class CartaCategory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  restaurant_id: string;

  @ManyToOne(() => Restaurant)
  @JoinColumn({ name: 'restaurant_id' })
  restaurant: Restaurant;

  @Column()
  name: string;

  @Column({ default: '🍽️' })
  emoji: string;

  @Column({ default: 0 })
  sort_order: number;

  @Column({ default: true })
  available: boolean;
}
```

- [ ] **Step 3: Create `src/carta/entities/carta-item.entity.ts`**

```typescript
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { CartaCategory } from './carta-category.entity';
import { DietaryInfo, PairingInfo, ItemVariant } from '@warike-business/types';

@Entity('carta_items')
export class CartaItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  category_id: string;

  @ManyToOne(() => CartaCategory)
  @JoinColumn({ name: 'category_id' })
  category: CartaCategory;

  @Column()
  restaurant_id: string;

  @Column()
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;

  @Column({ nullable: true })
  image_url: string;

  @Column({ default: true })
  available: boolean;

  @Column({ default: 15 })
  prep_time_minutes: number;

  @Column({ default: false })
  is_chef_recommendation: boolean;

  @Column({ type: 'text', nullable: true })
  chef_note: string;

  @Column({ type: 'jsonb', default: [] })
  tags: string[];

  @Column({ type: 'jsonb', default: [] })
  allergens: string[];

  @Column({ type: 'jsonb', nullable: true })
  dietary: DietaryInfo;

  @Column({ type: 'jsonb', nullable: true })
  pairing: PairingInfo;

  @Column({ type: 'jsonb', default: [] })
  variants: ItemVariant[];

  @Column({ type: 'jsonb', default: [] })
  combo_ids: string[];

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
```

- [ ] **Step 4: Create `src/reservas/entities/reserva.entity.ts`**

```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('reservas')
export class Reserva {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  restaurant_id: string;

  @Column()
  customer_name: string;

  @Column()
  customer_phone: string;

  @Column()
  party_size: number;

  @Column({ type: 'date' })
  date: string;

  @Column({ type: 'time' })
  time: string;

  @Column({ default: 'pending' })
  status: string;

  @Column({ nullable: true })
  session_id: string;

  @Column({ nullable: true })
  channel: string;

  @CreateDateColumn()
  created_at: Date;
}
```

- [ ] **Step 5: Create `src/pedidos/entities/pedido.entity.ts`**

```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { PedidoLineItem } from '@warike-business/types';

@Entity('pedidos')
export class Pedido {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  restaurant_id: string;

  @Column({ nullable: true })
  session_id: string;

  @Column({ default: 'web_widget' })
  channel: string;

  @Column({ type: 'jsonb' })
  items: PedidoLineItem[];

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  total: number;

  @Column({ default: 'pending' })
  status: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
```

- [ ] **Step 6: Create `src/feedback/entities/feedback.entity.ts`**

```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('feedback')
export class Feedback {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  restaurant_id: string;

  @Column({ nullable: true })
  session_id: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'float', nullable: true })
  sentiment_score: number;

  @Column({ nullable: true })
  channel: string;

  @Column({ default: false })
  anonymous: boolean;

  @Column({ nullable: true })
  customer_name: string;

  @Column({ nullable: true })
  customer_phone: string;

  @Column({ default: 'pending' })
  status: string;

  @CreateDateColumn()
  created_at: Date;
}
```

- [ ] **Step 7: Generate and run TypeORM migration**

```bash
cd apps/bot-gateway
pnpm run migration:generate src/migrations/InitialSchema
pnpm run migration:run
```

Expected: `src/migrations/TIMESTAMP-InitialSchema.ts` created. Migration runs successfully.

- [ ] **Step 8: Verify tables exist in DB**

```bash
psql -U postgres -d warike_business -c "\dt"
```

Expected output includes: `restaurants`, `carta_categories`, `carta_items`, `reservas`, `pedidos`, `feedback`

- [ ] **Step 9: Commit**

```bash
cd d:/Github/warike_business
git add apps/bot-gateway/src/restaurants/ apps/bot-gateway/src/carta/entities/ apps/bot-gateway/src/reservas/entities/ apps/bot-gateway/src/pedidos/entities/ apps/bot-gateway/src/feedback/entities/ apps/bot-gateway/src/migrations/
git commit -m "feat(bot-gateway): add TypeORM entities and initial DB migration (6 tables)"
```

---

## Task 6: Carta Module (CRUD + Toggle)

**Files:**
- Create: `apps/bot-gateway/src/carta/dto/create-carta-item.dto.ts`
- Create: `apps/bot-gateway/src/carta/dto/update-carta-item.dto.ts`
- Create: `apps/bot-gateway/src/carta/carta.service.ts`
- Create: `apps/bot-gateway/src/carta/carta.service.spec.ts`
- Create: `apps/bot-gateway/src/carta/carta.controller.ts`
- Create: `apps/bot-gateway/src/carta/carta.module.ts`

- [ ] **Step 1: Create `src/carta/dto/create-carta-item.dto.ts`**

```typescript
import { IsString, IsNumber, IsBoolean, IsOptional, IsArray, Min, IsObject } from 'class-validator';
import { DietaryInfo, PairingInfo, ItemVariant } from '@warike-business/types';

export class CreateCartaItemDto {
  @IsString()
  category_id: string;

  @IsString()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsNumber()
  @Min(0)
  price: number;

  @IsString()
  @IsOptional()
  image_url?: string;

  @IsBoolean()
  @IsOptional()
  is_chef_recommendation?: boolean;

  @IsString()
  @IsOptional()
  chef_note?: string;

  @IsArray()
  @IsOptional()
  allergens?: string[];

  @IsArray()
  @IsOptional()
  tags?: string[];

  @IsObject()
  @IsOptional()
  dietary?: DietaryInfo;

  @IsObject()
  @IsOptional()
  pairing?: PairingInfo;

  @IsArray()
  @IsOptional()
  variants?: ItemVariant[];

  @IsNumber()
  @IsOptional()
  prep_time_minutes?: number;
}
```

- [ ] **Step 2: Create `src/carta/dto/update-carta-item.dto.ts`**

```typescript
import { PartialType } from '@nestjs/mapped-types';
import { CreateCartaItemDto } from './create-carta-item.dto';
import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateCartaItemDto extends PartialType(CreateCartaItemDto) {
  @IsBoolean()
  @IsOptional()
  available?: boolean;
}
```

- [ ] **Step 3: Write failing test for CartaService**

Create `src/carta/carta.service.spec.ts`:

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException } from '@nestjs/common';
import { CartaService } from './carta.service';
import { CartaItem } from './entities/carta-item.entity';
import { CartaCategory } from './entities/carta-category.entity';

const mockRepo = {
  find: jest.fn(),
  findOne: jest.fn(),
  save: jest.fn(),
  create: jest.fn(),
  delete: jest.fn(),
};

describe('CartaService', () => {
  let service: CartaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CartaService,
        { provide: getRepositoryToken(CartaItem), useValue: { ...mockRepo } },
        { provide: getRepositoryToken(CartaCategory), useValue: { ...mockRepo } },
      ],
    }).compile();
    service = module.get<CartaService>(CartaService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAllByRestaurant', () => {
    it('returns items with category relation', async () => {
      const items = [{ id: '1', name: 'Ceviche', restaurant_id: 'r1' }];
      mockRepo.find.mockResolvedValue(items);
      const result = await service.findAllByRestaurant('r1');
      expect(result).toEqual(items);
      expect(mockRepo.find).toHaveBeenCalledWith({
        where: { restaurant_id: 'r1' },
        relations: ['category'],
      });
    });
  });

  describe('toggleAvailability', () => {
    it('flips available from true to false', async () => {
      const item = { id: '1', available: true, restaurant_id: 'r1' };
      mockRepo.findOne.mockResolvedValue(item);
      mockRepo.save.mockResolvedValue({ ...item, available: false });
      const result = await service.toggleAvailability('1', 'r1');
      expect(result.available).toBe(false);
    });

    it('throws NotFoundException when item not found', async () => {
      mockRepo.findOne.mockResolvedValue(null);
      await expect(service.toggleAvailability('bad', 'r1')).rejects.toThrow(NotFoundException);
    });
  });
});
```

- [ ] **Step 4: Run test to verify it fails**

```bash
cd apps/bot-gateway
pnpm test -- --testPathPattern=carta.service
```

Expected: FAIL — `Cannot find module './carta.service'`

- [ ] **Step 5: Create `src/carta/carta.service.ts`**

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CartaItem } from './entities/carta-item.entity';
import { CartaCategory } from './entities/carta-category.entity';
import { CreateCartaItemDto } from './dto/create-carta-item.dto';
import { UpdateCartaItemDto } from './dto/update-carta-item.dto';

@Injectable()
export class CartaService {
  constructor(
    @InjectRepository(CartaItem)
    private readonly itemRepo: Repository<CartaItem>,
    @InjectRepository(CartaCategory)
    private readonly categoryRepo: Repository<CartaCategory>,
  ) {}

  findAllByRestaurant(restaurant_id: string): Promise<CartaItem[]> {
    return this.itemRepo.find({ where: { restaurant_id }, relations: ['category'] });
  }

  findOne(id: string, restaurant_id: string): Promise<CartaItem | null> {
    return this.itemRepo.findOne({ where: { id, restaurant_id } });
  }

  create(restaurant_id: string, dto: CreateCartaItemDto): Promise<CartaItem> {
    const item = this.itemRepo.create({ ...dto, restaurant_id, available: true });
    return this.itemRepo.save(item);
  }

  async update(id: string, restaurant_id: string, dto: UpdateCartaItemDto): Promise<CartaItem> {
    const item = await this.itemRepo.findOne({ where: { id, restaurant_id } });
    if (!item) throw new NotFoundException('CartaItem not found');
    Object.assign(item, dto);
    return this.itemRepo.save(item);
  }

  async toggleAvailability(id: string, restaurant_id: string): Promise<CartaItem> {
    const item = await this.itemRepo.findOne({ where: { id, restaurant_id } });
    if (!item) throw new NotFoundException('CartaItem not found');
    item.available = !item.available;
    return this.itemRepo.save(item);
  }

  async remove(id: string, restaurant_id: string): Promise<void> {
    const item = await this.itemRepo.findOne({ where: { id, restaurant_id } });
    if (!item) throw new NotFoundException('CartaItem not found');
    await this.itemRepo.delete(id);
  }

  findCategories(restaurant_id: string): Promise<CartaCategory[]> {
    return this.categoryRepo.find({
      where: { restaurant_id },
      order: { sort_order: 'ASC' },
    });
  }

  createCategory(restaurant_id: string, name: string, emoji: string, sort_order: number): Promise<CartaCategory> {
    const cat = this.categoryRepo.create({ restaurant_id, name, emoji, sort_order });
    return this.categoryRepo.save(cat);
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

```bash
pnpm test -- --testPathPattern=carta.service
```

Expected: PASS — 4 tests passing.

- [ ] **Step 7: Create `src/carta/carta.controller.ts`**

```typescript
import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { CartaService } from './carta.service';
import { CreateCartaItemDto } from './dto/create-carta-item.dto';
import { UpdateCartaItemDto } from './dto/update-carta-item.dto';
import { JwtBusinessGuard } from '../auth/jwt-business.guard';

@Controller('carta')
@UseGuards(JwtBusinessGuard)
export class CartaController {
  constructor(private readonly cartaService: CartaService) {}

  @Get(':restaurantId')
  findAll(@Param('restaurantId') restaurantId: string) {
    return this.cartaService.findAllByRestaurant(restaurantId);
  }

  @Get(':restaurantId/categories')
  findCategories(@Param('restaurantId') restaurantId: string) {
    return this.cartaService.findCategories(restaurantId);
  }

  @Post(':restaurantId')
  create(@Param('restaurantId') restaurantId: string, @Body() dto: CreateCartaItemDto) {
    return this.cartaService.create(restaurantId, dto);
  }

  @Patch(':restaurantId/items/:id')
  update(
    @Param('restaurantId') restaurantId: string,
    @Param('id') id: string,
    @Body() dto: UpdateCartaItemDto,
  ) {
    return this.cartaService.update(id, restaurantId, dto);
  }

  @Patch(':restaurantId/items/:id/toggle')
  toggleAvailability(@Param('restaurantId') restaurantId: string, @Param('id') id: string) {
    return this.cartaService.toggleAvailability(id, restaurantId);
  }

  @Delete(':restaurantId/items/:id')
  remove(@Param('restaurantId') restaurantId: string, @Param('id') id: string) {
    return this.cartaService.remove(id, restaurantId);
  }
}
```

Note: `GET /carta/:restaurantId` also responds to unauthenticated calls from n8n using the n8n webhook secret. In v1 this endpoint is guarded by JWT; n8n must use a service account JWT. Adjust the guard to `@IsPublic()` in v2 if needed.

- [ ] **Step 8: Create `src/carta/carta.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CartaItem } from './entities/carta-item.entity';
import { CartaCategory } from './entities/carta-category.entity';
import { CartaService } from './carta.service';
import { CartaController } from './carta.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([CartaItem, CartaCategory]), AuthModule],
  providers: [CartaService],
  controllers: [CartaController],
  exports: [CartaService],
})
export class CartaModule {}
```

- [ ] **Step 9: Add `CartaModule` to `app.module.ts` imports array**

- [ ] **Step 10: Commit**

```bash
cd d:/Github/warike_business
git add apps/bot-gateway/src/carta/
git commit -m "feat(bot-gateway): add carta module with CRUD and instant toggle availability"
```

---

## Task 7: Reservas Module

**Files:**
- Create: `apps/bot-gateway/src/reservas/dto/create-reserva.dto.ts`
- Create: `apps/bot-gateway/src/reservas/reservas.service.ts`
- Create: `apps/bot-gateway/src/reservas/reservas.service.spec.ts`
- Create: `apps/bot-gateway/src/reservas/reservas.controller.ts`
- Create: `apps/bot-gateway/src/reservas/reservas.module.ts`

- [ ] **Step 1: Create `src/reservas/dto/create-reserva.dto.ts`**

```typescript
import { IsString, IsNumber, IsDateString, Min, Max } from 'class-validator';

export class CreateReservaDto {
  @IsString()
  restaurant_id: string;

  @IsString()
  customer_name: string;

  @IsString()
  customer_phone: string;

  @IsNumber()
  @Min(1)
  @Max(20)
  party_size: number;

  @IsDateString()
  date: string;

  @IsString()
  time: string;

  @IsString()
  session_id: string;

  @IsString()
  channel: string;
}
```

- [ ] **Step 2: Write failing test for ReservasService**

Create `src/reservas/reservas.service.spec.ts`:

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException } from '@nestjs/common';
import { ReservasService } from './reservas.service';
import { Reserva } from './entities/reserva.entity';

const mockRepo = {
  find: jest.fn(),
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
};

describe('ReservasService', () => {
  let service: ReservasService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReservasService,
        { provide: getRepositoryToken(Reserva), useValue: { ...mockRepo } },
      ],
    }).compile();
    service = module.get<ReservasService>(ReservasService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('saves reserva with status pending', async () => {
      const dto = {
        restaurant_id: 'r1', customer_name: 'Juan', customer_phone: '999',
        party_size: 2, date: '2026-04-26', time: '19:00', session_id: 's1', channel: 'whatsapp',
      };
      mockRepo.create.mockReturnValue({ ...dto, status: 'pending' });
      mockRepo.save.mockResolvedValue({ ...dto, id: 'uuid-1', status: 'pending' });
      const result = await service.create(dto);
      expect(result.status).toBe('pending');
    });
  });

  describe('confirm', () => {
    it('sets status to confirmed', async () => {
      mockRepo.findOne.mockResolvedValue({ id: '1', status: 'pending', restaurant_id: 'r1' });
      mockRepo.save.mockResolvedValue({ id: '1', status: 'confirmed', restaurant_id: 'r1' });
      const result = await service.confirm('1', 'r1');
      expect(result.status).toBe('confirmed');
    });

    it('throws NotFoundException when reserva not found', async () => {
      mockRepo.findOne.mockResolvedValue(null);
      await expect(service.confirm('bad', 'r1')).rejects.toThrow(NotFoundException);
    });
  });
});
```

- [ ] **Step 3: Run test to verify it fails**

```bash
pnpm test -- --testPathPattern=reservas.service
```

Expected: FAIL — `Cannot find module './reservas.service'`

- [ ] **Step 4: Create `src/reservas/reservas.service.ts`**

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reserva } from './entities/reserva.entity';
import { CreateReservaDto } from './dto/create-reserva.dto';

@Injectable()
export class ReservasService {
  constructor(
    @InjectRepository(Reserva)
    private readonly reservaRepo: Repository<Reserva>,
  ) {}

  create(dto: CreateReservaDto): Promise<Reserva> {
    const reserva = this.reservaRepo.create({ ...dto, status: 'pending' });
    return this.reservaRepo.save(reserva);
  }

  findByRestaurant(restaurant_id: string): Promise<Reserva[]> {
    return this.reservaRepo.find({
      where: { restaurant_id },
      order: { created_at: 'DESC' },
    });
  }

  async confirm(id: string, restaurant_id: string): Promise<Reserva> {
    const reserva = await this.reservaRepo.findOne({ where: { id, restaurant_id } });
    if (!reserva) throw new NotFoundException('Reserva not found');
    reserva.status = 'confirmed';
    return this.reservaRepo.save(reserva);
  }

  async cancel(id: string, restaurant_id: string): Promise<Reserva> {
    const reserva = await this.reservaRepo.findOne({ where: { id, restaurant_id } });
    if (!reserva) throw new NotFoundException('Reserva not found');
    reserva.status = 'cancelled';
    return this.reservaRepo.save(reserva);
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
pnpm test -- --testPathPattern=reservas.service
```

Expected: PASS — 4 tests passing.

- [ ] **Step 6: Create `src/reservas/reservas.controller.ts`**

```typescript
import { Controller, Get, Post, Patch, Body, Param, UseGuards } from '@nestjs/common';
import { ReservasService } from './reservas.service';
import { CreateReservaDto } from './dto/create-reserva.dto';
import { JwtBusinessGuard } from '../auth/jwt-business.guard';

@Controller('reservas')
export class ReservasController {
  constructor(private readonly reservasService: ReservasService) {}

  @Post()
  create(@Body() dto: CreateReservaDto) {
    return this.reservasService.create(dto);
  }

  @Get(':restaurantId')
  @UseGuards(JwtBusinessGuard)
  findAll(@Param('restaurantId') restaurantId: string) {
    return this.reservasService.findByRestaurant(restaurantId);
  }

  @Patch(':restaurantId/:id/confirm')
  @UseGuards(JwtBusinessGuard)
  confirm(@Param('restaurantId') restaurantId: string, @Param('id') id: string) {
    return this.reservasService.confirm(id, restaurantId);
  }

  @Patch(':restaurantId/:id/cancel')
  @UseGuards(JwtBusinessGuard)
  cancel(@Param('restaurantId') restaurantId: string, @Param('id') id: string) {
    return this.reservasService.cancel(id, restaurantId);
  }
}
```

- [ ] **Step 7: Create `src/reservas/reservas.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Reserva } from './entities/reserva.entity';
import { ReservasService } from './reservas.service';
import { ReservasController } from './reservas.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([Reserva]), AuthModule],
  providers: [ReservasService],
  controllers: [ReservasController],
  exports: [ReservasService],
})
export class ReservasModule {}
```

- [ ] **Step 8: Add `ReservasModule` to `app.module.ts` imports array**

- [ ] **Step 9: Commit**

```bash
git add apps/bot-gateway/src/reservas/
git commit -m "feat(bot-gateway): add reservas module with create/confirm/cancel"
```

---

## Task 8: Pedidos Module

**Files:**
- Create: `apps/bot-gateway/src/pedidos/dto/create-pedido.dto.ts`
- Create: `apps/bot-gateway/src/pedidos/pedidos.service.ts`
- Create: `apps/bot-gateway/src/pedidos/pedidos.controller.ts`
- Create: `apps/bot-gateway/src/pedidos/pedidos.module.ts`

- [ ] **Step 1: Create `src/pedidos/dto/create-pedido.dto.ts`**

```typescript
import { IsString, IsNumber, IsArray, IsOptional, ValidateNested, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { PedidoLineItem } from '@warike-business/types';

export class PedidoLineItemDto implements PedidoLineItem {
  @IsString()
  item_id: string;

  @IsString()
  @IsOptional()
  variant_id?: string;

  @IsNumber()
  @Min(1)
  quantity: number;

  @IsNumber()
  unit_price: number;

  @IsString()
  item_name: string;
}

export class CreatePedidoDto {
  @IsString()
  restaurant_id: string;

  @IsString()
  @IsOptional()
  session_id?: string;

  @IsString()
  channel: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PedidoLineItemDto)
  items: PedidoLineItemDto[];

  @IsNumber()
  @Min(0)
  total: number;
}
```

- [ ] **Step 2: Create `src/pedidos/pedidos.service.ts`**

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Pedido } from './entities/pedido.entity';
import { CreatePedidoDto } from './dto/create-pedido.dto';

@Injectable()
export class PedidosService {
  constructor(
    @InjectRepository(Pedido)
    private readonly pedidoRepo: Repository<Pedido>,
  ) {}

  create(dto: CreatePedidoDto): Promise<Pedido> {
    const pedido = this.pedidoRepo.create({ ...dto, status: 'pending' });
    return this.pedidoRepo.save(pedido);
  }

  findByRestaurant(restaurant_id: string): Promise<Pedido[]> {
    return this.pedidoRepo.find({
      where: { restaurant_id },
      order: { created_at: 'DESC' },
    });
  }

  async updateStatus(id: string, restaurant_id: string, status: string): Promise<Pedido> {
    const pedido = await this.pedidoRepo.findOne({ where: { id, restaurant_id } });
    if (!pedido) throw new NotFoundException('Pedido not found');
    pedido.status = status;
    return this.pedidoRepo.save(pedido);
  }
}
```

- [ ] **Step 3: Create `src/pedidos/pedidos.controller.ts`**

```typescript
import { Controller, Get, Post, Patch, Body, Param, UseGuards } from '@nestjs/common';
import { PedidosService } from './pedidos.service';
import { CreatePedidoDto } from './dto/create-pedido.dto';
import { JwtBusinessGuard } from '../auth/jwt-business.guard';

@Controller('pedidos')
export class PedidosController {
  constructor(private readonly pedidosService: PedidosService) {}

  @Post()
  create(@Body() dto: CreatePedidoDto) {
    return this.pedidosService.create(dto);
  }

  @Get(':restaurantId')
  @UseGuards(JwtBusinessGuard)
  findAll(@Param('restaurantId') restaurantId: string) {
    return this.pedidosService.findByRestaurant(restaurantId);
  }

  @Patch(':restaurantId/:id/status/:status')
  @UseGuards(JwtBusinessGuard)
  updateStatus(
    @Param('restaurantId') restaurantId: string,
    @Param('id') id: string,
    @Param('status') status: string,
  ) {
    return this.pedidosService.updateStatus(id, restaurantId, status);
  }
}
```

- [ ] **Step 4: Create `src/pedidos/pedidos.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Pedido } from './entities/pedido.entity';
import { PedidosService } from './pedidos.service';
import { PedidosController } from './pedidos.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([Pedido]), AuthModule],
  providers: [PedidosService],
  controllers: [PedidosController],
  exports: [PedidosService],
})
export class PedidosModule {}
```

- [ ] **Step 5: Add `PedidosModule` to `app.module.ts` imports array**

- [ ] **Step 6: Commit**

```bash
git add apps/bot-gateway/src/pedidos/
git commit -m "feat(bot-gateway): add pedidos module with create and status transitions"
```

---

## Task 9: Feedback Module (Private — Invariant Enforced)

**Files:**
- Create: `apps/bot-gateway/src/feedback/dto/create-feedback.dto.ts`
- Create: `apps/bot-gateway/src/feedback/feedback.service.ts`
- Create: `apps/bot-gateway/src/feedback/feedback.service.spec.ts`
- Create: `apps/bot-gateway/src/feedback/feedback.controller.ts`
- Create: `apps/bot-gateway/src/feedback/feedback.module.ts`

- [ ] **Step 1: Create `src/feedback/dto/create-feedback.dto.ts`**

```typescript
import { IsString, IsNumber, IsBoolean, IsOptional, Min, Max } from 'class-validator';

export class CreateFeedbackDto {
  @IsString()
  restaurant_id: string;

  @IsString()
  @IsOptional()
  session_id?: string;

  @IsString()
  message: string;

  @IsNumber()
  @Min(0)
  @Max(1)
  sentiment_score: number;

  @IsString()
  channel: string;

  @IsBoolean()
  anonymous: boolean;

  @IsString()
  @IsOptional()
  customer_name?: string;

  @IsString()
  @IsOptional()
  customer_phone?: string;
}
```

- [ ] **Step 2: Write failing test for FeedbackService**

Create `src/feedback/feedback.service.spec.ts`:

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException } from '@nestjs/common';
import { FeedbackService } from './feedback.service';
import { Feedback } from './entities/feedback.entity';

const mockRepo = {
  find: jest.fn(),
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
};

describe('FeedbackService', () => {
  let service: FeedbackService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FeedbackService,
        { provide: getRepositoryToken(Feedback), useValue: { ...mockRepo } },
      ],
    }).compile();
    service = module.get<FeedbackService>(FeedbackService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('saves feedback with status pending', async () => {
      const dto = {
        restaurant_id: 'r1', message: 'Mal servicio',
        sentiment_score: 0.1, channel: 'whatsapp', anonymous: false,
      };
      mockRepo.create.mockReturnValue({ ...dto, status: 'pending' });
      mockRepo.save.mockResolvedValue({ ...dto, id: 'f1', status: 'pending' });
      const result = await service.create(dto);
      expect(result.status).toBe('pending');
    });
  });

  describe('resolve', () => {
    it('sets status to resolved', async () => {
      mockRepo.findOne.mockResolvedValue({ id: 'f1', status: 'pending', restaurant_id: 'r1' });
      mockRepo.save.mockResolvedValue({ id: 'f1', status: 'resolved', restaurant_id: 'r1' });
      const result = await service.resolve('f1', 'r1');
      expect(result.status).toBe('resolved');
    });

    it('throws NotFoundException when feedback not found', async () => {
      mockRepo.findOne.mockResolvedValue(null);
      await expect(service.resolve('bad', 'r1')).rejects.toThrow(NotFoundException);
    });
  });
});
```

- [ ] **Step 3: Run test to verify it fails**

```bash
pnpm test -- --testPathPattern=feedback.service
```

Expected: FAIL — `Cannot find module './feedback.service'`

- [ ] **Step 4: Create `src/feedback/feedback.service.ts`**

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Feedback } from './entities/feedback.entity';
import { CreateFeedbackDto } from './dto/create-feedback.dto';

@Injectable()
export class FeedbackService {
  constructor(
    @InjectRepository(Feedback)
    private readonly feedbackRepo: Repository<Feedback>,
  ) {}

  create(dto: CreateFeedbackDto): Promise<Feedback> {
    const feedback = this.feedbackRepo.create({ ...dto, status: 'pending' });
    return this.feedbackRepo.save(feedback);
  }

  findByRestaurant(restaurant_id: string, status?: string): Promise<Feedback[]> {
    const where: Record<string, string> = { restaurant_id };
    if (status) where['status'] = status;
    return this.feedbackRepo.find({ where, order: { created_at: 'DESC' } });
  }

  async resolve(id: string, restaurant_id: string): Promise<Feedback> {
    const fb = await this.feedbackRepo.findOne({ where: { id, restaurant_id } });
    if (!fb) throw new NotFoundException('Feedback not found');
    fb.status = 'resolved';
    return this.feedbackRepo.save(fb);
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
pnpm test -- --testPathPattern=feedback.service
```

Expected: PASS — 4 tests passing.

- [ ] **Step 6: Create `src/feedback/feedback.controller.ts`**

```typescript
import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { FeedbackService } from './feedback.service';
import { CreateFeedbackDto } from './dto/create-feedback.dto';
import { JwtBusinessGuard } from '../auth/jwt-business.guard';

@Controller('feedback')
export class FeedbackController {
  constructor(private readonly feedbackService: FeedbackService) {}

  @Post()
  create(@Body() dto: CreateFeedbackDto) {
    return this.feedbackService.create(dto);
  }

  @Get(':restaurantId')
  @UseGuards(JwtBusinessGuard)
  findAll(@Param('restaurantId') restaurantId: string, @Query('status') status?: string) {
    return this.feedbackService.findByRestaurant(restaurantId, status);
  }

  @Patch(':restaurantId/:id/resolve')
  @UseGuards(JwtBusinessGuard)
  resolve(@Param('restaurantId') restaurantId: string, @Param('id') id: string) {
    return this.feedbackService.resolve(id, restaurantId);
  }
}
```

There is intentionally NO endpoint that publishes feedback to Wuarike reviews. This file is the enforcement point of the privacy invariant.

- [ ] **Step 7: Create `src/feedback/feedback.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Feedback } from './entities/feedback.entity';
import { FeedbackService } from './feedback.service';
import { FeedbackController } from './feedback.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([Feedback]), AuthModule],
  providers: [FeedbackService],
  controllers: [FeedbackController],
  exports: [FeedbackService],
})
export class FeedbackModule {}
```

- [ ] **Step 8: Add `FeedbackModule` to `app.module.ts` imports array**

- [ ] **Step 9: Commit**

```bash
git add apps/bot-gateway/src/feedback/
git commit -m "feat(bot-gateway): add feedback module — private channel, no public endpoint"
```

---

## Task 10: Webhooks Module (Activity Polling for Dashboard)

Dashboard calls `GET /webhooks/events/:restaurantId` every 30 seconds to get recent activity (pedidos + reservas + feedback merged and sorted by recency).

**Files:**
- Create: `apps/bot-gateway/src/webhooks/webhooks.service.ts`
- Create: `apps/bot-gateway/src/webhooks/webhooks.controller.ts`
- Create: `apps/bot-gateway/src/webhooks/webhooks.module.ts`

- [ ] **Step 1: Create `src/webhooks/webhooks.service.ts`**

```typescript
import { Injectable } from '@nestjs/common';
import { PedidosService } from '../pedidos/pedidos.service';
import { ReservasService } from '../reservas/reservas.service';
import { FeedbackService } from '../feedback/feedback.service';

export interface ActivityEvent {
  type: 'pedido' | 'reserva' | 'feedback';
  id: string;
  summary: string;
  created_at: string;
  urgent: boolean;
}

@Injectable()
export class WebhooksService {
  constructor(
    private readonly pedidosService: PedidosService,
    private readonly reservasService: ReservasService,
    private readonly feedbackService: FeedbackService,
  ) {}

  async getRecentActivity(restaurant_id: string): Promise<ActivityEvent[]> {
    const [pedidos, reservas, feedbacks] = await Promise.all([
      this.pedidosService.findByRestaurant(restaurant_id),
      this.reservasService.findByRestaurant(restaurant_id),
      this.feedbackService.findByRestaurant(restaurant_id),
    ]);

    const events: ActivityEvent[] = [
      ...pedidos.slice(0, 5).map(p => ({
        type: 'pedido' as const,
        id: p.id,
        summary: `Pedido — S/. ${p.total}`,
        created_at: p.created_at.toString(),
        urgent: false,
      })),
      ...reservas.slice(0, 5).map(r => ({
        type: 'reserva' as const,
        id: r.id,
        summary: `Reserva ${r.party_size} personas — ${r.date} ${r.time}`,
        created_at: r.created_at.toString(),
        urgent: r.status === 'pending',
      })),
      ...feedbacks.slice(0, 5).map(f => ({
        type: 'feedback' as const,
        id: f.id,
        summary: f.message.substring(0, 60) + (f.message.length > 60 ? '...' : ''),
        created_at: f.created_at.toString(),
        urgent: f.status === 'pending',
      })),
    ];

    return events
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      .slice(0, 10);
  }
}
```

- [ ] **Step 2: Create `src/webhooks/webhooks.controller.ts`**

```typescript
import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { WebhooksService } from './webhooks.service';
import { JwtBusinessGuard } from '../auth/jwt-business.guard';

@Controller('webhooks')
export class WebhooksController {
  constructor(private readonly webhooksService: WebhooksService) {}

  @Get('events/:restaurantId')
  @UseGuards(JwtBusinessGuard)
  getActivity(@Param('restaurantId') restaurantId: string) {
    return this.webhooksService.getRecentActivity(restaurantId);
  }
}
```

- [ ] **Step 3: Create `src/webhooks/webhooks.module.ts`**

```typescript
import { Module } from '@nestjs/common';
import { WebhooksController } from './webhooks.controller';
import { WebhooksService } from './webhooks.service';
import { PedidosModule } from '../pedidos/pedidos.module';
import { ReservasModule } from '../reservas/reservas.module';
import { FeedbackModule } from '../feedback/feedback.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PedidosModule, ReservasModule, FeedbackModule, AuthModule],
  providers: [WebhooksService],
  controllers: [WebhooksController],
})
export class WebhooksModule {}
```

- [ ] **Step 4: Add `WebhooksModule` to `app.module.ts` imports array**

Final `app.module.ts` imports should be:
```typescript
imports: [
  ConfigModule.forRoot({ isGlobal: true }),
  TypeOrmModule.forRootAsync({ ... }),
  AuthModule,
  CartaModule,
  ReservasModule,
  PedidosModule,
  FeedbackModule,
  WebhooksModule,
],
```

- [ ] **Step 5: Commit**

```bash
git add apps/bot-gateway/src/webhooks/
git commit -m "feat(bot-gateway): add webhooks activity polling endpoint for dashboard"
```

---

## Task 11: Full Test Suite + Smoke Test

- [ ] **Step 1: Run all tests from monorepo root**

```bash
cd d:/Github/warike_business
pnpm test
```

Expected output:
```
apps/bot-gateway: Test Suites: 4 passed, 4 total
apps/bot-gateway: Tests:       ~14 passed, ~14 total
```

If any test fails, check that mock object properties match what the service calls on the repository.

- [ ] **Step 2: Start bot-gateway and verify all endpoints mount**

```bash
cd apps/bot-gateway && pnpm run start:dev
```

Expected: `Bot Gateway running on port 3002` — no module initialization errors.

- [ ] **Step 3: Smoke test each endpoint group**

```bash
# Auth verify (requires a valid business JWT from WARIKE_BACKEND)
curl http://localhost:3002/auth/verify \
  -H "Authorization: Bearer <business-jwt>"
# Expected: { "valid": true, "user": { "sub": "...", "role": "business" } }

# Carta (public read for n8n — in v1 still requires JWT)
curl http://localhost:3002/carta/any-restaurant-id \
  -H "Authorization: Bearer <business-jwt>"
# Expected: [] (empty array, no 500)

# Feedback create (n8n call, no JWT)
curl -X POST http://localhost:3002/feedback \
  -H "Content-Type: application/json" \
  -d '{"restaurant_id":"r1","message":"test","sentiment_score":0.2,"channel":"whatsapp","anonymous":true}'
# Expected: { "id": "uuid", "status": "pending", ... }
```

- [ ] **Step 4: Final commit**

```bash
cd d:/Github/warike_business
git add .
git commit -m "feat: complete Plan 1 — monorepo + types + bot-gateway API ready for Plan 2 and Plan 3"
```

---

## API Reference for Plan 2 (Dashboard) and Plan 3 (n8n)

```
Base URL: http://localhost:3002 (dev) | http://38.242.252.183:3002 (prod)

AUTH
GET    /auth/verify                               JWT required — n8n verifies sessions

CARTA (all require JWT)
GET    /carta/:restaurantId                       Full menu with categories
GET    /carta/:restaurantId/categories            Category list only
POST   /carta/:restaurantId                       Create item (body: CreateCartaItemDto)
PATCH  /carta/:restaurantId/items/:id             Update item (body: UpdateCartaItemDto)
PATCH  /carta/:restaurantId/items/:id/toggle      Toggle available (no body)
DELETE /carta/:restaurantId/items/:id             Remove item

RESERVAS
POST   /reservas                                  Create (no JWT — n8n calls this)
GET    /reservas/:restaurantId                    List (JWT required)
PATCH  /reservas/:restaurantId/:id/confirm        Confirm (JWT required)
PATCH  /reservas/:restaurantId/:id/cancel         Cancel (JWT required)

PEDIDOS
POST   /pedidos                                   Create (no JWT — n8n calls this)
GET    /pedidos/:restaurantId                     List (JWT required)
PATCH  /pedidos/:restaurantId/:id/status/:status  Update status (JWT required)

FEEDBACK (private — no public endpoint exists)
POST   /feedback                                  Create (no JWT — n8n calls this)
GET    /feedback/:restaurantId?status=pending     List (JWT required)
PATCH  /feedback/:restaurantId/:id/resolve        Mark resolved (JWT required)

WEBHOOKS
GET    /webhooks/events/:restaurantId             Recent activity feed (JWT required, poll every 30s)
```
