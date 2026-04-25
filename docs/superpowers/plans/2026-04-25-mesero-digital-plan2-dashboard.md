# Mesero Digital — Plan 2/3: Dashboard (Next.js)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Next.js 14 restaurant owner dashboard inside `apps/dashboard` — login, sidebar navigation, 4-KPI home screen, carta CRUD with instant availability toggle, reservas calendar, pedidos in real time (30s polling), private feedback management, and bot personality configuration.

**Architecture:** Next.js 14 App Router with route groups `(auth)` and `(dashboard)`. Server Components for data fetching, Client Components only for interactive UI. API calls go to the `bot-gateway` at `BOT_GATEWAY_URL`. Auth via next-auth with a custom credentials provider that validates JWTs issued by the main Wuarike backend.

**Tech Stack:** Next.js 14, TypeScript, Tailwind CSS, shadcn/ui, next-auth 5, TanStack Query 5, Zustand 4, `@warike-business/types` (workspace), lucide-react

**Prerequisite:** Plan 1 must be complete — the bot-gateway API must be running.

---

## File Map

```
apps/dashboard/
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── next.config.ts
├── .env.local (gitignored)
├── app/
│   ├── layout.tsx                        ← root layout (fonts, providers)
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── layout.tsx
│   └── (dashboard)/
│       ├── layout.tsx                    ← sidebar + top nav
│       ├── page.tsx                      ← Inicio: 4 KPIs + activity feed
│       ├── carta/
│       │   ├── page.tsx                  ← category accordion + items list
│       │   └── nuevo/page.tsx            ← 3-step wizard new item
│       ├── reservas/page.tsx
│       ├── pedidos/page.tsx
│       ├── feedback/page.tsx
│       └── bot/page.tsx
├── components/
│   ├── ui/                               ← shadcn/ui primitives
│   └── business/
│       ├── KpiCard.tsx
│       ├── ActivityFeed.tsx
│       ├── CartaItemRow.tsx
│       ├── CartaWizard.tsx
│       ├── ReservaCard.tsx
│       ├── PedidoCard.tsx
│       ├── FeedbackCard.tsx
│       └── BotPreview.tsx
├── lib/
│   ├── api-client.ts                     ← typed fetch wrapper → bot-gateway
│   ├── auth.ts                           ← next-auth config
│   └── query-client.ts                   ← TanStack Query singleton
└── hooks/
    ├── use-activity-poll.ts              ← 30s polling hook
    └── use-feedback-count.ts             ← badge count for sidebar
```

---

## Task 1: Next.js Scaffold + Tailwind + shadcn/ui

**Files:**
- Create: `apps/dashboard/` (Next.js project)
- Create: `apps/dashboard/.env.local`
- Modify: `apps/dashboard/package.json`

- [ ] **Step 1: Create Next.js app**

```bash
cd d:/Github/warike_business/apps
npx create-next-app@latest dashboard \
  --typescript --tailwind --eslint --app \
  --src-dir no --import-alias "@/*" \
  --skip-install
```

- [ ] **Step 2: Install dependencies**

```bash
cd apps/dashboard
pnpm add next-auth@beta @auth/core \
  @tanstack/react-query zustand \
  lucide-react clsx tailwind-merge \
  @warike-business/types
pnpm add -D @types/node
```

- [ ] **Step 3: Add workspace types to `apps/dashboard/package.json`**

Ensure `dependencies` contains:
```json
"@warike-business/types": "workspace:*"
```

Then from monorepo root: `pnpm install`

- [ ] **Step 4: Install shadcn/ui**

```bash
cd apps/dashboard
npx shadcn@latest init
```

When prompted:
- Style: **Default**
- Base color: **Neutral**
- CSS variables: **yes**

Then add components:
```bash
npx shadcn@latest add button card badge input label switch textarea select tabs accordion toast
```

- [ ] **Step 5: Create `apps/dashboard/.env.local`**

```
NEXTAUTH_SECRET=same_jwt_secret_as_backend
NEXTAUTH_URL=http://localhost:3000
BOT_GATEWAY_URL=http://localhost:3002
```

- [ ] **Step 6: Update `apps/dashboard/tailwind.config.ts`** — add Poppins font variable

```typescript
import type { Config } from 'tailwindcss';

const config: Config = {
  darkMode: ['class'],
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-poppins)', 'sans-serif'],
      },
      colors: {
        brand: {
          primary: '#F26122',
          danger: '#E8453C',
          success: '#00BFA5',
          warning: '#FFB800',
        },
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
};

export default config;
```

- [ ] **Step 7: Update root `app/layout.tsx`**

```typescript
import type { Metadata } from 'next';
import { Poppins } from 'next/font/google';
import './globals.css';

const poppins = Poppins({
  subsets: ['latin'],
  weight: ['400', '600', '700'],
  variable: '--font-poppins',
});

export const metadata: Metadata = {
  title: 'Wuarike Business',
  description: 'Panel de gestión para restaurantes',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className={`${poppins.variable} font-sans bg-[#F7F8FA]`}>{children}</body>
    </html>
  );
}
```

- [ ] **Step 8: Verify Next.js builds**

```bash
pnpm run dev
```

Expected: `ready on http://localhost:3000` — no TypeScript errors.

- [ ] **Step 9: Commit**

```bash
cd d:/Github/warike_business
git add apps/dashboard/
git commit -m "feat(dashboard): scaffold Next.js 14 with Tailwind, shadcn/ui, Poppins"
```

---

## Task 2: Auth (next-auth + JWT from Wuarike Backend)

**Files:**
- Create: `apps/dashboard/lib/auth.ts`
- Create: `apps/dashboard/app/api/auth/[...nextauth]/route.ts`
- Create: `apps/dashboard/app/(auth)/login/page.tsx`
- Create: `apps/dashboard/app/(auth)/layout.tsx`

- [ ] **Step 1: Create `lib/auth.ts`**

```typescript
import NextAuth from 'next-auth';
import Credentials from 'next-auth/providers/credentials';

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    Credentials({
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        const res = await fetch(`${process.env.BOT_GATEWAY_URL}/auth/login`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(credentials),
        });
        if (!res.ok) return null;
        const data = await res.json();
        if (data.access_token && data.user?.role === 'business') {
          return { ...data.user, accessToken: data.access_token };
        }
        return null;
      },
    }),
  ],
  callbacks: {
    jwt({ token, user }) {
      if (user) {
        token.accessToken = (user as { accessToken: string }).accessToken;
        token.restaurantId = (user as { restaurant_id?: string }).restaurant_id;
        token.role = (user as { role: string }).role;
      }
      return token;
    },
    session({ session, token }) {
      session.user.accessToken = token.accessToken as string;
      session.user.restaurantId = token.restaurantId as string;
      session.user.role = token.role as string;
      return session;
    },
  },
  pages: { signIn: '/login' },
});
```

