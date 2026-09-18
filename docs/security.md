# Security

## Principles

- The server is the only authority for identity, authorization, tenant scope,
  balances and call state. Clients send intents and render results.
- Fail closed: invalid configuration, unknown tenants, corrupt tenant config
  and unverifiable tokens all reject the request.
- Every privileged or money-moving action is attributable (actor, request id,
  IP) and immutable in an audit trail.

## Identity and authorization

- Users and admins authenticate with **Firebase ID tokens**, verified with the
  Admin SDK (`AUTH_MODE=firebase`, required in production; the env schema
  refuses `dev` when `NODE_ENV=production`).
- The `dev` verifier accepts unsigned `dev:` tokens for local work and tests.
  It throws if instantiated in production, and the admin console likewise
  refuses `ADMIN_AUTH_MODE=dev` in production.
- Authorization never trusts token claims. Roles and permissions for admins are
  read from `admin_accounts`; user status (`BLOCKED`) is read from `users`.
- Admin routes are explicitly `@AdminScope()`; user routes require a resolved
  tenant. Tenant admins are pinned to their tenant on every request and cannot
  change tenant status.
- The admin console keeps the bearer token in an `httpOnly`, `SameSite=Lax`
  cookie and only calls the API from the server, so tokens never reach browser
  JavaScript.

## Tenant isolation

- `X-Tenant-Key` is resolved to an internal `tenantId`; clients never send
  UUIDs for tenant scope.
- Suspended tenants are rejected before authentication.
- Every query is scoped by `tenantId`; unique constraints and the ledger's
  idempotency keys are tenant-prefixed. Row locks verify the tenant as well as
  the id.

## Money

- Integer-only coin arithmetic; guarded by `assertPositiveCoinAmount`.
- Ledger postings are SERIALIZABLE, row-locked, idempotent and never negative.
- Coins are credited only after server-side verification of a purchase
  (provider receipt/webhook), exactly once per order.
- Provider events are stored before processing with a unique
  `(provider, providerEventId)` and a recorded `signatureValid` flag, so
  replays and tampered notifications are detectable.
- Payout methods hold references, not raw bank data; sensitive fields must be
  tokenised upstream.

## Transport and HTTP hardening

- Helmet: `nosniff`, frame-ancestors none, strict CSP for the API (no HTML),
  HSTS in production, `x-powered-by` removed.
- CORS allow-list from `CORS_ORIGINS`; credentials only for listed origins.
- Rate limiting per client with Redis-backed storage shared across replicas;
  `TRUST_PROXY_HOPS` must match the real number of proxies so limits apply to
  the correct IP.
- Request bodies are parsed with `rawBody: true` so webhook signatures can be
  verified over the exact bytes.

## Secrets

- `.env` is git-ignored; `.env.example` contains local defaults only.
- Production secrets (database, Redis, Firebase service account, Agora App
  Certificate, metrics token) come from the platform's secret manager and are
  injected as environment variables or mounted files.
- The Agora App Certificate is server-only; clients receive short-lived RTC
  tokens for opaque channel names.
- Logs redact `Authorization`, `Cookie`, `X-Api-Key` and `Set-Cookie`.

## Audit and observability

- `audit_logs`: immutable record of privileged actions with before/after
  snapshots, actor, reason, request id and IP. Written in the same transaction
  as the change when possible.
- `call_state_transitions`: every call state change with actor and reason.
- `wallet_transactions`: append-only ledger; status is the only mutable field.
- Request ids flow from client → API → logs → error responses, so any user
  report can be traced.

## Before production checklist

- [ ] `NODE_ENV=production`, `AUTH_MODE=firebase`, `ADMIN_AUTH_MODE=firebase`
- [ ] Firebase service account configured; test token verification end to end
- [ ] `CORS_ORIGINS` limited to the real admin/web origins
- [ ] `TRUST_PROXY_HOPS` set for the ingress topology
- [ ] `METRICS_TOKEN` set or `/metrics` blocked at the ingress
- [ ] Redis `maxmemory-policy noeviction`, persistence enabled
- [ ] PostgreSQL backups and point-in-time recovery verified
- [ ] Database role for the API has no superuser/DDL rights; migrations run
      from a separate role in CI
- [ ] Payment webhook secrets configured; signature verification enabled
- [ ] Dependency audit (`pnpm audit`) clean or triaged
- [ ] Log sink configured; no PII beyond what the privacy policy states

## Reporting

Security issues should be reported privately to the platform operators at the
support address published on <https://bebuapp.in/>; do not open public issues
for vulnerabilities.
