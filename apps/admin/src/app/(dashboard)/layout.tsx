import { AppShell } from '@/components/app-shell';
import { signOut } from '@/lib/actions/auth';
import { adminConfig } from '@/lib/config';
import { requireSession } from '@/lib/require-session';

export default async function DashboardLayout({ children }: LayoutProps<'/'>) {
  const { session } = await requireSession();

  return (
    <AppShell
      session={session}
      environment={process.env.NODE_ENV}
      authMode={adminConfig.authMode}
      signOutAction={signOut}
    >
      {children}
    </AppShell>
  );
}
