# syntax=docker/dockerfile:1.7
# bebu landing site — builds the static site and publishes it into a volume
# that the edge proxy serves. Build context = repo root.

ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-alpine AS build
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH CI=1
RUN corepack enable
WORKDIR /repo
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY packages/config/package.json packages/config/
COPY apps/landing/package.json apps/landing/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile --filter @bebu/landing... --filter @bebu/config
COPY packages/config ./packages/config
COPY apps/landing ./apps/landing
COPY releases ./releases
RUN pnpm --filter @bebu/landing build

# Copies the built site into /srv/landing (a shared volume) and exits.
FROM alpine:3.20 AS publish
COPY --from=build /repo/apps/landing/dist /site
CMD ["sh", "-c", "rm -rf /srv/landing/* /srv/landing/.[!.]* 2>/dev/null; cp -a /site/. /srv/landing/ && echo 'landing published'"]