Note: This calls `POST /auth/login` on bot-gateway — add that endpoint to Plan 1 Task 4 when implementing (or add a login module to bot-gateway before running Plan 2). The endpoint should accept `{ email, password }` and return `{ access_token, user }`.

- [ ] **Step 2: Create `app/api/auth/[...nextauth]/route.ts`**

```typescript
import { handlers } from '@/lib/auth';
export const { GET, POST } = handlers;
```

- [ ] **Step 3: Create `app/(auth)/layout.tsx`**

```typescript
export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FFF5F0]">
      <div className="w-full max-w-md px-4">{children}</div>
    </div>
  );
}
```

- [ ] **Step 4: Create `app/(auth)/login/page.tsx`**

```typescript
'use client';

import { useState } from 'react';
import { signIn } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

export default function LoginPage() {
  const router = useRouter();
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    setError('');
    const formData = new FormData(e.currentTarget);
    const result = await signIn('credentials', {
      email: formData.get('email'),
      password: formData.get('password'),
      redirect: false,
    });
    if (result?.error) {
      setError('Email o contraseña incorrectos');
      setLoading(false);
    } else {
      router.push('/');
    }
  }

  return (
    <Card className="shadow-lg">
      <CardHeader className="text-center pb-2">
        <div className="text-4xl mb-2">🍽️</div>
        <CardTitle className="text-2xl font-bold text-[#1A1A1A]">Wuarike Business</CardTitle>
        <p className="text-sm text-[#6B7280]">Panel de gestión para tu restaurante</p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-1">
            <Label htmlFor="email">Email</Label>
            <Input id="email" name="email" type="email" required placeholder="dueño@restaurante.com" />
          </div>
          <div className="space-y-1">
            <Label htmlFor="password">Contraseña</Label>
            <Input id="password" name="password" type="password" required />
          </div>
          {error && <p className="text-sm text-[#E8453C]">{error}</p>}
          <Button
            type="submit"
            disabled={loading}
            className="w-full bg-[#F26122] hover:bg-[#d9541a] text-white font-semibold"
          >
            {loading ? 'Ingresando...' : 'Ingresar'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
```

- [ ] **Step 5: Add auth session provider to root layout**

Update `app/layout.tsx`:

```typescript
import type { Metadata } from 'next';
import { Poppins } from 'next/font/google';
import { SessionProvider } from 'next-auth/react';
import { auth } from '@/lib/auth';
import './globals.css';

const poppins = Poppins({ subsets: ['latin'], weight: ['400', '600', '700'], variable: '--font-poppins' });

export const metadata: Metadata = {
  title: 'Wuarike Business',
  description: 'Panel de gestión para restaurantes',
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const session = await auth();
  return (
    <html lang="es">
      <body className={`${poppins.variable} font-sans bg-[#F7F8FA]`}>
        <SessionProvider session={session}>{children}</SessionProvider>
      </body>
    </html>
  );
}
```

- [ ] **Step 6: Commit**

```bash
git add apps/dashboard/lib/auth.ts apps/dashboard/app/
git commit -m "feat(dashboard): add next-auth login with Wuarike JWT credentials"
```

---

## Task 3: API Client + Query Provider

**Files:**
- Create: `apps/dashboard/lib/api-client.ts`
- Create: `apps/dashboard/lib/query-client.ts`
- Create: `apps/dashboard/components/providers.tsx`

- [ ] **Step 1: Create `lib/api-client.ts`**

```typescript
import { CartaItem, CartaCategory } from '@warike-business/types';

const BASE = process.env.NEXT_PUBLIC_BOT_GATEWAY_URL ?? 'http://localhost:3002';

async function fetchApi<T>(path: string, token: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...options?.headers,
    },
  });
  if (!res.ok) {
    const error = await res.json().catch(() => ({ message: 'Error desconocido' }));
    throw new Error(error.message ?? `HTTP ${res.status}`);
  }
  return res.json();
}

export const api = {
  carta: {
    getAll: (restaurantId: string, token: string) =>
      fetchApi<CartaItem[]>(`/carta/${restaurantId}`, token),
    getCategories: (restaurantId: string, token: string) =>
      fetchApi<CartaCategory[]>(`/carta/${restaurantId}/categories`, token),
    toggle: (restaurantId: string, itemId: string, token: string) =>
      fetchApi<CartaItem>(`/carta/${restaurantId}/items/${itemId}/toggle`, token, { method: 'PATCH' }),
    create: (restaurantId: string, token: string, body: unknown) =>
      fetchApi<CartaItem>(`/carta/${restaurantId}`, token, { method: 'POST', body: JSON.stringify(body) }),
    update: (restaurantId: string, itemId: string, token: string, body: unknown) =>
      fetchApi<CartaItem>(`/carta/${restaurantId}/items/${itemId}`, token, { method: 'PATCH', body: JSON.stringify(body) }),
    remove: (restaurantId: string, itemId: string, token: string) =>
      fetchApi<void>(`/carta/${restaurantId}/items/${itemId}`, token, { method: 'DELETE' }),
  },
  reservas: {
    getAll: (restaurantId: string, token: string) =>
      fetchApi<unknown[]>(`/reservas/${restaurantId}`, token),
    confirm: (restaurantId: string, id: string, token: string) =>
      fetchApi<unknown>(`/reservas/${restaurantId}/${id}/confirm`, token, { method: 'PATCH' }),
    cancel: (restaurantId: string, id: string, token: string) =>
      fetchApi<unknown>(`/reservas/${restaurantId}/${id}/cancel`, token, { method: 'PATCH' }),
  },
  pedidos: {
    getAll: (restaurantId: string, token: string) =>
      fetchApi<unknown[]>(`/pedidos/${restaurantId}`, token),
    updateStatus: (restaurantId: string, id: string, status: string, token: string) =>
      fetchApi<unknown>(`/pedidos/${restaurantId}/${id}/status/${status}`, token, { method: 'PATCH' }),
  },
  feedback: {
    getAll: (restaurantId: string, token: string, status?: string) =>
      fetchApi<unknown[]>(`/feedback/${restaurantId}${status ? `?status=${status}` : ''}`, token),
    resolve: (restaurantId: string, id: string, token: string) =>
      fetchApi<unknown>(`/feedback/${restaurantId}/${id}/resolve`, token, { method: 'PATCH' }),
  },
  webhooks: {
    getActivity: (restaurantId: string, token: string) =>
      fetchApi<unknown[]>(`/webhooks/events/${restaurantId}`, token),
  },
};
```

- [ ] **Step 2: Create `lib/query-client.ts`**

```typescript
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 30,
      retry: 1,
    },
  },
});
```

- [ ] **Step 3: Create `components/providers.tsx`**

```typescript
'use client';

