import type { Metadata } from 'next';
import { redirect } from 'next/navigation';

import { BrandMark } from '@/components/brand-mark';
import { DevSignInForm } from '@/components/dev-sign-in-form';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { adminConfig } from '@/lib/config';
import { loadPlatformStatus } from '@/lib/platform';
import { fetchSession, readSessionToken } from '@/lib/session';

export const metadata: Metadata = { title: 'Sign in' };

export default async function SignInPage({ searchParams }: PageProps<'/sign-in'>) {
  const token = await readSessionToken();
  if (token) {
    const existing = await fetchSession(token);
    if (existing.ok) redirect('/');
  }

  const { reason } = await searchParams;
  const status = await loadPlatformStatus();
  const apiUp = status.info.ok;

  return (
    <main className="flex flex-1 items-center justify-center bg-muted/40 px-4 py-12">
      <div className="w-full max-w-md space-y-6">
        <BrandMark className="justify-center" />

        <Card>
          <CardHeader>
            <CardTitle>Sign in to the operations console</CardTitle>
            <CardDescription>
              {adminConfig.authMode === 'dev'
                ? 'This environment uses the development identity provider. Enter the uid and email of a seeded admin account.'
                : 'Sign in with your Firebase-backed admin account.'}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {reason === 'expired' ? (
              <p className="rounded-lg border border-warning/40 bg-warning/10 px-3 py-2 text-sm">
                Your session is no longer valid. Sign in again to continue.
              </p>
            ) : null}

            {adminConfig.authMode === 'dev' ? (
              <DevSignInForm disabled={!apiUp} />
            ) : (
              <p className="rounded-lg border bg-muted px-3 py-2 text-sm text-muted-foreground">
                Firebase sign-in for the admin panel is scheduled for the authentication stage.
                Until then, set <code className="font-mono">ADMIN_AUTH_MODE=dev</code> in
                non-production environments.
              </p>
            )}
          </CardContent>
        </Card>

        <div className="flex items-center justify-between rounded-lg border bg-card px-3 py-2 text-xs text-muted-foreground">
          <span className="truncate">
            API <span className="font-mono">{adminConfig.apiUrl}</span>
          </span>
          <Badge variant={apiUp ? 'secondary' : 'destructive'}>
            {apiUp
              ? `reachable · v${status.info.ok ? status.info.data.version : ''}`
              : 'unreachable'}
          </Badge>
        </div>
      </div>
    </main>
  );
}
