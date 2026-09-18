import { existsSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * Loads `.env` from the repository root (and `.env.local` if present) into
 * `process.env` WITHOUT overriding variables that are already set. Uses the
 * built-in `process.loadEnvFile` (Node >= 21.7) so no dotenv dependency is
 * needed. In production, environment variables come from the platform and no
 * file is loaded.
 */
export function loadRootEnv(): void {
  if (process.env['NODE_ENV'] === 'production') return;

  const here = dirname(fileURLToPath(import.meta.url));
  const candidates = [
    resolve(here, '../../../../.env'), // from dist/config or src/config -> repo root
    resolve(process.cwd(), '.env'),
    resolve(process.cwd(), '../../.env'),
  ];

  const seen = new Set<string>();
  for (const base of candidates) {
    for (const file of [`${base}.local`, base]) {
      if (seen.has(file) || !existsSync(file)) continue;
      seen.add(file);
      const snapshot = { ...process.env };
      process.loadEnvFile(file);
      // loadEnvFile overrides; restore anything that was already defined.
      for (const [key, value] of Object.entries(snapshot)) {
        if (value !== undefined) process.env[key] = value;
      }
    }
    if (seen.size > 0) return;
  }
}