import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from '@/lib/query-client';

export function Providers({ children }: { children: React.ReactNode }) {
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}
```

- [ ] **Step 4: Wrap root layout children with Providers**

Update `app/layout.tsx` — inside `<SessionProvider>`:
```typescript
<SessionProvider session={session}>
  <Providers>{children}</Providers>
</SessionProvider>
```

- [ ] **Step 5: Commit**

```bash
git add apps/dashboard/lib/ apps/dashboard/components/providers.tsx
git commit -m "feat(dashboard): add typed API client and TanStack Query provider"
```

---

## Task 4: Dashboard Layout (Sidebar + Navigation)

**Files:**
- Create: `apps/dashboard/app/(dashboard)/layout.tsx`
- Create: `apps/dashboard/components/business/Sidebar.tsx`
- Create: `apps/dashboard/hooks/use-feedback-count.ts`

- [ ] **Step 1: Create `hooks/use-feedback-count.ts`**

```typescript
'use client';

import { useQuery } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import { api } from '@/lib/api-client';

export function useFeedbackCount() {
  const { data: session } = useSession();
  return useQuery({
    queryKey: ['feedback-count', session?.user?.restaurantId],
    queryFn: () =>
      api.feedback.getAll(
        session!.user.restaurantId!,
        session!.user.accessToken!,
        'pending',
      ),
    enabled: !!session?.user?.restaurantId,
    refetchInterval: 30_000,
    select: (data) => (Array.isArray(data) ? data.length : 0),
  });
}
```

- [ ] **Step 2: Create `components/business/Sidebar.tsx`**

```typescript
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Home, UtensilsCrossed, CalendarDays, Bell, MessageCircle, Bot, Settings } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Badge } from '@/components/ui/badge';
import { useFeedbackCount } from '@/hooks/use-feedback-count';

const nav = [
  { href: '/',           label: 'Inicio',    icon: Home },
  { href: '/carta',      label: 'Mi Carta',  icon: UtensilsCrossed },
  { href: '/reservas',   label: 'Reservas',  icon: CalendarDays },
  { href: '/pedidos',    label: 'Pedidos',   icon: Bell },
  { href: '/feedback',   label: 'Feedback',  icon: MessageCircle, badge: true },
  { href: '/bot',        label: 'Mi Bot',    icon: Bot },
  { href: '/ajustes',    label: 'Ajustes',   icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const { data: feedbackCount } = useFeedbackCount();

  return (
    <aside className="w-56 shrink-0 bg-white border-r border-gray-100 min-h-screen p-4 flex flex-col gap-1">
      <div className="flex items-center gap-2 px-2 py-3 mb-4">
        <span className="text-2xl">🍽️</span>
        <span className="font-bold text-[#F26122] text-lg">Wuarike</span>
        <span className="text-xs text-gray-400 font-semibold">Business</span>
      </div>
      {nav.map(({ href, label, icon: Icon, badge }) => (
        <Link
          key={href}
          href={href}
          className={cn(
            'flex items-center gap-3 px-3 py-2 rounded-xl text-sm font-medium transition-colors',
            pathname === href
              ? 'bg-[#FFF5F0] text-[#F26122]'
              : 'text-[#6B7280] hover:bg-gray-50 hover:text-[#1A1A1A]',
          )}
        >
          <Icon size={18} />
          <span className="flex-1">{label}</span>
          {badge && feedbackCount ? (
            <Badge className="bg-[#E8453C] text-white text-xs px-1.5 py-0 rounded-full">
              {feedbackCount}
            </Badge>
          ) : null}
        </Link>
      ))}
    </aside>
  );
}
```

- [ ] **Step 3: Create `app/(dashboard)/layout.tsx`**

```typescript
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';
import { Sidebar } from '@/components/business/Sidebar';

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const session = await auth();
  if (!session) redirect('/login');

  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <main className="flex-1 p-6 max-w-4xl">{children}</main>
    </div>
  );
}
```

- [ ] **Step 4: Commit**

```bash
git add apps/dashboard/app/\(dashboard\)/ apps/dashboard/components/ apps/dashboard/hooks/
git commit -m "feat(dashboard): add sidebar navigation with feedback badge counter"
```

---

## Task 5: Inicio Page (4 KPIs + Activity Feed)

**Files:**
- Create: `apps/dashboard/components/business/KpiCard.tsx`
- Create: `apps/dashboard/components/business/ActivityFeed.tsx`
- Create: `apps/dashboard/hooks/use-activity-poll.ts`
- Create: `apps/dashboard/app/(dashboard)/page.tsx`

- [ ] **Step 1: Create `components/business/KpiCard.tsx`**

```typescript
import { Card, CardContent } from '@/components/ui/card';

interface KpiCardProps {
  label: string;
  value: string | number;
  urgent?: boolean;
}

export function KpiCard({ label, value, urgent }: KpiCardProps) {
  return (
    <Card className="shadow-sm">
      <CardContent className="p-4">
        <p className={`text-3xl font-bold ${urgent ? 'text-[#E8453C]' : 'text-[#1A1A1A]'}`}>
          {value}
        </p>
        <p className="text-sm text-[#6B7280] mt-1">{label}</p>
      </CardContent>
    </Card>
  );
}
```

- [ ] **Step 2: Create `hooks/use-activity-poll.ts`**

```typescript
'use client';

import { useQuery } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import { api } from '@/lib/api-client';

export function useActivityPoll() {
  const { data: session } = useSession();
  return useQuery({
    queryKey: ['activity', session?.user?.restaurantId],
    queryFn: () =>
      api.webhooks.getActivity(
        session!.user.restaurantId!,
        session!.user.accessToken!,
      ),
    enabled: !!session?.user?.restaurantId,
    refetchInterval: 30_000,
  });
}
```

- [ ] **Step 3: Create `components/business/ActivityFeed.tsx`**

```typescript
'use client';

