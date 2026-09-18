import 'server-only';

import type { Route } from 'next';
import { headers } from 'next/headers';
import { redirect } from 'next/navigation';

/**
 * `redirect()` inside a Server Action behaves differently depending on how
 * the action was invoked:
 *
 *  - Fetch-based (hydrated React form): Next returns an `x-action-redirect`
 *    header with the app-relative path and the client router prepends
 *    `basePath` itself.
 *  - Classic full-page POST (JS disabled, or the user submitted before
 *    hydration finished): Next answers `303 Location: <path>` verbatim, so a
 *    console served under `/admin` would land on the domain root.
 *
 * Fetch-based actions always carry the `Next-Action` header, so we add the
 * base path only when it is absent.
 */
export async function redirectWithinApp(path: `/${string}`): Promise<never> {
  const requestHeaders = await headers();
  const isClientAction = requestHeaders.has('next-action');
  const basePath = (process.env.ADMIN_BASE_PATH ?? '').replace(/\/$/, '');
  const target = isClientAction || !basePath ? path : `${basePath}${path}`;
  // The prefixed form is deliberately outside the typed route table.
  redirect(target as Route);
}
