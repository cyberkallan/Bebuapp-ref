import { setupHeader, setupReveal, setupYear } from './reveal';

interface Build {
  file: string;
  abi: 'arm64-v8a' | 'armeabi-v7a' | 'x86_64' | 'universal';
  version: string | null;
  bytes: number;
  sha256: string | null;
}

interface Manifest {
  version: string | null;
  builds: Build[];
}

const ABI_PRIORITY: Build['abi'][] = ['arm64-v8a', 'universal', 'armeabi-v7a', 'x86_64'];

function formatBytes(bytes: number): string {
  if (bytes >= 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  return `${Math.round(bytes / 1024)} KB`;
}

function pickPrimary(builds: Build[]): Build | undefined {
  for (const abi of ABI_PRIORITY) {
    const match = builds.find((b) => b.abi === abi);
    if (match) return match;
  }
  return builds[0];
}

/**
 * The landing page links to the download page; once the manifest is known
 * the primary buttons deep-link to the APK itself and show its size.
 */
function renderDownloads(manifest: Manifest): void {
  document.querySelectorAll<HTMLElement>('[data-version]').forEach((el) => {
    el.textContent = manifest.version ?? 'early access';
  });

  const primary = pickPrimary(manifest.builds);
  const buttons = document.querySelector<HTMLElement>('[data-download-buttons]');
  const empty = document.querySelector<HTMLElement>('[data-download-empty]');
  if (!primary) {
    buttons?.setAttribute('hidden', '');
    empty?.removeAttribute('hidden');
    return;
  }

  document.querySelectorAll<HTMLAnchorElement>('[data-download-primary]').forEach((a) => {
    a.href = `/downloads/${encodeURIComponent(primary.file)}`;
    a.setAttribute('download', primary.file);
  });
  document.querySelectorAll<HTMLElement>('[data-download-primary-label]').forEach((el) => {
    const short = el.closest('.btn--sm') !== null;
    el.textContent = short
      ? `Download · ${formatBytes(primary.bytes)}`
      : `Download APK · ${formatBytes(primary.bytes)}`;
  });
}

async function loadManifest(): Promise<void> {
  try {
    const res = await fetch('/downloads/manifest.json', { cache: 'no-cache' });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    renderDownloads((await res.json()) as Manifest);
  } catch {
    renderDownloads({ version: null, builds: [] });
  }
}

setupHeader();
setupReveal();
setupYear();
void loadManifest();