import { ShoppingBag, CalendarDays, MessageCircle, CheckCircle } from 'lucide-react';

interface ActivityEvent {
  type: 'pedido' | 'reserva' | 'feedback';
  id: string;
  summary: string;
  created_at: string;
  urgent: boolean;
}

const icons = {
  pedido: <ShoppingBag size={16} className="text-[#F26122]" />,
  reserva: <CalendarDays size={16} className="text-[#00BFA5]" />,
  feedback: <MessageCircle size={16} className="text-[#E8453C]" />,
};

function timeAgo(dateStr: string) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `hace ${mins} min`;
  return `hace ${Math.floor(mins / 60)}h`;
}

export function ActivityFeed({ events }: { events: ActivityEvent[] }) {
  if (!events.length) {
    return <p className="text-sm text-[#6B7280] py-4">Sin actividad reciente.</p>;
  }
  return (
    <ul className="divide-y divide-gray-50">
      {events.map((e) => (
        <li key={e.id} className="flex items-center gap-3 py-3">
          <span>{icons[e.type]}</span>
          <span className={`flex-1 text-sm ${e.urgent ? 'text-[#E8453C] font-semibold' : 'text-[#1A1A1A]'}`}>
            {e.summary}
          </span>
          <span className="text-xs text-[#6B7280] shrink-0">{timeAgo(e.created_at)}</span>
        </li>
      ))}
    </ul>
  );
}
```

- [ ] **Step 4: Create `app/(dashboard)/page.tsx`**

```typescript
'use client';

import { useQuery } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import { api } from '@/lib/api-client';
import { KpiCard } from '@/components/business/KpiCard';
import { ActivityFeed } from '@/components/business/ActivityFeed';
import { useActivityPoll } from '@/hooks/use-activity-poll';
import { useFeedbackCount } from '@/hooks/use-feedback-count';

function getGreeting() {
  const h = new Date().getHours();
  if (h < 12) return 'Buenos días';
  if (h < 18) return 'Buenas tardes';
  return 'Buenas noches';
}

export default function InicioPage() {
  const { data: session } = useSession();
  const { data: activity = [] } = useActivityPoll();
  const { data: feedbackCount = 0 } = useFeedbackCount();
  const { data: pedidos = [] } = useQuery({
    queryKey: ['pedidos', session?.user?.restaurantId],
    queryFn: () => api.pedidos.getAll(session!.user.restaurantId!, session!.user.accessToken!),
    enabled: !!session?.user?.restaurantId,
    refetchInterval: 30_000,
  });
  const { data: reservas = [] } = useQuery({
    queryKey: ['reservas', session?.user?.restaurantId],
    queryFn: () => api.reservas.getAll(session!.user.restaurantId!, session!.user.accessToken!),
    enabled: !!session?.user?.restaurantId,
  });

  const today = new Date().toLocaleDateString('es-PE', { weekday: 'long', day: 'numeric', month: 'long' });
  const pedidosArray = Array.isArray(pedidos) ? pedidos : [];
  const reservasArray = Array.isArray(reservas) ? reservas : [];
  const todayPedidos = pedidosArray.filter((p: { created_at: string }) =>
    new Date(p.created_at).toDateString() === new Date().toDateString(),
  );
  const todaySales = todayPedidos.reduce((sum: number, p: { total: number }) => sum + Number(p.total), 0);
  const todayReservas = reservasArray.filter(
    (r: { date: string }) => r.date === new Date().toISOString().split('T')[0],
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-[#1A1A1A]">
          {getGreeting()}, {session?.user?.name ?? 'Restaurante'} ☀️
        </h1>
        <p className="text-sm text-[#6B7280] capitalize">{today}</p>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <KpiCard label="Pedidos hoy" value={todayPedidos.length} />
        <KpiCard label="Ventas estimadas hoy" value={`S/. ${todaySales.toFixed(0)}`} />
        <KpiCard label="Reservas confirmadas" value={todayReservas.length} />
        <KpiCard label="Feedback sin resolver" value={feedbackCount} urgent={feedbackCount > 0} />
      </div>

      <div className="bg-white rounded-2xl p-4 shadow-sm">
        <h2 className="text-sm font-semibold text-[#1A1A1A] mb-3">Actividad reciente</h2>
        <ActivityFeed events={Array.isArray(activity) ? activity as never[] : []} />
      </div>
    </div>
  );
}
```

- [ ] **Step 5: Commit**

```bash
git add apps/dashboard/app/\(dashboard\)/page.tsx apps/dashboard/components/business/KpiCard.tsx apps/dashboard/components/business/ActivityFeed.tsx apps/dashboard/hooks/
git commit -m "feat(dashboard): add inicio page with 4 KPIs and 30s activity polling"
```

---

## Task 6: Carta Page (CRUD + Toggle)

**Files:**
- Create: `apps/dashboard/components/business/CartaItemRow.tsx`
- Create: `apps/dashboard/components/business/CartaWizard.tsx`
- Create: `apps/dashboard/app/(dashboard)/carta/page.tsx`
- Create: `apps/dashboard/app/(dashboard)/carta/nuevo/page.tsx`

- [ ] **Step 1: Create `components/business/CartaItemRow.tsx`**

```typescript
'use client';

import { useState } from 'react';
import { Switch } from '@/components/ui/switch';
import { Badge } from '@/components/ui/badge';
import { CartaItem } from '@warike-business/types';

interface CartaItemRowProps {
  item: CartaItem;
  onToggle: (id: string) => Promise<void>;
}

export function CartaItemRow({ item, onToggle }: CartaItemRowProps) {
  const [loading, setLoading] = useState(false);

  async function handleToggle() {
    setLoading(true);
    await onToggle(item.id);
    setLoading(false);
  }

  return (
    <div className={`flex items-center gap-3 p-3 rounded-xl ${!item.available ? 'opacity-50' : ''}`}>
      {item.image_url && (
        <img src={item.image_url} alt={item.name} className="w-12 h-12 rounded-lg object-cover shrink-0" />
      )}
      <div className="flex-1 min-w-0">
        <p className="text-sm font-semibold text-[#1A1A1A] truncate">
          {item.name}
          {item.is_chef_recommendation && <span className="ml-1 text-[#FFB800]">⭐</span>}
        </p>
        <p className="text-sm text-[#6B7280]">S/. {Number(item.price).toFixed(2)}</p>
      </div>
      {!item.available && (
        <Badge variant="secondary" className="text-xs shrink-0">Agotado</Badge>
      )}
      <Switch
        checked={item.available}
        onCheckedChange={handleToggle}
        disabled={loading}
        className="shrink-0 data-[state=checked]:bg-[#F26122]"
      />
    </div>
  );
}
```

- [ ] **Step 2: Create `app/(dashboard)/carta/page.tsx`**

```typescript
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import Link from 'next/link';
import { Plus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { CartaItemRow } from '@/components/business/CartaItemRow';
import { api } from '@/lib/api-client';
import { CartaItem, CartaCategory } from '@warike-business/types';

export default function CartaPage() {
  const { data: session } = useSession();
  const qc = useQueryClient();
  const rid = session?.user?.restaurantId ?? '';
  const tok = session?.user?.accessToken ?? '';

  const { data: items = [] } = useQuery<CartaItem[]>({
    queryKey: ['carta', rid],
    queryFn: () => api.carta.getAll(rid, tok),
    enabled: !!rid,
  });

  const { data: categories = [] } = useQuery<CartaCategory[]>({
    queryKey: ['carta-categories', rid],
    queryFn: () => api.carta.getCategories(rid, tok),
    enabled: !!rid,
  });

  const toggleMutation = useMutation({
    mutationFn: (itemId: string) => api.carta.toggle(rid, itemId, tok),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['carta', rid] }),
  });

  const itemsByCategory = categories.map((cat) => ({
    category: cat,
    items: items.filter((i) => i.category_id === cat.id),
  }));

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-bold text-[#1A1A1A]">Mi Carta</h1>
        <Link href="/carta/nuevo">
          <Button className="bg-[#F26122] hover:bg-[#d9541a] text-white gap-2 rounded-xl">
            <Plus size={16} /> Agregar plato
          </Button>
        </Link>
      </div>

      <Accordion type="multiple" className="space-y-2">
        {itemsByCategory.map(({ category, items: catItems }) => (
          <AccordionItem key={category.id} value={category.id} className="bg-white rounded-2xl px-4 border-0 shadow-sm">
            <AccordionTrigger className="text-sm font-semibold text-[#1A1A1A] hover:no-underline">
              {category.emoji} {category.name}
              <span className="ml-auto mr-2 text-xs text-[#6B7280] font-normal">{catItems.length} platos</span>
            </AccordionTrigger>
            <AccordionContent className="divide-y divide-gray-50">
              {catItems.length === 0 && (
                <p className="text-sm text-[#6B7280] py-3">Sin platos en esta categoría.</p>
              )}
              {catItems.map((item) => (
                <CartaItemRow
                  key={item.id}
                  item={item}
                  onToggle={(id) => toggleMutation.mutateAsync(id)}
                />
              ))}
            </AccordionContent>
          </AccordionItem>
        ))}
      </Accordion>
    </div>
  );
}
```

- [ ] **Step 3: Create `app/(dashboard)/carta/nuevo/page.tsx`** (3-step wizard)

```typescript
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { api } from '@/lib/api-client';
import { CartaCategory } from '@warike-business/types';

