/**
 * Result of verifying a client credential. Independent of Firebase so the
 * auth layer can be tested and, if ever needed, re-pointed to another IdP.
 */
export interface VerifiedIdentity {
  /** Stable subject id (Firebase uid). */
  uid: string;
  email: string | null;
  phoneNumber: string | null;
  /** e.g. "google.com", "phone", "password", "apple.com". */
  provider: string | null;
  emailVerified: boolean;
  /** Custom claims set server-side (never trusted for money, used for hints). */
  claims: Readonly<Record<string, unknown>>;
}

export class TokenVerificationError extends Error {
  constructor(
    public readonly reason: 'invalid' | 'expired' | 'revoked',
    message?: string,
  ) {
    super(message ?? `token ${reason}`);
    this.name = 'TokenVerificationError';
  }
}

export interface TokenVerifier {
  verify(idToken: string): Promise<VerifiedIdentity>;
}

/** DI token for the active {@link TokenVerifier}. */
export const TOKEN_VERIFIER = Symbol('TOKEN_VERIFIER');
