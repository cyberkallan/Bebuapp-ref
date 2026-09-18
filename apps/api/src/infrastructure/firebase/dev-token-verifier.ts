import { createHmac, timingSafeEqual } from 'node:crypto';

import { z } from 'zod';

import type { AppEnv } from '../../config/env.schema.js';
import {
  TokenVerificationError,
  type TokenVerifier,
  type VerifiedIdentity,
} from './token-verifier.js';

/**
 * Dev-only credential format: `dev:<base64url(json)>[.<hmac>]` where the JSON
 * matches {@link devTokenSchema}. Lets the mobile app, admin panel and tests
 * run without a Firebase project.
 *
 * - Local development: the signature is optional (no secret configured).
 * - Staging: `DEV_AUTH_SECRET` is mandatory and every token must carry a
 *   matching HMAC-SHA256 signature, so a publicly reachable staging API
 *   cannot be impersonated by anyone who knows a uid.
 * - Production: the env schema forbids AUTH_MODE=dev and this class refuses
 *   to be constructed.
 */
const devTokenSchema = z.object({
  uid: z.string().min(1).max(128),
  email: z.email().optional(),
  phoneNumber: z.string().optional(),
  provider: z.string().optional(),
  claims: z.record(z.string(), z.unknown()).optional(),
});

export type DevTokenPayload = z.infer<typeof devTokenSchema>;

export const DEV_TOKEN_PREFIX = 'dev:';

function sign(body: string, secret: string): string {
  return createHmac('sha256', secret).update(body).digest('base64url');
}

export function encodeDevToken(payload: DevTokenPayload, secret?: string): string {
  const body = Buffer.from(JSON.stringify(payload), 'utf8').toString('base64url');
  return secret ? `${DEV_TOKEN_PREFIX}${body}.${sign(body, secret)}` : DEV_TOKEN_PREFIX + body;
}

export interface DevTokenVerifierOptions {
  /** Shared secret; when set, unsigned or mis-signed tokens are rejected. */
  secret?: string | undefined;
  appEnv?: AppEnv | undefined;
}

export class DevTokenVerifier implements TokenVerifier {
  private readonly secret: string | undefined;

  constructor(options: DevTokenVerifierOptions = {}) {
    const appEnv = options.appEnv ?? process.env['APP_ENV'] ?? process.env['NODE_ENV'];
    if (appEnv === 'production') {
      throw new Error('DevTokenVerifier must never be instantiated in production');
    }
    if (appEnv === 'staging' && !options.secret) {
      throw new Error('DevTokenVerifier requires a shared secret in staging');
    }
    this.secret = options.secret;
  }

  verify(idToken: string): Promise<VerifiedIdentity> {
    if (!idToken.startsWith(DEV_TOKEN_PREFIX)) {
      return Promise.reject(new TokenVerificationError('invalid', 'not a dev token'));
    }
    const [body, signature] = idToken.slice(DEV_TOKEN_PREFIX.length).split('.', 2);
    if (!body) {
      return Promise.reject(new TokenVerificationError('invalid', 'malformed dev token'));
    }

    if (this.secret) {
      const expected = Buffer.from(sign(body, this.secret));
      const actual = Buffer.from(signature ?? '');
      if (expected.length !== actual.length || !timingSafeEqual(expected, actual)) {
        return Promise.reject(
          new TokenVerificationError('invalid', 'dev token signature mismatch'),
        );
      }
    }

    let parsed: unknown;
    try {
      parsed = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
    } catch {
      return Promise.reject(new TokenVerificationError('invalid', 'malformed dev token'));
    }
    const result = devTokenSchema.safeParse(parsed);
    if (!result.success) {
      return Promise.reject(new TokenVerificationError('invalid', 'dev token failed validation'));
    }
    const p = result.data;
    return Promise.resolve({
      uid: p.uid,
      email: p.email ?? null,
      phoneNumber: p.phoneNumber ?? null,
      provider: p.provider ?? 'dev',
      emailVerified: Boolean(p.email),
      claims: p.claims ?? {},
    });
  }
}