const COMMON_ALLERGENS = ['Pescado', 'Mariscos', 'Gluten', 'Lácteos', 'Huevo', 'Soya', 'Maní', 'Cebolla', 'Ají'];

type Step = 1 | 2 | 3;

export default function NuevoPlatoPage() {
  const router = useRouter();
  const { data: session } = useSession();
  const qc = useQueryClient();
  const rid = session?.user?.restaurantId ?? '';
  const tok = session?.user?.accessToken ?? '';
  const [step, setStep] = useState<Step>(1);
  const [form, setForm] = useState({
    name: '', price: '', category_id: '', description: '',
    allergens: [] as string[],
    is_chef_recommendation: false, chef_note: '', image_url: '',
  });

  const { data: categories = [] } = useQuery<CartaCategory[]>({
    queryKey: ['carta-categories', rid],
    queryFn: () => api.carta.getCategories(rid, tok),
    enabled: !!rid,
  });

  const createMutation = useMutation({
    mutationFn: () => api.carta.create(rid, tok, {
      ...form,
      price: parseFloat(form.price),
    }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['carta', rid] });
      router.push('/carta');
    },
  });

  return (
    <div className="space-y-6 max-w-lg">
      <div>
        <h1 className="text-xl font-bold text-[#1A1A1A]">Agregar plato</h1>
        <div className="flex gap-2 mt-3">
          {([1, 2, 3] as Step[]).map((s) => (
            <div
              key={s}
              className={`h-1.5 flex-1 rounded-full transition-colors ${step >= s ? 'bg-[#F26122]' : 'bg-gray-200'}`}
            />
          ))}
        </div>
        <p className="text-xs text-[#6B7280] mt-1">
          Paso {step} de 3 — {['Nombre y precio', 'Alérgenos', 'Foto y nota'][step - 1]}
        </p>
      </div>

      {step === 1 && (
        <div className="space-y-4">
          <div className="space-y-1">
            <Label>Nombre del plato *</Label>
            <Input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} placeholder="Ceviche Clásico" />
          </div>
          <div className="space-y-1">
            <Label>Precio (S/.) *</Label>
            <Input type="number" value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })} placeholder="28.00" />
          </div>
          <div className="space-y-1">
            <Label>Categoría *</Label>
            <Select value={form.category_id} onValueChange={(v) => setForm({ ...form, category_id: v })}>
              <SelectTrigger><SelectValue placeholder="Selecciona una categoría" /></SelectTrigger>
              <SelectContent>
                {categories.map((c) => (
                  <SelectItem key={c.id} value={c.id}>{c.emoji} {c.name}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1">
            <Label>Descripción</Label>
            <Textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} rows={3} />
          </div>
          <Button
            className="w-full bg-[#F26122] hover:bg-[#d9541a] text-white"
            disabled={!form.name || !form.price || !form.category_id}
            onClick={() => setStep(2)}
          >
            Siguiente
          </Button>
        </div>
      )}

      {step === 2 && (
        <div className="space-y-4">
          <Label>Alérgenos presentes</Label>
          <div className="flex flex-wrap gap-2">
            {COMMON_ALLERGENS.map((a) => {
              const selected = form.allergens.includes(a);
              return (
                <button
                  key={a}
                  onClick={() => setForm({
                    ...form,
                    allergens: selected
                      ? form.allergens.filter((x) => x !== a)
                      : [...form.allergens, a],
                  })}
                  className={`px-3 py-1 rounded-full text-sm border transition-colors ${
                    selected
                      ? 'bg-[#E8453C] border-[#E8453C] text-white'
                      : 'bg-white border-gray-200 text-[#6B7280]'
                  }`}
                >
                  {a}
                </button>
              );
            })}
          </div>
          <div className="flex gap-3">
            <Button variant="outline" onClick={() => setStep(1)} className="flex-1">Atrás</Button>
            <Button className="flex-1 bg-[#F26122] hover:bg-[#d9541a] text-white" onClick={() => setStep(3)}>
              Siguiente
            </Button>
          </div>
        </div>
      )}

      {step === 3 && (
        <div className="space-y-4">
          <div className="space-y-1">
            <Label>URL de foto (opcional)</Label>
            <Input value={form.image_url} onChange={(e) => setForm({ ...form, image_url: e.target.value })} placeholder="https://..." />
          </div>
          <div className="flex items-center justify-between">
            <Label>¿Recomendación del chef?</Label>
            <Switch
              checked={form.is_chef_recommendation}
              onCheckedChange={(v) => setForm({ ...form, is_chef_recommendation: v })}
              className="data-[state=checked]:bg-[#F26122]"
            />
          </div>
          {form.is_chef_recommendation && (
            <div className="space-y-1">
              <Label>Nota del chef</Label>
              <Textarea
                value={form.chef_note}
                onChange={(e) => setForm({ ...form, chef_note: e.target.value })}
                rows={2}
                placeholder="El plato estrella de la casa..."
              />
            </div>
          )}
          <div className="flex gap-3">
            <Button variant="outline" onClick={() => setStep(2)} className="flex-1">Atrás</Button>
            <Button
              className="flex-1 bg-[#F26122] hover:bg-[#d9541a] text-white"
              disabled={createMutation.isPending}
              onClick={() => createMutation.mutate()}
            >
              {createMutation.isPending ? 'Guardando...' : 'Guardar plato'}
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
```

- [ ] **Step 4: Commit**

```bash
git add apps/dashboard/app/\(dashboard\)/carta/ apps/dashboard/components/business/CartaItemRow.tsx
git commit -m "feat(dashboard): add carta page with accordion, instant toggle, and 3-step wizard"
```

---

## Task 7: Reservas, Pedidos, Feedback, and Bot Pages

**Files:**
- Create: `apps/dashboard/components/business/ReservaCard.tsx`
- Create: `apps/dashboard/components/business/PedidoCard.tsx`
- Create: `apps/dashboard/components/business/FeedbackCard.tsx`
- Create: `apps/dashboard/components/business/BotPreview.tsx`
- Create: `apps/dashboard/app/(dashboard)/reservas/page.tsx`
- Create: `apps/dashboard/app/(dashboard)/pedidos/page.tsx`
- Create: `apps/dashboard/app/(dashboard)/feedback/page.tsx`
- Create: `apps/dashboard/app/(dashboard)/bot/page.tsx`

- [ ] **Step 1: Create `components/business/ReservaCard.tsx`**

```typescript
'use client';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

interface Reserva {
  id: string; customer_name: string; party_size: number;
  date: string; time: string; status: string; customer_phone: string;
}

const statusColors: Record<string, string> = {
  pending: 'bg-[#FFB800] text-white',
  confirmed: 'bg-[#00BFA5] text-white',
  cancelled: 'bg-gray-300 text-gray-600',
};

interface ReservaCardProps {
  reserva: Reserva;
  onConfirm: (id: string) => void;
  onCancel: (id: string) => void;
}

export function ReservaCard({ reserva, onConfirm, onCancel }: ReservaCardProps) {
  return (
    <div className="bg-white rounded-2xl p-4 shadow-sm flex items-start justify-between gap-4">
      <div className="space-y-1">
        <div className="flex items-center gap-2">
          <p className="font-semibold text-[#1A1A1A]">{reserva.customer_name}</p>
          <Badge className={statusColors[reserva.status] ?? ''}>{reserva.status}</Badge>
        </div>
        <p className="text-sm text-[#6B7280]">
          📅 {reserva.date} a las {reserva.time} — {reserva.party_size} personas
        </p>
        <p className="text-sm text-[#6B7280]">📞 {reserva.customer_phone}</p>
      </div>
      {reserva.status === 'pending' && (
        <div className="flex gap-2 shrink-0">
          <Button size="sm" className="bg-[#00BFA5] hover:bg-[#009e89] text-white" onClick={() => onConfirm(reserva.id)}>
            Confirmar
          </Button>
          <Button size="sm" variant="outline" onClick={() => onCancel(reserva.id)}>
            Cancelar
          </Button>
        </div>
      )}
    </div>
  );
}
```

- [ ] **Step 2: Create `components/business/PedidoCard.tsx`**

```typescript
'use client';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';

interface PedidoItem { item_name: string; quantity: number; unit_price: number; }
interface Pedido { id: string; items: PedidoItem[]; total: number; status: string; channel: string; created_at: string; }

const statusColors: Record<string, string> = {
  pending: 'bg-[#FFB800] text-white',
  confirmed: 'bg-[#00BFA5] text-white',
  preparing: 'bg-blue-400 text-white',
  ready: 'bg-[#F26122] text-white',
  cancelled: 'bg-gray-300 text-gray-600',
};

const nextStatus: Record<string, string> = {
  pending: 'confirmed', confirmed: 'preparing', preparing: 'ready',
};

interface PedidoCardProps {
  pedido: Pedido;
  onUpdateStatus: (id: string, status: string) => void;
}

export function PedidoCard({ pedido, onUpdateStatus }: PedidoCardProps) {
  const next = nextStatus[pedido.status];
  return (
    <div className="bg-white rounded-2xl p-4 shadow-sm">
      <div className="flex items-center justify-between mb-2">
        <Badge className={statusColors[pedido.status] ?? ''}>{pedido.status}</Badge>
        <span className="text-xs text-[#6B7280]">{pedido.channel}</span>
      </div>
      <ul className="text-sm text-[#1A1A1A] space-y-0.5 mb-3">
        {pedido.items.map((item, i) => (
          <li key={i}>{item.quantity}x {item.item_name} — S/. {(item.quantity * item.unit_price).toFixed(2)}</li>
        ))}
      </ul>
      <div className="flex items-center justify-between">
        <p className="font-bold text-[#1A1A1A]">Total: S/. {Number(pedido.total).toFixed(2)}</p>
        {next && (
          <Button size="sm" className="bg-[#F26122] hover:bg-[#d9541a] text-white" onClick={() => onUpdateStatus(pedido.id, next)}>
            Marcar como {next}
          </Button>
        )}
      </div>
    </div>
  );
}
```

- [ ] **Step 3: Create `components/business/FeedbackCard.tsx`**

```typescript
'use client';

import { Button } from '@/components/ui/button';

interface Feedback {
  id: string; message: string; channel: string; created_at: string;
  status: string; customer_name?: string; anonymous: boolean;
}

function timeAgo(dateStr: string) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return `hace ${mins} min`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `hace ${hrs}h`;
  return `hace ${Math.floor(hrs / 24)} días`;
}

interface FeedbackCardProps {
  feedback: Feedback;
  onResolve: (id: string) => void;
}

export function FeedbackCard({ feedback, onResolve }: FeedbackCardProps) {
  const isResolved = feedback.status === 'resolved';
  return (
    <div className={`rounded-2xl p-4 shadow-sm border-l-4 ${isResolved ? 'bg-white border-gray-200' : 'bg-white border-[#E8453C]'}`}>
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold text-[#6B7280] uppercase">{feedback.channel}</span>
          {feedback.customer_name && !feedback.anonymous && (
            <span className="text-xs text-[#1A1A1A]">· {feedback.customer_name}</span>
          )}
        </div>
        <span className="text-xs text-[#6B7280]">{timeAgo(feedback.created_at)}</span>
      </div>
      <p className="text-sm text-[#1A1A1A] line-clamp-3">{feedback.message}</p>
      {!isResolved && (
        <Button
          size="sm"
          variant="outline"
          className="mt-3 text-[#00BFA5] border-[#00BFA5] hover:bg-[#e6faf8]"
          onClick={() => onResolve(feedback.id)}
        >
          ✓ Marcar como resuelto
        </Button>
      )}
    </div>
  );
}
```

- [ ] **Step 4: Create `app/(dashboard)/reservas/page.tsx`**

```typescript
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import { api } from '@/lib/api-client';
import { ReservaCard } from '@/components/business/ReservaCard';

export default function ReservasPage() {
  const { data: session } = useSession();
  const qc = useQueryClient();
  const rid = session?.user?.restaurantId ?? '';
  const tok = session?.user?.accessToken ?? '';

  const { data: reservas = [] } = useQuery<unknown[]>({
    queryKey: ['reservas', rid],
    queryFn: () => api.reservas.getAll(rid, tok),
    enabled: !!rid,
  });

  const confirmMutation = useMutation({
    mutationFn: (id: string) => api.reservas.confirm(rid, id, tok),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['reservas', rid] }),
  });
  const cancelMutation = useMutation({
    mutationFn: (id: string) => api.reservas.cancel(rid, id, tok),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['reservas', rid] }),
  });

  const pending = (reservas as {status:string}[]).filter((r) => r.status === 'pending');
  const confirmed = (reservas as {status:string}[]).filter((r) => r.status === 'confirmed');

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-bold text-[#1A1A1A]">Reservas</h1>
      {pending.length > 0 && (
        <div>
          <h2 className="text-sm font-semibold text-[#FFB800] mb-3">⏳ Pendientes de confirmación ({pending.length})</h2>
          <div className="space-y-3">
            {pending.map((r) => (
              <ReservaCard key={(r as {id:string}).id} reserva={r as never}
                onConfirm={(id) => confirmMutation.mutate(id)}
                onCancel={(id) => cancelMutation.mutate(id)} />
            ))}
          </div>
        </div>
      )}
      <div>
        <h2 className="text-sm font-semibold text-[#00BFA5] mb-3">✅ Confirmadas ({confirmed.length})</h2>
        <div className="space-y-3">
          {confirmed.map((r) => (
            <ReservaCard key={(r as {id:string}).id} reserva={r as never}
              onConfirm={(id) => confirmMutation.mutate(id)}
              onCancel={(id) => cancelMutation.mutate(id)} />
          ))}
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 5: Create `app/(dashboard)/pedidos/page.tsx`**

```typescript
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import { api } from '@/lib/api-client';
import { PedidoCard } from '@/components/business/PedidoCard';

export default function PedidosPage() {
  const { data: session } = useSession();
  const qc = useQueryClient();
  const rid = session?.user?.restaurantId ?? '';
  const tok = session?.user?.accessToken ?? '';

  const { data: pedidos = [] } = useQuery<unknown[]>({
    queryKey: ['pedidos', rid],
    queryFn: () => api.pedidos.getAll(rid, tok),
    enabled: !!rid,
    refetchInterval: 30_000,
  });

  const statusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      api.pedidos.updateStatus(rid, id, status, tok),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['pedidos', rid] }),
  });

  const active = (pedidos as {status:string}[]).filter((p) => !['ready','cancelled'].includes(p.status));
  const done = (pedidos as {status:string}[]).filter((p) => p.status === 'ready' || p.status === 'cancelled');

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-bold text-[#1A1A1A]">Pedidos</h1>
      <div>
        <h2 className="text-sm font-semibold text-[#F26122] mb-3">🛎️ Activos ({active.length})</h2>
        <div className="space-y-3">
          {active.map((p) => (
            <PedidoCard key={(p as {id:string}).id} pedido={p as never}
              onUpdateStatus={(id, status) => statusMutation.mutate({ id, status })} />
          ))}
          {active.length === 0 && <p className="text-sm text-[#6B7280]">Sin pedidos activos.</p>}
        </div>
      </div>
      <div>
        <h2 className="text-sm font-semibold text-[#6B7280] mb-3">Historial reciente</h2>
        <div className="space-y-3">
          {done.slice(0, 5).map((p) => (
            <PedidoCard key={(p as {id:string}).id} pedido={p as never}
              onUpdateStatus={(id, status) => statusMutation.mutate({ id, status })} />
          ))}
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 6: Create `app/(dashboard)/feedback/page.tsx`**

```typescript
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSession } from 'next-auth/react';
import { api } from '@/lib/api-client';
import { FeedbackCard } from '@/components/business/FeedbackCard';

