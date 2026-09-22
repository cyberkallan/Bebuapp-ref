/** Fades `[data-reveal]` elements in as they enter the viewport. */
export function setupReveal(): void {
  const items = Array.from(document.querySelectorAll<HTMLElement>('[data-reveal]'));
  if (!items.length) return;
  if (
    !('IntersectionObserver' in window) ||
    window.matchMedia('(prefers-reduced-motion: reduce)').matches
  ) {
    items.forEach((el) => el.classList.add('is-in'));
    return;
  }
  document.documentElement.classList.add('js');
  // Anything already on screen animates in on the next frame instead of
  // waiting for the observer's first pass.
  const vh = window.innerHeight;
  const pending = items.filter((el) => {
    const r = el.getBoundingClientRect();
    if (r.top < vh && r.bottom > 0) {
      requestAnimationFrame(() => el.classList.add('is-in'));
      return false;
    }
    return true;
  });
  if (!pending.length) return;
  const io = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-in');
          io.unobserve(entry.target);
        }
      }
    },
    { rootMargin: '0px 0px -8% 0px', threshold: 0.08 },
  );
  pending.forEach((el) => io.observe(el));
}

/** Sticky header: adds a hairline once the page has scrolled; mobile menu toggle. */
export function setupHeader(): void {
  const header = document.querySelector<HTMLElement>('[data-header]');
  const toggle = document.querySelector<HTMLButtonElement>('[data-nav-toggle]');
  const links = document.querySelector<HTMLElement>('#nav-links');
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

export function setupYear(): void {
  const el = document.querySelector<HTMLElement>('[data-year]');
  if (el) el.textContent = String(new Date().getFullYear());
}
