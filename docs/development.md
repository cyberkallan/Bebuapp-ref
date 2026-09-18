# Development guide

## Prerequisites

| Tool        | Version | Notes                                              |
| ----------- | ------- | -------------------------------------------------- |
| Node.js     | 24 LTS  | `.nvmrc`; `nvm use`                                |
| pnpm        | 10+     | `corepack enable`                                  |
| Docker      | any     | optional; for local Postgres/Redis via compose     |
| PostgreSQL  | 16      | if not using Docker                                |
| Redis       | 7       | if not using Docker                                |
| Flutter     | 3.27+   | only for `apps/mobile`                             |

## First run

```bash
./infra/scripts/bootstrap.sh
```

The script copies `.env.example` to `.env`, installs dependencies, starts
Postgres and Redis (Docker Compose when available), waits for them, applies
migrations and seeds the `bebu` tenant plus a super admin.

Without Docker, create the databases yourself and keep the URLs in `.env`:

```sql
CREATE ROLE bebu LOGIN PASSWORD 'bebu';
CREATE DATABASE bebu OWNER bebu;
CREATE DATABASE bebu_test OWNER bebu;
```

## Running

```bash
pnpm dev          # API (:4180) and admin (:4181) with hot reload
pnpm dev:api
pnpm dev:admin
```

The admin console reads the repository-root `.env` (`BEBU_API_URL`,
`ADMIN_AUTH_MODE`). In `dev` auth mode, sign in with the seeded admin
(`dev-super-admin` / `admin@bebuapp.in`). The API in `AUTH_MODE=dev` accepts
tokens of the form `dev:<base64url(json)>`; tests and the admin console build
them with `encodeDevToken` / `encodeDevBearer`.

Calling the API by hand:

```bash
TOKEN="Bearer dev:$(printf '{"uid":"u1","email":"u1@example.com"}' | basenc --base64url -w0)"
curl -H "X-Tenant-Key: bebu" -H "Authorization: $TOKEN" http://127.0.0.1:4180/api/v1/users/me
```

## Database workflow

```bash
pnpm db:generate          # regenerate the Prisma client (also runs on build/typecheck)
pnpm db:migrate           # prisma migrate dev: creates a migration from schema changes
pnpm db:migrate:deploy    # apply committed migrations (CI, staging, production)
pnpm db:seed              # idempotent development seed
pnpm --filter @bebu/api db:studio
```

Rules:

- Never edit an applied migration; add a new one.
- Every business table has `tenantId`; unique constraints include it.
- Money columns are `BIGINT`/`Int`; never `Float`/`Decimal` for coins.
- Raw SQL (used for `FOR UPDATE` locks) must quote camelCase column names
  (`"tenantId"`), because only tables are `@@map`ped to snake_case.

## Testing

```bash
pnpm test        # unit tests: packages/shared and apps/api (no infra needed)
pnpm test:e2e    # apps/api integration tests against DATABASE_URL_TEST + Redis
```

- Unit tests live next to the code as `*.spec.ts` and cover pure logic: coin
  arithmetic, the call transition table, schemas, env parsing, the
  re-engagement policy, token verifiers, Agora token issuance.
- E2E tests boot the real Nest application (same guards, filters and Helmet
  configuration as production) and hit it with supertest. They truncate the
  test database between suites. `test/wallet-ledger.e2e-spec.ts` exercises the
  ledger primitive under concurrent debits.
- Add an e2e test whenever a change touches money, call state or the auth
  pipeline.

## Quality gates

```bash
pnpm typecheck   # tsc --noEmit for every package (strict, noUncheckedIndexedAccess)
pnpm lint        # ESLint with type-aware rules; no floating promises, no any
pnpm format      # Prettier
pnpm build       # shared packages, API (nest build) and admin (next build)
```

All four must pass before merging. The API `dev` script uses `nest start
--watch` (tsc) rather than esbuild-based runners because Nest relies on
decorator metadata.

## Conventions

- **Modules**: `apps/api/src/modules/<feature>` with `*.module.ts`,
  `*.controller.ts`, `*.service.ts`; infrastructure adapters live in
  `apps/api/src/infrastructure`. Controllers validate and delegate; services
  hold business rules; nothing in a controller touches Prisma directly.
- **Validation**: Zod schemas in `@bebu/shared` and `@ValidatedBody/Query/
  Params` decorators. Update schemas (create vs. update) are explicit so PATCH
  never applies creation defaults.
- **Errors**: throw `AppException` with an `ErrorCode`; never leak driver or
  stack details. Clients branch on `code`.
- **Money and calls**: only through `WalletLedgerService.apply` and
  `CallStateMachineService.transition`, inside
  `PrismaService.financialTransaction`.
- **Idempotency**: every mutating financial endpoint accepts an
  `Idempotency-Key`; the ledger enforces uniqueness per tenant.
- **Logging**: `PinoLogger` with context; never log tokens, cookies or payment
  payloads.
- **Imports**: ESM with explicit `.js` extensions in the API; `@/` alias in the
  admin app.
- **Commits**: one logical change per commit, conventional prefixes
  (`feat(api): …`, `fix(admin): …`).

## Ports

| Service       | Port |
| ------------- | ---- |
| API           | 4180 |
| Admin console | 4181 |
| PostgreSQL    | 5432 |
| Redis         | 6379 |