export default function FeedbackPage() {
  const { data: session } = useSession();
  const qc = useQueryClient();
  const rid = session?.user?.restaurantId ?? '';
  const tok = session?.user?.accessToken ?? '';

  const { data: feedbacks = [] } = useQuery<unknown[]>({
    queryKey: ['feedback', rid],
    queryFn: () => api.feedback.getAll(rid, tok),
    enabled: !!rid,
    refetchInterval: 30_000,
  });

  const resolveMutation = useMutation({
    mutationFn: (id: string) => api.feedback.resolve(rid, id, tok),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['feedback', rid] }),
  });

  const pending = (feedbacks as {status:string}[]).filter((f) => f.status === 'pending');
  const resolved = (feedbacks as {status:string}[]).filter((f) => f.status === 'resolved');

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-bold text-[#1A1A1A]">Feedback Privado</h1>
      <p className="text-xs text-[#6B7280] bg-[#FFF5F0] rounded-xl px-3 py-2">
        🔒 Este feedback es completamente privado. Nunca se publica en Wuarike.
      </p>
      <div>
        <h2 className="text-sm font-semibold text-[#E8453C] mb-3">🔴 Sin resolver ({pending.length})</h2>
        <div className="space-y-3">
          {pending.map((f) => (
            <FeedbackCard key={(f as {id:string}).id} feedback={f as never}
              onResolve={(id) => resolveMutation.mutate(id)} />
          ))}
          {pending.length === 0 && <p className="text-sm text-[#6B7280]">No hay feedback pendiente. ✨</p>}
        </div>
      </div>
      <div>
        <h2 className="text-sm font-semibold text-[#6B7280] mb-3">✅ Resueltos ({resolved.length})</h2>
        <div className="space-y-3">
          {resolved.slice(0, 10).map((f) => (
            <FeedbackCard key={(f as {id:string}).id} feedback={f as never}
              onResolve={(id) => resolveMutation.mutate(id)} />
          ))}
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 7: Create `components/business/BotPreview.tsx`**

```typescript
'use client';

interface BotPreviewProps { name: string; greeting: string; }

export function BotPreview({ name, greeting }: BotPreviewProps) {
  return (
    <div className="bg-[#F7F8FA] rounded-2xl p-4 space-y-3">
      <p className="text-xs font-semibold text-[#6B7280] uppercase">Vista previa del bot</p>
      <div className="flex items-start gap-2">
        <div className="w-8 h-8 rounded-full bg-[#F26122] flex items-center justify-center text-white text-sm shrink-0">
          🤖
        </div>
        <div className="bg-white rounded-2xl rounded-tl-none px-4 py-2 shadow-sm max-w-xs">
          <p className="text-xs font-semibold text-[#F26122] mb-0.5">{name || 'Mi Bot'}</p>
          <p className="text-sm text-[#1A1A1A]">{greeting || '¡Hola! ¿En qué te puedo ayudar?'}</p>
        </div>
      </div>
    </div>
  );
}
```

- [ ] **Step 8: Create `app/(dashboard)/bot/page.tsx`**

```typescript
'use client';

import { useState } from 'react';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Button } from '@/components/ui/button';
import { BotPreview } from '@/components/business/BotPreview';

export default function BotPage() {
  const [form, setForm] = useState({
    name: '', tone: 'amigable', greeting: '',
  });
  const [saved, setSaved] = useState(false);

  function handleSave() {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  }

  return (
    <div className="space-y-6 max-w-lg">
      <h1 className="text-xl font-bold text-[#1A1A1A]">Configurar Mi Bot</h1>
      <div className="space-y-4">
        <div className="space-y-1">
          <Label>Nombre del mesero digital</Label>
          <Input
            value={form.name}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            placeholder="Carlitos"
            maxLength={30}
          />
        </div>
        <div className="space-y-1">
          <Label>Tono de conversación</Label>
          <Select value={form.tone} onValueChange={(v) => setForm({ ...form, tone: v })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="amigable">😊 Amigable</SelectItem>
              <SelectItem value="formal">🤝 Formal</SelectItem>
              <SelectItem value="divertido">🎉 Divertido</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1">
          <Label>Mensaje de bienvenida</Label>
          <Textarea
            value={form.greeting}
            onChange={(e) => setForm({ ...form, greeting: e.target.value })}
            rows={3}
            maxLength={200}
            placeholder="¡Hola! Soy Carlitos, el mesero de El Rincón Criollo 🍽️"
          />
          <p className="text-xs text-[#6B7280]">{form.greeting.length}/200</p>
        </div>
        <BotPreview name={form.name} greeting={form.greeting} />
        <Button
          onClick={handleSave}
          className="w-full bg-[#F26122] hover:bg-[#d9541a] text-white"
        >
          {saved ? '¡Guardado! ✓' : 'Guardar configuración'}
        </Button>
      </div>
    </div>
  );
}
```

Note: This page currently saves state locally. Connecting it to `PATCH /restaurants/:id` (add `RestaurantsModule` to bot-gateway if needed) is a straightforward extension.

- [ ] **Step 9: Commit**

```bash
git add apps/dashboard/app/\(dashboard\)/reservas/ apps/dashboard/app/\(dashboard\)/pedidos/ apps/dashboard/app/\(dashboard\)/feedback/ apps/dashboard/app/\(dashboard\)/bot/ apps/dashboard/components/business/
git commit -m "feat(dashboard): add reservas, pedidos, feedback, and bot configuration pages"
```

---

## Task 8: Final Build Verification

- [ ] **Step 1: Run TypeScript check**

```bash
cd apps/dashboard
npx tsc --noEmit
```

Expected: 0 errors.

- [ ] **Step 2: Run Next.js build**

```bash
pnpm run build
```

Expected: Build completes successfully. All routes listed without errors.

- [ ] **Step 3: Start dev server and verify all pages load**

```bash
pnpm run dev
```

Visit in browser:
- `http://localhost:3000/login` — login form renders
- `http://localhost:3000/` — KPI cards + activity feed (after login)
- `http://localhost:3000/carta` — accordion with category + items
- `http://localhost:3000/carta/nuevo` — 3-step wizard
- `http://localhost:3000/reservas` — reservas cards
- `http://localhost:3000/pedidos` — pedidos with status buttons
- `http://localhost:3000/feedback` — private feedback cards + lock notice
- `http://localhost:3000/bot` — bot config + live preview

Expected: All pages render without console errors.

- [ ] **Step 4: Final commit**

```bash
cd d:/Github/warike_business
git add .
git commit -m "feat: complete Plan 2 — Next.js dashboard with all screens, ready for Plan 3 (n8n)"
```

---

## Next Step

Plan 3 covers the n8n AI workflows (`mesero-core`, `mesero-pedidos`, `mesero-reservas`, `mesero-feedback`). These are JSON workflow files that connect to the bot-gateway endpoints built in Plan 1 and the LLM (Claude claude-sonnet-4-6).
