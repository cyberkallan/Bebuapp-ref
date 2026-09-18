# bebu platform

Multi-tenant SaaS platform for real-time 1-to-1 voice and video calling with
coin-based billing. One backend and one admin console serve many branded mobile
applications (tenants), each with its own users, callers, pricing and feature
flags. Public site: [bebuapp.in](https://bebuapp.in/).

This repository is the **foundation stage**: the architecture, data model,
security pipeline and financial primitives are in place and tested; the
product features that sit on top (payments, live calling, matching,
re-engagement) are deliberately not implemented yet. See
[What is implemented](#what-is-implemented) for an honest inventory.

## Repository layout

```
apps/
  api/        NestJS modular monolith (TypeScript, Prisma 7, PostgreSQL, Redis, BullMQ)
  admin/      Next.js 16 operations console (Tailwind 4, shadcn/ui)
  mobile/     Flutter white-label client (one build per tenant)
  landing/    Static marketing site + Android APK download page (Vite)
packages/
  shared/     Domain enums, call state machine, coin arithmetic, Zod schemas, error codes
  config/     Shared tsconfig and ESLint presets
infra/
  docker/     docker compose for local Postgres + Redis
  deploy/     single-VPS production stack (Docker Compose + Caddy HTTPS, console at /admin)
  scripts/    bootstrap and readiness helpers
releases/     signed test APKs + checksums
docs/         architecture, development, security, deployment
```

## Quick start

Prerequisites: Node 24 (`.nvmrc`), pnpm 10+, Docker (or a local Postgres 16 and
Redis 7).

```bash
corepack enable                       # provides pnpm
./infra/scripts/bootstrap.sh          # .env, deps, infra, migrations, seed
pnpm dev                              # API on :4180, admin on :4181
```

Then open <http://127.0.0.1:4181>, sign in with the seeded super admin
(`dev-super-admin` / `admin@bebuapp.in`; development auth mode only) and you
will see live API health and the seeded `bebu` application.

Useful endpoints while the API runs:

| Endpoint                                | Purpose                                   |
| --------------------------------------- | ----------------------------------------- |
| `GET /health/live`, `/health/ready`     | Kubernetes probes                         |
| `GET /health`                           | Full dependency report                    |
| `GET /metrics`                          | Prometheus scrape (optional bearer token) |
| `GET /api/v1/tenant/config`             | Public branding/flags (`X-Tenant-Key`)    |
| `GET /api/v1/users/me`, `/api/v1/wallet`| Signed-in user profile and balance        |
| `GET /api/v1/admin/me`, `/admin/tenants`| Admin identity and tenant management      |

## Everyday commands

```bash
pnpm dev            # API + admin with hot reload
pnpm build          # all packages and apps
pnpm typecheck      # strict TypeScript across the monorepo
pnpm lint           # ESLint (type-aware)
pnpm test           # unit tests (shared + api)
pnpm test:e2e       # API integration tests against bebu_test database
pnpm db:migrate     # create a migration from schema changes (dev)
pnpm db:seed        # idempotent dev seed
pnpm infra:up|down  # local Postgres + Redis
```

## What is implemented

Verified by tests and manual runs in this stage:

- **Monorepo tooling**: pnpm workspaces, strict TypeScript, type-aware ESLint,
  Prettier, Vitest.
- **Shared domain package**: tenant/role/permission model, server-side call
  state machine with transition table, integer-only coin arithmetic with
  commission splitting, Zod schemas, stable error codes.
- **API platform core**: Zod-validated configuration, structured pino logging
  with request ids, uniform JSON error envelope (including 404s outside the
  prefix), Helmet, CORS allow-list, Redis-backed rate limiting, health probes,
  Prometheus metrics, graceful shutdown.
- **Data model**: Prisma schema and initial migration for tenants, users,
  devices, admin accounts, caller profiles and cross-tenant visibility, wallets
  with an append-only ledger, coin packages, payment orders and events, payout
  requests, calls with billing intervals and state-transition audit, ratings,
  reports, audit logs and notification logs.
- **Tenancy and auth**: `X-Tenant-Key` resolution with Redis cache and status
  enforcement, Firebase ID-token verification (plus a dev verifier that cannot
  run in production), user auto-provisioning with wallet creation, admin
  principals with database-sourced roles/permissions, permission guard, audit
  log service.
- **Financial primitive**: `WalletLedgerService.apply` — row-locked, idempotent,
  never-negative ledger posting inside SERIALIZABLE transactions; proven under
  concurrent debits in e2e tests.
- **Call primitive**: `CallStateMachineService.transition` — locked,
  version-checked, audited state changes using the shared transition table.
- **Agora**: server-side RTC token issuance with opaque channel names (the app
  certificate never leaves the server).
- **Admin console**: session handling, dev sign-in, platform overview with
  dependency health, applications list and detail.
- **Mobile foundation**: flavor-driven tenant selection, API client with
  tenant/auth/request-id headers, tenant config bootstrap that themes the app.

Scaffolded only (interfaces, module wiring, no business logic):
payments providers (Google Play, Apple, web), call orchestration and billing
loop, matching/presence, notifications sender, re-engagement scheduler
(the pure policy function *is* implemented and tested), moderation, analytics,
Firebase sign-in for the admin console, and the Flutter feature screens.

## Documentation

- [docs/architecture.md](docs/architecture.md) — system design, modules, data
  flows, tenancy, financial and call safety.
- [docs/development.md](docs/development.md) — environment setup, workflows,
  testing strategy, conventions.
- [docs/security.md](docs/security.md) — threat model, controls, secrets,
  what to check before production.
- [docs/deployment.md](docs/deployment.md) — hosting requirements, the VPS
  stack (`infra/deploy`), staging vs production, current ayushaura.in setup.
- [apps/mobile/README.md](apps/mobile/README.md) — Flutter client.

## Roadmap (next stages)

1. Users & callers: profiles, caller onboarding/verification, availability.
2. Wallet & payments: coin packages, Google Play / Apple / web providers,
   webhook verification, payouts.
3. Calls: request/ring/accept flow, Agora join, per-interval billing worker,
   insufficient-balance handling, reconnection.
4. Matching & presence: Redis-backed availability, random matching queue.
5. Re-engagement: push delivery, scheduler, caller-authored notifications.
6. Moderation, analytics, admin screens for all of the above.
