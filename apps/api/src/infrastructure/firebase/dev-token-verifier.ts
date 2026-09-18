import { z } from 'zod';

import {
  TokenVerificationError,
  type TokenVerifier,
  type VerifiedIdentity,
} from './token-verifier.js';

/**
 * Dev-only credential format: `dev:<base64url(json)>` where the JSON matches
 * {@link devTokenSchema}. Lets the mobile app, admin panel and tests run
 * without a Firebase project. The env schema forbids AUTH_MODE=dev in
 * production, and the auth module refuses to construct this class there.
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

export function encodeDevToken(payload: DevTokenPayload): string {
  return DEV_TOKEN_PREFIX + Buffer.from(JSON.stringify(payload), 'utf8').toString('base64url');
}

export class DevTokenVerifier implements TokenVerifier {
  constructor() {
    if (process.env['NODE_ENV'] === 'production') {
      throw new Error('DevTokenVerifier must never be instantiated in production');
    }
  }

  verify(idToken: string): Promise<VerifiedIdentity> {
    if (!idToken.startsWith(DEV_TOKEN_PREFIX)) {
      return Promise.reject(new TokenVerificationError('invalid', 'not a dev token'));
    }
    let parsed: unknown;
    try {
      parsed = JSON.parse(
        Buffer.from(idToken.slice(DEV_TOKEN_PREFIX.length), 'base64url').toString('utf8'),
      );
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
