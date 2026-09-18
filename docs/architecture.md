# Architecture

## Goals

- Serve many branded mobile applications from one platform with strict tenant
  isolation.
- Handle real money safely: every coin movement is atomic, idempotent,
  auditable and integer-only.
- Keep call state and billing server-authoritative so clients can never
  under-pay, over-charge or desynchronise.
- Scale horizontally: stateless API replicas, shared PostgreSQL and Redis,
  background work in queues.

## System overview

```
┌──────────────┐   HTTPS/JSON    ┌───────────────────────────┐
│ Flutter apps │ ──────────────▶ │  API (NestJS, N replicas) │
│ (per tenant) │ ◀── push (FCM)  │  guards → controllers →   │
└──────────────┘                 │  services → Prisma/Redis  │
┌──────────────┐   server-side   │                           │
│ Admin console│ ──────────────▶ │  BullMQ workers (same     │
│ (Next.js)    │                 │  image, QUEUE_WORKERS_    │
└──────────────┘                 │  ENABLED toggles role)    │
                                 └─────┬──────────────┬──────┘
                 ┌─────────────────────┘              └──────────────┐
        ┌────────▼────────┐                                  ┌───────▼──────┐
        │ PostgreSQL 16   │  durable truth: tenants, users,   │ Redis 7      │
        │ (Prisma 7)      │  wallets, ledger, calls, audit    │ cache, locks,│
        └─────────────────┘                                  │ presence,    │
                                                             │ rate limits, │
   External: Firebase Auth (identity), Agora RTC (media),    │ queues       │
   FCM (push), Google Play / App Store / web PSP (payments)  └──────────────┘
```

The API is a **modular monolith**: infrastructure modules are global, feature
modules import only what they need, and each module could later be extracted
into its own service without changing its public surface.

## Request pipeline (API)

Every HTTP request passes through the same chain, in order:

1. `pino-http` assigns or echoes `X-Request-Id`; sensitive headers are
   redacted from logs.
2. `Helmet` security headers, CORS allow-list (mobile apps send no `Origin`;
   browsers must be listed in `CORS_ORIGINS`).
3. **ThrottlerGuard** — fixed-window rate limit with Redis storage so limits are
   shared across replicas.
4. **TenantGuard** — resolves `X-Tenant-Key` to a `TenantContext` (Redis cached,
   60 s), rejects unknown or suspended tenants. Admin routes may omit it;
   `@RequireTenant()` forces it on public routes such as `/tenant/config`.
5. **AuthGuard** — verifies the bearer token via the configured
   `TokenVerifier` (Firebase Admin SDK, or a dev verifier that refuses to run
   in production) and resolves a `Principal`:
   - `UserPrincipal` for tenant-scoped app users (auto-provisioned with a
     wallet on first login, blocked users rejected);
   - `AdminPrincipal` for `@AdminScope()` routes, with roles and permissions
     loaded from the database — token claims are never trusted for
     authorization.
6. **PermissionsGuard** — enforces `@RequirePermissions(...)`.
7. Controller → `ZodValidationPipe` on body/query/params → service.
8. `HttpMetricsInterceptor` records latency per route template.
9. `AllExceptionsFilter` converts every error into the `ApiErrorBody` envelope
   (`statusCode`, stable `code`, `message`, `requestId`) and logs 5xx with the
   request id. Unknown routes, including those outside the `/api` prefix,
   return the same envelope.

Routes are versioned by URI (`/api/v1/...`); health, metrics and the root info
endpoint are version-neutral.

## Multi-tenancy

- A **tenant** is one branded application (`tenants` table). Every business
  row carries `tenantId`; unique constraints and indexes are tenant-prefixed.
- Isolation is logical (shared schema). Services receive the tenant from the
  request context and must scope every query by it; the ledger and call
  primitives take `tenantId` explicitly and verify it in their row locks.
- Configuration per tenant lives in validated JSON columns: `branding`,
  `legal`, `featureFlags`, `pricing`. Parsing failures are treated as corrupt
  configuration and fail loudly rather than silently falling back to defaults.
- Callers belong to one home tenant but can be exposed to others via
  `sharedAcrossTenants` plus an explicit `CallerTenantVisibility` allow-list.
