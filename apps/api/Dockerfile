# syntax=docker/dockerfile:1.7
# bebu API — multi-stage build. Build context must be the repository root:
#   docker build -f apps/api/Dockerfile -t bebu/api .
#   docker build -f apps/api/Dockerfile --target migrate -t bebu/api-migrate .

ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-alpine AS base
ENV PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH \
    CI=1
RUN corepack enable
WORKDIR /repo

# ---- deps: install only the workspace subset the API needs -----------------
FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY packages/config/package.json packages/config/
COPY packages/shared/package.json packages/shared/
COPY apps/api/package.json apps/api/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile --filter @bebu/api... --filter @bebu/config

# ---- build -----------------------------------------------------------------
FROM deps AS build
COPY packages ./packages
COPY apps/api ./apps/api
RUN PRISMA_ALLOW_MISSING_DATABASE_URL=1 pnpm --filter @bebu/shared build \
 && PRISMA_ALLOW_MISSING_DATABASE_URL=1 pnpm --filter @bebu/api build \
 && pnpm --filter @bebu/api deploy --prod --legacy /out

# ---- migrate: one-shot container that applies Prisma migrations ------------
# Keeps the Prisma CLI out of the runtime image while sharing the same build.
FROM build AS migrate
WORKDIR /repo/apps/api
CMD ["node_modules/.bin/prisma", "migrate", "deploy"]

# ---- runtime ---------------------------------------------------------------
FROM node:${NODE_VERSION}-alpine AS runtime
ENV NODE_ENV=production
RUN apk add --no-cache tini curl \
 && addgroup -S bebu && adduser -S bebu -G bebu
WORKDIR /app
COPY --from=build --chown=bebu:bebu /out ./
USER bebu
EXPOSE 4180
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=5 \
  CMD curl -fsS "http://127.0.0.1:${API_PORT:-4180}/health/live" || exit 1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/main.js"]
