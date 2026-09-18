# @bebu/landing

Static marketing site and Android download page for bebu. Built with Vite (vanilla TypeScript, hand-written CSS) so the
output is plain HTML/CSS/JS that runs on any web host, including shared hosting without Node.js.

## Commands

```bash
pnpm --filter @bebu/landing dev      # http://127.0.0.1:4183
pnpm --filter @bebu/landing build    # -> dist/
pnpm --filter @bebu/landing preview  # serve dist/ locally
```

`build` first runs `scripts/sync-downloads.mjs`, which copies the signed APKs and `SHA256SUMS.txt` from `/releases`
into `public/downloads/` and writes `manifest.json`. The page reads that manifest at runtime to render download buttons,
sizes and checksums, so publishing a new APK only requires dropping it into `/releases` and rebuilding.

## Deploying

The `dist/` folder is the complete site. `public/.htaccess` (copied verbatim into `dist/`) handles HTTPS redirect, the
APK MIME type, caching, and security headers on Apache/LiteSpeed hosts.

```bash
pnpm --filter @bebu/landing build
rsync -az --delete -e "ssh -p <port>" apps/landing/dist/ <user>@<host>:domains/<domain>/public_html/
```

`/admin/` on this static site is a status page. The real operator console (`apps/admin`) is a Node.js application and
is served at `/admin` by the production stack in `infra/deploy` — see `docs/deployment.md`.
