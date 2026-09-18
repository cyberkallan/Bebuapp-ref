# syntax=docker/dockerfile:1.7
# bebu operator console — Next.js standalone build. Build context = repo root:
#   docker build -f apps/admin/Dockerfile --build-arg ADMIN_BASE_PATH=/admin -t bebu/admin .

ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-alpine AS base
ENV PNPM_HOME=/pnpm \
    PATH=/pnpm:$PATH \
    CI=1 \
    NEXT_TELEMETRY_DISABLED=1
RUN corepack enable
WORKDIR /repo

# ---- deps ------------------------------------------------------------------
FROM base AS deps
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY packages/config/package.json packages/config/
COPY packages/shared/package.json packages/shared/
COPY apps/admin/package.json apps/admin/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile --filter @bebu/admin... --filter @bebu/config

# ---- build -----------------------------------------------------------------
FROM deps AS build
# Sub-path the console is served from (baked into the client bundle).
ARG ADMIN_BASE_PATH=/admin
ENV ADMIN_BASE_PATH=${ADMIN_BASE_PATH} \
    NEXT_OUTPUT_STANDALONE=1
COPY packages ./packages
COPY apps/admin ./apps/admin
RUN pnpm --filter @bebu/shared build \
 && pnpm --filter @bebu/admin build

# ---- runtime ---------------------------------------------------------------
FROM node:${NODE_VERSION}-alpine AS runtime
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=4181 \
    HOSTNAME=0.0.0.0
RUN apk add --no-cache tini curl \
 && addgroup -S bebu && adduser -S bebu -G bebu
WORKDIR /app
COPY --from=build --chown=bebu:bebu /repo/apps/admin/.next/standalone ./
COPY --from=build --chown=bebu:bebu /repo/apps/admin/.next/static ./apps/admin/.next/static
COPY --from=build --chown=bebu:bebu /repo/apps/admin/public ./apps/admin/public
USER bebu
WORKDIR /app/apps/admin
EXPOSE 4181
HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=5 \
  CMD curl -fsS -o /dev/null "http://127.0.0.1:${PORT}${ADMIN_BASE_PATH:-}/sign-in" || exit 1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "server.js"]
