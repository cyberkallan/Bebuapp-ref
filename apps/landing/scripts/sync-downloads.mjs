// Copies the signed APKs and their checksums from /releases into the site's
// public folder so `vite build` ships them under /downloads/. Also writes a
// small JSON manifest the page reads to show sizes and checksums.
import {
  copyFileSync,
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..');
const releasesDir = path.resolve(root, '../../releases');
const outDir = path.join(root, 'public/downloads');

// Start clean so APKs removed from /releases do not linger in the site.
rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });

if (!existsSync(releasesDir)) {
  console.warn(`[landing] no releases directory at ${releasesDir}; download links will be empty`);
  writeFileSync(
    path.join(outDir, 'manifest.json'),
    JSON.stringify({ version: null, builds: [] }, null, 2),
  );
  process.exit(0);
}

const checksums = new Map();
const sumsFile = path.join(releasesDir, 'SHA256SUMS.txt');
if (existsSync(sumsFile)) {
  for (const line of readFileSync(sumsFile, 'utf8').split('\n')) {
    const [hash, name] = line.trim().split(/\s+/);
    if (hash && name) checksums.set(name, hash);
  }
}

const builds = [];
for (const name of readdirSync(releasesDir)
  .filter((f) => f.endsWith('.apk'))
  .sort()) {
  copyFileSync(path.join(releasesDir, name), path.join(outDir, name));
  const abi = /-(arm64-v8a|armeabi-v7a|x86_64)\.apk$/.exec(name)?.[1] ?? 'universal';
  const version = /^bebu-([0-9]+\.[0-9]+\.[0-9]+)/.exec(name)?.[1] ?? null;
  builds.push({
    file: name,
    abi,
    version,
    bytes: statSync(path.join(releasesDir, name)).size,
    sha256: checksums.get(name) ?? null,
  });
}

writeFileSync(
  path.join(outDir, 'manifest.json'),
  JSON.stringify({ version: builds[0]?.version ?? null, builds }, null, 2),
);
console.log(`[landing] synced ${builds.length} APK(s) to public/downloads`);
