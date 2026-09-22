# bebu backend: Express 5 + Socket.IO + Mongoose.
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund

FROM node:22-alpine
ENV NODE_ENV=production
RUN apk add --no-cache tini curl
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# setting.js is rewritten at runtime when settings change in the admin panel,
# and storage/ receives uploads: both must be writable by the runtime user.
RUN mkdir -p storage && chown -R node:node /app
USER node
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS -o /dev/null -H "key: $secretKey" http://127.0.0.1:5000/api/user/setting/getAppConfiguration || exit 1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]