- Admins are either platform-wide (`SUPER_ADMIN`, `tenantId = null`) or bound
  to a tenant (`TENANT_ADMIN`); tenant admins cannot act outside their tenant
  and cannot change tenant status.

## Financial model

- **Coins are integers** (`BIGINT` in the database, `number`/`bigint` in code
  with `assertPositiveCoinAmount`). No floats anywhere.
- Each user has a `USER` wallet; each caller a `CALLER_EARNINGS` wallet; each
  tenant a `PLATFORM_REVENUE` wallet. Wallets hold a materialised `balance`,
  a `heldBalance` reserved by active calls, and a `version`.
- `wallet_transactions` is an **append-only ledger**. Rows carry direction,
  absolute amount, `balanceBefore`/`balanceAfter`, a typed reference
  (payment order, call, billing interval, payout, admin action) and an
  idempotency key unique per tenant.
- `WalletLedgerService.apply(tx, input)` is the only primitive that moves
  coins. It runs inside `PrismaService.financialTransaction` (SERIALIZABLE),
  locks the wallet row (`SELECT … FOR UPDATE`), replays idempotent duplicates
  without moving coins, refuses to take a balance negative and writes the
  ledger row and balance update atomically.
- Payments credit coins exactly once: the `PaymentOrder` row moves to
  `COMPLETED` in the same transaction that writes its `walletTransactionId`.
  Provider notifications are stored in `payment_events` with a unique
  `(provider, providerEventId)` before processing, so replays are detected.
- Commission is split with `splitCommission(amount, bps)`; the caller share
  and platform share always sum to the charge.

## Call model

- `CallState` and `CALL_STATE_TRANSITIONS` in `@bebu/shared` define the only
  legal moves (REQUESTED → RINGING → ACCEPTED → CONNECTING → CONNECTED →
  BILLING → ENDING → COMPLETED, plus terminal failure states).
- `CallStateMachineService.transition` locks the call row, checks the
  caller-observed `stateVersion` (optimistic concurrency), validates the
  transition, stamps timestamps and appends a `CallStateTransition` audit row.
- Billing is per started interval (`CALL_TIMEOUTS.billingIntervalSeconds`);
  each interval produces a `CallBillingInterval` linking the user charge and
  caller earning ledger rows. The server checks balance every
  `balanceCheckSeconds` and ends calls with `INSUFFICIENT_BALANCE`.
- Media goes through Agora. The API issues short-lived RTC tokens for opaque
  channel names; the App Certificate never reaches a client.
- Live presence, availability rankings and busy markers live in Redis
  (`PresenceKey` layout) with TTLs tied to client heartbeats; PostgreSQL stays
  the durable truth.
- Timers (ring timeout, connect timeout, billing ticks) run as delayed jobs on
  the `call-lifecycle` queue so they survive API restarts.

## Background work

BullMQ queues on the shared Redis connection: `notifications`,
`reengagement`, `call-lifecycle`, `payments`, `analytics`. Default job options
retry five times with exponential backoff. Any API replica can enqueue;
replicas with `QUEUE_WORKERS_ENABLED=true` also process. Redis must run with
`maxmemory-policy noeviction` (set in the compose file) so jobs are never
dropped.

## Re-engagement

`evaluateReengagement` is a pure function that decides whether a domain event
(e.g. favourite caller online, low balance, missed call) may become a push
notification. It applies tenant rules, device availability, user category
opt-outs, quiet hours, per-event cooldowns and daily frequency caps. Every
decision — sent or suppressed with a reason — is persisted in
`notification_logs` so caps and tuning are based on real history.

## Observability

- Structured JSON logs (pretty in dev) with `requestId` and `tenantId`.
- `/metrics` exposes process metrics plus `http_request_duration_seconds`,
  call, payment, wallet and notification counters.
- `/health/live` never touches dependencies; `/health/ready` checks PostgreSQL,
  Redis and memory and returns 503 with a detailed report on failure.

## Shared package

`@bebu/shared` is consumed by the API and the admin console and mirrors the
contracts the Flutter app implements in Dart: enums, state tables, coin
arithmetic, Zod schemas for every input, stable `ErrorCode`s and the
`ApiErrorBody` envelope. Changing a contract means changing it here first.
