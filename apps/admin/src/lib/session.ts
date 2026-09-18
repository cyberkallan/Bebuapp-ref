import 'server-only';

import type { Permission, Role } from '@bebu/shared';
import { cookies } from 'next/headers';

import { apiFetch, type ApiResult } from './api-client';
import { adminConfig } from './config';

/** Mirrors `AdminMeView` from the API. */
export interface AdminSession {
  adminId: string;
  tenantId: string | null;
  roles: readonly Role[];
  permissions: readonly Permission[];
  email: string | null;
}

const SESSION_MAX_AGE_SECONDS = 60 * 60 * 12;

/** Raw bearer token stored in the httpOnly session cookie, if any. */
export async function readSessionToken(): Promise<string | null> {
  const store = await cookies();
  return store.get(adminConfig.sessionCookie)?.value ?? null;
}

export async function writeSessionToken(token: string): Promise<void> {
  const store = await cookies();
  store.set(adminConfig.sessionCookie, token, {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: SESSION_MAX_AGE_SECONDS,
  });
}

export async function clearSessionToken(): Promise<void> {
  const store = await cookies();
  store.delete(adminConfig.sessionCookie);
}

/**
 * Resolves the current admin by asking the API. The API is the only authority
 * on roles/permissions; the panel never decodes the token itself.
 */
export async function fetchSession(token: string): Promise<ApiResult<AdminSession>> {
  return apiFetch<AdminSession>('/api/v1/admin/me', { token });
}

export function hasPermission(session: AdminSession, permission: Permission): boolean {
  return session.permissions.includes(permission);
}

/**
 * Builds the dev-mode credential understood by the API's DevTokenVerifier
 * (`dev:<base64url(json)>`). Only used when ADMIN_AUTH_MODE=dev; the API
 * rejects these tokens outright when it runs with Firebase auth.
 */
export function encodeDevBearer(uid: string, email: string): string {
  const payload = JSON.stringify({ uid, email, provider: 'dev' });
  return `Bearer dev:${Buffer.from(payload, 'utf8').toString('base64url')}`;
}
