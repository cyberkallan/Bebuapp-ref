import 'server-only';

import { redirect } from 'next/navigation';

import { fetchSession, readSessionToken, type AdminSession } from './session';

export interface AuthedContext {
  token: string;
  session: AdminSession;
}

/**
 * Guards dashboard pages. Redirects to /sign-in when there is no session or
 * the API rejects it (expired token, admin deactivated). API outages surface
 * as a thrown error so the dashboard error boundary can show a clear message
 * instead of bouncing the operator to the sign-in page.
 */
export async function requireSession(): Promise<AuthedContext> {
  const token = await readSessionToken();
  if (!token) redirect('/sign-in');

  const result = await fetchSession(token);
  if (result.ok) return { token, session: result.data };

  if (result.unreachable) {
    throw new Error(result.error.message);
  }
  // Cookies cannot be mutated during render; the stale cookie is replaced on
  // the next successful sign-in.
  redirect('/sign-in?reason=expired');
}
