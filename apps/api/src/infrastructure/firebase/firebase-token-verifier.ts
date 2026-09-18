import { type App, applicationDefault, cert, getApps, initializeApp } from 'firebase-admin/app';
import { type Auth, getAuth } from 'firebase-admin/auth';

import type { AppConfig } from '../../config/app-config.js';
import {
  TokenVerificationError,
  type TokenVerifier,
  type VerifiedIdentity,
} from './token-verifier.js';

/**
 * Verifies Firebase ID tokens with the Admin SDK. Credentials come from a
 * mounted service-account file or inline env vars; they never ship in a
 * client. `checkRevoked` is on so sign-out-everywhere takes effect promptly.
 */
export class FirebaseTokenVerifier implements TokenVerifier {
  private readonly auth: Auth;

  constructor(config: AppConfig) {
    this.auth = getAuth(FirebaseTokenVerifier.initApp(config));
  }

  private static initApp(config: AppConfig): App {
    const existing = getApps()[0];
    if (existing) return existing;

    if (config.auth.credentialsFile) {
      return initializeApp({
        credential: applicationDefault(),
        projectId: config.auth.firebaseProjectId,
      });
    }
    return initializeApp({
      credential: cert({
        projectId: config.auth.firebaseProjectId,
        clientEmail: config.auth.clientEmail,
        privateKey: config.auth.privateKey,
      }),
      projectId: config.auth.firebaseProjectId,
    });
  }

  async verify(idToken: string): Promise<VerifiedIdentity> {
    try {
      const decoded = await this.auth.verifyIdToken(idToken, true);
      const { uid, email, phone_number, email_verified, firebase, ...rest } = decoded;
      const reserved = new Set(['aud', 'auth_time', 'exp', 'iat', 'iss', 'sub']);
      const claims = Object.fromEntries(Object.entries(rest).filter(([k]) => !reserved.has(k)));
      return {
        uid,
        email: email ?? null,
        phoneNumber: phone_number ?? null,
        provider: firebase.sign_in_provider ?? null,
        emailVerified: email_verified ?? false,
        claims,
      };
    } catch (err) {
      const code = (err as { code?: string }).code ?? '';
      if (code === 'auth/id-token-expired') throw new TokenVerificationError('expired');
      if (code === 'auth/id-token-revoked') throw new TokenVerificationError('revoked');
      throw new TokenVerificationError('invalid');
    }
  }
}
