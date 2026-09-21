import qrcode from 'qrcode-generator';

type Abi = 'arm64-v8a' | 'armeabi-v7a' | 'x86_64' | 'universal';

interface Build {
  file: string;
  abi: Abi;
  version: string | null;
  bytes: number;
  sha256: string | null;
}

interface ReleaseNote {
  type: 'new' | 'improved' | 'fix';
  title: string;
  body?: string;
}

interface Manifest {
  version: string | null;
  builds: Build[];
  notes?: { date?: string; items?: ReleaseNote[] } | null;
}

const ABI_INFO: Record<Abi, { name: string; bestFor: string; order: number }> = {
  'arm64-v8a': {
    name: '64-bit ARM',
    bestFor: 'Almost every phone sold since 2017 — Samsung, Xiaomi, Vivo, OnePlus, Realme, Pixel.',
    order: 0,
  },
  universal: {
    name: 'Universal',
    bestFor:
      'Works on any Android device. Larger download because it bundles every processor type.',
    order: 1,
  },
  'armeabi-v7a': {
    name: '32-bit ARM',
    bestFor: 'Older or entry-level phones from before 2017.',
    order: 2,
  },
  x86_64: {
    name: 'x86-64',
    bestFor: 'Android emulators and Chromebooks with Intel or AMD chips.',
    order: 3,
  },
};

type Platform = 'android' | 'ios' | 'desktop';

function $<T extends Element>(selector: string, root: ParentNode = document): T | null {
  return root.querySelector<T>(selector);
}

function $$<T extends Element>(selector: string, root: ParentNode = document): T[] {
  return Array.from(root.querySelectorAll<T>(selector));
}

