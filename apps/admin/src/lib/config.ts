import 'server-only';

/**
 * Server-side configuration for the admin panel. Nothing here is exposed to
 * the browser: all API calls are made from Server Components / Actions so the
 * admin session token never leaves the server.
 */
export type AdminAuthMode = 'dev' | 'firebase';
export type AppEnv = 'development' | 'staging' | 'production';

/**
 * Deployment environment (mirrors the API's APP_ENV). `NODE_ENV` is always
 * "production" under `next start`, so staging is expressed separately.
 */
export function readAppEnv(): AppEnv {
  const raw = process.env.APP_ENV;
  if (raw === 'staging' || raw === 'production' || raw === 'development') return raw;
  return process.env.NODE_ENV === 'production' ? 'production' : 'development';
}

function readAuthMode(): AdminAuthMode {
  const raw = process.env.ADMIN_AUTH_MODE ?? process.env.AUTH_MODE ?? 'dev';
  if (raw === 'firebase') return 'firebase';
  const appEnv = readAppEnv();
  if (appEnv === 'production') {
    // Fail closed: a production deployment must opt in to a real identity provider.
    throw new Error(
      'ADMIN_AUTH_MODE=dev is not allowed in production; set ADMIN_AUTH_MODE=firebase',
    );
  }
  if (appEnv === 'staging' && !process.env.DEV_AUTH_SECRET) {
    throw new Error('ADMIN_AUTH_MODE=dev in staging requires DEV_AUTH_SECRET');
  }
  return 'dev';
}

export const adminConfig = {
  /** Base URL of the bebu API (no trailing slash). */
  apiUrl: (process.env.BEBU_API_URL ?? 'http://127.0.0.1:4180').replace(/\/$/, ''),
  /**
   * Evaluated lazily so `next build` (which runs with NODE_ENV=production) can
   * analyse the module graph without a configured identity provider.
   */
  get authMode(): AdminAuthMode {
    return readAuthMode();
  },
  get appEnv(): AppEnv {
    return readAppEnv();
  },
  /** Shared secret used to sign dev tokens; must match the API's DEV_AUTH_SECRET. */
  get devAuthSecret(): string | undefined {
    return process.env.DEV_AUTH_SECRET;
  },
  sessionCookie: 'bebu_admin_session',
  /** Upper bound for any single API call from the panel. */
  requestTimeoutMs: 8_000,
};
