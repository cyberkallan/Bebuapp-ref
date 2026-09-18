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

const ABI_LABELS: Record<Build['abi'], { name: string; bestFor: string }> = {
  'arm64-v8a': { name: '64-bit ARM', bestFor: 'Most phones from 2017 onwards (recommended)' },
  'armeabi-v7a': { name: '32-bit ARM', bestFor: 'Older or entry-level Android phones' },
  x86_64: { name: 'x86-64', bestFor: 'Emulators and Chromebooks' },
  universal: { name: 'Universal', bestFor: 'Any Android device (larger download)' },
};

const ABI_PRIORITY: Build['abi'][] = ['arm64-v8a', 'universal', 'armeabi-v7a', 'x86_64'];

function $<T extends Element>(selector: string, root: ParentNode = document): T | null {
  return root.querySelector<T>(selector);
}

function formatBytes(bytes: number): string {
  if (bytes >= 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  return `${Math.round(bytes / 1024)} KB`;
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
}

function pickPrimary(builds: Build[]): Build | undefined {
  for (const abi of ABI_PRIORITY) {
    const match = builds.find((b) => b.abi === abi);
    if (match) return match;
  }
  return builds[0];
}

function setupHeader(): void {
  const header = $<HTMLElement>('[data-header]');
  const toggle = $<HTMLButtonElement>('[data-nav-toggle]');
  const links = $<HTMLElement>('#nav-links');
  if (!header || !toggle || !links) return;

  const onScroll = (): void => {
    header.classList.toggle('is-scrolled', window.scrollY > 8);
  };
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });

  toggle.addEventListener('click', () => {
    const open = links.classList.toggle('is-open');
    toggle.setAttribute('aria-expanded', String(open));
  });
  links.addEventListener('click', (event) => {
    if ((event.target as HTMLElement).tagName === 'A') {
      links.classList.remove('is-open');
      toggle.setAttribute('aria-expanded', 'false');
    }
  });
}

function setupTimer(): void {
  const el = $<HTMLElement>('[data-timer]');
  if (!el) return;
  let seconds = 4 * 60 + 32;
  window.setInterval(() => {
    seconds += 1;
    const m = String(Math.floor(seconds / 60)).padStart(2, '0');
    const s = String(seconds % 60).padStart(2, '0');
    el.textContent = `${m}:${s}`;
  }, 1000);
}

function renderDownloads(manifest: Manifest): void {
  const versionEls = document.querySelectorAll<HTMLElement>('[data-version]');
  const primaryLink = $<HTMLAnchorElement>('[data-download-primary]');
  const primaryLabel = $<HTMLElement>('[data-download-primary-label]');
  const buttons = $<HTMLElement>('[data-download-buttons]');
  const buildsPanel = $<HTMLElement>('[data-builds]');
  const buildsBody = $<HTMLElement>('[data-builds-body]');
  const checksums = $<HTMLElement>('[data-checksums]');
  const empty = $<HTMLElement>('[data-download-empty]');
  const toggleBuilds = $<HTMLButtonElement>('[data-toggle-builds]');

  const primary = pickPrimary(manifest.builds);
  versionEls.forEach((el) => {
    el.textContent = manifest.version ?? 'early access';
  });

  if (!primary || !primaryLink || !buttons || !buildsPanel || !buildsBody || !checksums) {
    buttons?.setAttribute('hidden', '');
    empty?.removeAttribute('hidden');
    return;
  }

  primaryLink.href = `/downloads/${primary.file}`;
  primaryLink.setAttribute('download', primary.file);
  if (primaryLabel) {
    primaryLabel.textContent = `Download APK · ${formatBytes(primary.bytes)}`;
  }

  buildsBody.innerHTML = manifest.builds
    .map((b) => {
      const label = ABI_LABELS[b.abi];
      return `<tr>
        <td><span class="tag">${escapeHtml(label.name)}</span> <span class="mono">${escapeHtml(b.abi)}</span></td>
        <td>${escapeHtml(label.bestFor)}</td>
        <td>${formatBytes(b.bytes)}</td>
        <td><a class="btn btn--table" href="/downloads/${encodeURIComponent(b.file)}" download>Download</a></td>
      </tr>`;
    })
    .join('');

  checksums.innerHTML = manifest.builds
    .map(
      (b) =>
        `<li><span>${escapeHtml(b.file)}</span><code>${escapeHtml(b.sha256 ?? 'checksum unavailable')}</code></li>`,
    )
    .join('');

  toggleBuilds?.addEventListener('click', () => {
    const isHidden = buildsPanel.hasAttribute('hidden');
    if (isHidden) buildsPanel.removeAttribute('hidden');
    else buildsPanel.setAttribute('hidden', '');
    toggleBuilds.setAttribute('aria-expanded', String(isHidden));
    toggleBuilds.textContent = isHidden ? 'Hide other builds' : 'Other devices';
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

function setupYear(): void {
  const el = $<HTMLElement>('[data-year]');
  if (el) el.textContent = String(new Date().getFullYear());
}

setupHeader();
setupTimer();
setupYear();
void loadManifest();
