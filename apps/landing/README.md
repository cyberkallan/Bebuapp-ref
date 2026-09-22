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

## App screenshots

`public/screens/*.webp` are real renders of the Flutter app (780×1688, dark and light themes) shown inside the CSS
`.device` frame on both pages. To refresh them after a UI change, render the screens again from the app (any widget
test that calls `RenderRepaintBoundary.toImage` at a 390×844 logical size works), export them as WebP at 780px wide and
overwrite the files here — the names are referenced directly from `index.html` and `download.html`. `public/og.png` is
the social preview card and should be regenerated from the same renders.

## Deploying

The `dist/` folder is the complete site. `public/.htaccess` (copied verbatim into `dist/`) handles HTTPS redirect, the
APK MIME type, caching, and security headers on Apache/LiteSpeed hosts.

```bash
pnpm --filter @bebu/landing build
rsync -az --delete -e "ssh -p <port>" apps/landing/dist/ <user>@<host>:domains/<domain>/public_html/
```

`/admin/` on this static site is a status page. The real operator console (`apps/admin`) is a Node.js application and
is served at `/admin` by the production stack in `infra/deploy` — see `docs/deployment.md`.