function formatBytes(bytes: number): string {
  if (bytes >= 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  return `${Math.round(bytes / 1024)} KB`;
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
}

function detectPlatform(): Platform {
  const ua = navigator.userAgent;
  if (/Android/i.test(ua)) return 'android';
  if (/iPhone|iPad|iPod/i.test(ua)) return 'ios';
  return 'desktop';
}

/**
 * Browsers do not expose the CPU ABI, so this is a best guess: 64-bit ARM
 * covers virtually every Android phone of the last eight years; explicit
 * x86 hints point at emulators/Chromebooks.
 */
function guessAbi(builds: Build[]): Build | undefined {
  const ua = navigator.userAgent;
  const want: Abi[] =
    /x86_64|Win64|x64|Intel/i.test(ua) && detectPlatform() !== 'android'
      ? ['arm64-v8a', 'universal', 'x86_64', 'armeabi-v7a']
      : ['arm64-v8a', 'universal', 'armeabi-v7a', 'x86_64'];
  for (const abi of want) {
    const match = builds.find((b) => b.abi === abi);
    if (match) return match;
  }
  return builds[0];
}

function downloadHref(build: Build): string {
  return `/downloads/${encodeURIComponent(build.file)}`;
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

function setupTilt(): void {
  const stage = $<HTMLElement>('[data-tilt]');
  const phone = stage ? $<HTMLElement>('.dl-phone', stage) : null;
  if (!stage || !phone) return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  if (!window.matchMedia('(pointer: fine)').matches) return;

  stage.addEventListener('pointermove', (event) => {
    const rect = stage.getBoundingClientRect();
    const px = (event.clientX - rect.left) / rect.width - 0.5;
    const py = (event.clientY - rect.top) / rect.height - 0.5;
    phone.style.setProperty('--ry', `${(-14 + px * 26).toFixed(2)}deg`);
    phone.style.setProperty('--rx', `${(6 - py * 18).toFixed(2)}deg`);
  });
  stage.addEventListener('pointerleave', () => {
    phone.style.removeProperty('--ry');
    phone.style.removeProperty('--rx');
  });
}

function setupTabs(): void {
  const tabs = $$<HTMLButtonElement>('[data-os-tab]');
  const panels = $$<HTMLElement>('[data-os-panel]');
  if (!tabs.length) return;
  const platform = detectPlatform();
  const initial =
    platform === 'android' ? 'android' : /Win/i.test(navigator.userAgent) ? 'win' : 'mac';

  const select = (id: string): void => {
    tabs.forEach((t) => t.setAttribute('aria-selected', String(t.dataset['osTab'] === id)));
    panels.forEach((p) => {
      if (p.dataset['osPanel'] === id) p.removeAttribute('hidden');
      else p.setAttribute('hidden', '');
    });
  };
  tabs.forEach((t) => t.addEventListener('click', () => select(t.dataset['osTab'] ?? 'android')));
  select(initial);
}

function setupSticky(): void {
  const bar = $<HTMLElement>('[data-sticky]');
  const hero = $<HTMLElement>('#get');
  if (!bar || !hero) return;
  bar.removeAttribute('hidden');
  const observer = new IntersectionObserver(
    ([entry]) => bar.classList.toggle('is-visible', !entry?.isIntersecting),
    { threshold: 0.15 },
  );
  observer.observe(hero);
}

function setupCopyButtons(root: ParentNode): void {
  $$<HTMLButtonElement>('[data-copy]', root).forEach((button) => {
    button.addEventListener('click', async () => {
      const value = button.dataset['copy'] ?? '';
      try {
        await navigator.clipboard.writeText(value);
        button.classList.add('is-copied');
        button.textContent = 'Copied';
        window.setTimeout(() => {
          button.classList.remove('is-copied');
          button.textContent = 'Copy';
        }, 1600);
      } catch {
        button.textContent = 'Select & copy';
      }
    });
  });
}

function renderQr(url: string): void {
  const card = $<HTMLElement>('[data-qr-card]');
  const target = $<HTMLElement>('[data-qr]');
  if (!card || !target) return;
  if (detectPlatform() === 'android') {
    card.setAttribute('hidden', '');
    return;
  }
  const qr = qrcode(0, 'M');
  qr.addData(url);
  qr.make();
  target.innerHTML = qr.createSvgTag({ cellSize: 4, margin: 0, scalable: true });
  card.removeAttribute('hidden');
}

function renderPrimary(primary: Build | undefined, manifest: Manifest): void {
  const links = $$<HTMLAnchorElement>('[data-download-primary]');
  const meta = $<HTMLElement>('[data-primary-meta]');
  const navLabel = $<HTMLElement>('[data-nav-label]');
  const empty = $<HTMLElement>('[data-download-empty]');
  const mega = $<HTMLElement>('.dl-mega');

  $$<HTMLElement>('[data-version]').forEach((el) => {
    el.textContent = manifest.version ?? 'early access';
  });

  if (!primary) {
    links.forEach((a) => {
      a.setAttribute('aria-disabled', 'true');
      a.href = '#builds';
    });
    if (meta) meta.textContent = 'Build not published yet';
    mega?.classList.remove('is-pending');
    empty?.removeAttribute('hidden');
    $$<HTMLElement>('[data-primary-size]').forEach((el) => (el.textContent = '—'));
    return;
  }

  links.forEach((a) => {
    a.href = downloadHref(primary);
    a.setAttribute('download', primary.file);
  });
  const info = ABI_INFO[primary.abi];
  const platform = detectPlatform();
  if (meta) {
    meta.textContent =
      platform === 'android'
        ? `${info.name} · ${formatBytes(primary.bytes)} · picked for this phone`
        : `${info.name} · ${formatBytes(primary.bytes)} · APK file`;
  }
  mega?.classList.remove('is-pending');
  if (navLabel) navLabel.textContent = `Download · ${formatBytes(primary.bytes)}`;
  $$<HTMLElement>('[data-primary-size]').forEach(
    (el) => (el.textContent = formatBytes(primary.bytes)),
  );
  $$<HTMLElement>('[data-primary-file]').forEach((el) => (el.textContent = primary.file));

  renderQr(new URL(downloadHref(primary), window.location.href).toString());
}

function renderBuilds(builds: Build[], primary: Build | undefined): void {
  const grid = $<HTMLElement>('[data-builds-grid]');
  const hint = $<HTMLElement>('[data-device-hint]');
  if (!grid) return;

  if (!builds.length) {
    grid.innerHTML = `<div class="dl-build"><p class="dl-build__for">No builds published yet.</p></div>`;
    return;
  }

  const sorted = [...builds].sort((a, b) => ABI_INFO[a.abi].order - ABI_INFO[b.abi].order);
  grid.innerHTML = sorted
    .map((b) => {
      const info = ABI_INFO[b.abi];
      const recommended = b === primary;
      return `<article class="dl-build${recommended ? ' is-recommended' : ''}">
        ${recommended ? '<span class="dl-build__badge">Recommended</span>' : ''}
        <div class="dl-build__head">
          <span class="dl-build__name">${escapeHtml(info.name)}</span>
          <span class="dl-build__abi">${escapeHtml(b.abi)}</span>
        </div>
        <p class="dl-build__for">${escapeHtml(info.bestFor)}</p>
        <div class="dl-build__foot">
          <span class="dl-build__size">${formatBytes(b.bytes)}<small>v${escapeHtml(b.version ?? '—')}</small></span>
          <a class="btn ${recommended ? 'btn--primary' : 'btn--ghost-dark'}" href="${downloadHref(b)}" download="${escapeHtml(b.file)}">Download</a>
        </div>
      </article>`;
    })
    .join('');

  if (hint) {
    const platform = detectPlatform();
    hint.textContent =
      platform === 'ios'
        ? 'bebu is Android-only for now. An iPhone version is on the roadmap.'
        : platform === 'desktop'
          ? 'You are on a computer: scan the QR code above with your phone, or download here and transfer the file.'
          : 'Not sure which one? The recommended build is right for nearly every phone. If Android says the app is not compatible, try the 32-bit build.';
    hint.removeAttribute('hidden');
  }
}

function renderChecksums(builds: Build[]): void {
  const list = $<HTMLElement>('[data-checksums]');
  if (!list) return;
  list.innerHTML = builds
    .map((b) => {
      const hash = b.sha256 ?? '';
      return `<li class="dl-sum">
        <div class="dl-sum__file"><span>${escapeHtml(b.file)}</span><span class="dl-build__abi">${escapeHtml(b.abi)}</span></div>
        <div class="dl-sum__hash">
          <code>${hash ? escapeHtml(hash) : 'checksum unavailable'}</code>
          ${hash ? `<button class="dl-copy" type="button" data-copy="${escapeHtml(hash)}">Copy</button>` : ''}
        </div>
      </li>`;
    })
    .join('');
  setupCopyButtons(list);
}

function renderNotes(manifest: Manifest): void {
  const list = $<HTMLElement>('[data-notes-list]');
  const date = $<HTMLElement>('[data-notes-date]');
  const items = manifest.notes?.items ?? [];
  if (!list) return;
  if (date && manifest.notes?.date) {
    const d = new Date(manifest.notes.date);
    date.textContent = Number.isNaN(d.getTime())
      ? manifest.notes.date
      : d.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' });
  }
  if (!items.length) return;
  const labels: Record<ReleaseNote['type'], string> = {
    new: 'New',
    improved: 'Improved',
    fix: 'Fixed',
  };
  list.innerHTML = items
    .map(
      (n) => `<li>
        <span class="dl-notes__tag dl-notes__tag--${n.type}">${labels[n.type]}</span>
        <span><b>${escapeHtml(n.title)}</b>${n.body ? ` — ${escapeHtml(n.body)}` : ''}</span>
      </li>`,
    )
    .join('');
}

async function loadManifest(): Promise<Manifest> {
  try {
    const res = await fetch('/downloads/manifest.json', { cache: 'no-cache' });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return (await res.json()) as Manifest;
  } catch {
    return { version: null, builds: [] };
  }
}

function setupYear(): void {
  const el = $<HTMLElement>('[data-year]');
  if (el) el.textContent = String(new Date().getFullYear());
}

async function main(): Promise<void> {
  setupHeader();
  setupTilt();
  setupTabs();
  setupSticky();
  setupYear();
  $<HTMLElement>('.dl-mega')?.classList.add('is-pending');

  const manifest = await loadManifest();
  const primary = guessAbi(manifest.builds);
  renderPrimary(primary, manifest);
  renderBuilds(manifest.builds, primary);
  renderChecksums(manifest.builds);
  renderNotes(manifest);
}

void main();
