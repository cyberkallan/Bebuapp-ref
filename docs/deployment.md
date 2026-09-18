# Deployment

bebu is a set of long-running services (API, operator console, PostgreSQL, Redis, queue workers). It needs a
server that can run Docker: a VPS or cloud VM. It **cannot** run on shared web hosting (static/PHP only) or on
serverless platforms such as Vercel.

| Surface                          | What it is                          | Where it can live                          |
| -------------------------------- | ----------------------------------- | ------------------------------------------ |
| Landing site + APK download      | Static files (`apps/landing/dist`)  | Anywhere, including shared hosting         |
| API (`/api/*`, `/health`)        | Node.js (NestJS) + Postgres + Redis | VPS / VM with Docker                       |
| Operator console (`/admin`)      | Node.js (Next.js), talks to the API | VPS / VM with Docker, same host as the API |

## Current hosting (ayushaura.in)

`ayushaura.in` is on Hostinger shared hosting (CloudLinux, PHP 8.2, MySQL only). Deployed there:

- `https://ayushaura.in/` — landing page with the signed Android APKs under `/downloads/`.
- `https://ayushaura.in/admin/` — a status page explaining that the console requires an application server.

Redeploying the static site:

```bash
pnpm --filter @bebu/landing build
rsync -az --delete -e "ssh -p 65002" apps/landing/dist/ <user>@<host>:domains/ayushaura.in/public_html/
```

## Single-VPS stack (`infra/deploy`)

Everything runs behind [Caddy](https://caddyserver.com) with automatic HTTPS:

```
caddy :443 ── /            landing (static, built by the `landing` job)
           ── /api/*       api   (NestJS)      ──┬── postgres
           ── /health*     api                  └── redis
           ── /admin/*     admin (Next.js, basePath=/admin) ── api (private network)
           ── /metrics     404 at the edge (internal only)
migrate (one-shot) applies Prisma migrations before the API starts.
```

### Server requirements

- Ubuntu 22.04/24.04 (or Debian 12), 2 vCPU / 4 GB RAM minimum for staging; 4 vCPU / 8 GB for production.
- Docker Engine 24+ with the Compose v2 plugin: `curl -fsSL https://get.docker.com | sh`
- Ports 80 and 443 open. DNS `A` record for the domain (and `www`) pointing at the server.

### First deployment

```bash
git clone <repo> bebu && cd bebu
cp infra/deploy/.env.example infra/deploy/.env
nano infra/deploy/.env            # DOMAIN, ACME_EMAIL, APP_ENV (see below)
infra/deploy/deploy.sh up         # builds images, runs migrations, starts everything
infra/deploy/deploy.sh seed       # creates the default tenant + super admin
```

`deploy.sh up` generates any empty `POSTGRES_PASSWORD`, `REDIS_PASSWORD`, `DEV_AUTH_SECRET` and (in staging) the
`/admin` basic-auth password; it prints that password once — store it.

Useful commands: `deploy.sh status`, `deploy.sh logs [service]`, `deploy.sh update` (pull + rebuild + restart),
`deploy.sh down` (volumes are preserved).

### Staging vs production (`APP_ENV`)

`NODE_ENV` is always `production` in the containers (optimised builds, JSON logs). `APP_ENV` describes the deployment
and drives the security rules:

| Setting          | `APP_ENV=staging`                                                                    | `APP_ENV=production`                     |
| ---------------- | ------------------------------------------------------------------------------------ | ---------------------------------------- |
| Sign-in          | Dev identity form, tokens HMAC-signed with `DEV_AUTH_SECRET` (shared by API + admin) | Firebase only (`AUTH_MODE=firebase`)     |
| `/admin` at edge | Additionally behind HTTP basic auth (`Caddyfile.staging`)                            | No extra layer                           |
| Agora            | Optional (call features disabled until configured)                                   | `AGORA_APP_ID` + certificate required    |
| Purpose          | Test on the real domain before identity provider is wired                            | Live traffic                             |

Unsigned dev tokens are rejected by a staging API, so knowing an admin uid is not enough to call it; the secret is
never sent to a browser (the console signs tokens server-side).

Switching to production: set `APP_ENV=production`, `CADDYFILE=Caddyfile`, `AUTH_MODE=firebase`,
`ADMIN_AUTH_MODE=firebase`, the Firebase service-account variables and the Agora credentials, then
`deploy.sh update`. The API refuses to boot if any of these are missing.

### Mobile app

The Android build ships with a default API URL baked in at build time and a runtime override (Home → server icon).
For a staging VPS, point the app at `https://<DOMAIN>`; the API is served under `/api/v1`. Rebuild the APK with the
production URL before store submission (see `apps/mobile/README.md`).

### Backups

- PostgreSQL: `docker compose -f infra/deploy/docker-compose.yml exec postgres pg_dump -U bebu bebu | gzip > bebu-$(date +%F).sql.gz`
- Redis persists with AOF in the `redis-data` volume; it holds presence/locks/queues and is safe to rebuild.
- Caddy certificates live in the `caddy-data` volume.

### Security checklist before going live

- `APP_ENV=production`, Firebase and Agora configured, `DEV_AUTH_SECRET` removed.
- Rotate every password that was ever pasted into a chat, ticket or email (including hosting SSH passwords).
- SSH: key-based auth only, non-default port, `ufw` allowing 22/80/443 only.
- Keep `infra/deploy/.env` at mode `600`; it is git-ignored.
- Review `docs/security.md`.
