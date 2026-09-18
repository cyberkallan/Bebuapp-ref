import type { Metadata } from 'next';
import Link from 'next/link';
import { ArrowRight, Database, Server, Waypoints } from 'lucide-react';

import { ErrorPanel } from '@/components/error-panel';
import { PageHeader } from '@/components/page-header';
import { RefreshButton } from '@/components/refresh-button';
import { StatusPill, type PillTone } from '@/components/status-pill';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { adminConfig } from '@/lib/config';
import { loadPlatformStatus, type DependencyState } from '@/lib/platform';
import { requireSession } from '@/lib/require-session';
import { listTenants } from '@/lib/tenants';

export const metadata: Metadata = { title: 'Overview' };
export const dynamic = 'force-dynamic';

const STATE_TONE: Record<DependencyState, PillTone> = {
  up: 'success',
  down: 'danger',
  unknown: 'neutral',
};
const STATE_LABEL: Record<DependencyState, string> = {
  up: 'Healthy',
  down: 'Down',
  unknown: 'Unknown',
};

export default async function OverviewPage() {
  const { token, session } = await requireSession();
  const [status, tenants] = await Promise.all([loadPlatformStatus(), listTenants(token)]);

  const overall: DependencyState =
    !status.health.ok && status.health.unreachable
      ? 'down'
      : status.dependencies.every((d) => d.state === 'up')
        ? 'up'
        : status.dependencies.some((d) => d.state === 'down')
          ? 'down'
          : 'unknown';

  const tenantCount = tenants.ok ? tenants.data.length : null;
  const activeTenantCount = tenants.ok
    ? tenants.data.filter((t) => t.status === 'ACTIVE').length
    : null;

  return (
    <>
      <PageHeader
        title="Platform overview"
        description="Live status of the bebu API and its dependencies, plus the applications this console can manage."
        actions={<RefreshButton />}
      />

      {status.info.ok ? null : (
        <div className="mb-6">
          <ErrorPanel
            title="The API is not responding"
            error={status.info.error}
            hint={
              <>
                Check that the API is running at{' '}
                <code className="font-mono">{adminConfig.apiUrl}</code> and that{' '}
                <code className="font-mono">BEBU_API_URL</code> points at it.
              </>
            }
          />
        </div>
      )}

      <section aria-label="Summary" className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <SummaryCard
          icon={<Server className="size-4" />}
          label="API"
          value={status.info.ok ? `v${status.info.data.version}` : '—'}
          footer={
            status.info.ok ? (
              <span className="font-mono text-xs text-muted-foreground">
                {status.info.data.environment}
              </span>
            ) : (
              <StatusPill tone="danger">Unreachable</StatusPill>
            )
          }
        />
        <SummaryCard
          icon={<Waypoints className="size-4" />}
          label="Dependencies"
          value={`${status.dependencies.filter((d) => d.state === 'up').length}/${status.dependencies.length}`}
          footer={<StatusPill tone={STATE_TONE[overall]}>{STATE_LABEL[overall]}</StatusPill>}
        />
        <SummaryCard
          icon={<Database className="size-4" />}
          label="Applications"
          value={tenantCount === null ? '—' : String(tenantCount)}
          footer={
            tenantCount === null ? (
              <StatusPill tone="neutral">Unavailable</StatusPill>
            ) : (
              <span className="text-xs text-muted-foreground">{activeTenantCount} active</span>
            )
          }
        />
        <SummaryCard
          label="Your access"
          value={session.roles.map((r) => r.toLowerCase().replaceAll('_', ' ')).join(', ')}
          footer={
            <span className="text-xs text-muted-foreground">
              {session.permissions.length} permissions ·{' '}
              {session.tenantId ? 'single application' : 'all applications'}
            </span>
          }
        />
      </section>

      <section className="mt-6 grid gap-6 lg:grid-cols-5">
        <Card className="lg:col-span-3">
          <CardHeader>
            <CardTitle>Dependency health</CardTitle>
            <CardDescription>
              Readiness probes as reported by <code className="font-mono">/health</code>. A failing
              check removes the instance from the load balancer.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ul className="divide-y">
              {status.dependencies.map((dep) => (
                <li
                  key={dep.key}
                  className="flex items-center justify-between gap-4 py-3 first:pt-0 last:pb-0"
                >
                  <div className="min-w-0">
                    <p className="text-sm font-medium">{dep.label}</p>
                    <p className="truncate font-mono text-xs text-muted-foreground">
                      {dep.detail ?? dep.key}
                    </p>
                  </div>
                  <StatusPill tone={STATE_TONE[dep.state]}>{STATE_LABEL[dep.state]}</StatusPill>
                </li>
              ))}
            </ul>
            <p className="mt-4 text-xs text-muted-foreground">
              Checked {new Date(status.checkedAt).toUTCString()}
            </p>
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Applications</CardTitle>
            <CardDescription>Branded apps served by this platform.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {tenants.ok ? (
              tenants.data.length === 0 ? (
                <p className="text-sm text-muted-foreground">
                  No applications yet. Run <code className="font-mono">pnpm db:seed</code> to create
                  the default bebu app.
                </p>
              ) : (
                <ul className="space-y-2">
                  {tenants.data.slice(0, 5).map((t) => (
                    <li key={t.id}>
                      <Link
                        href={`/tenants/${t.id}`}
                        className="flex items-center justify-between gap-3 rounded-lg border px-3 py-2 transition-colors hover:bg-muted/60"
                      >
                        <span className="flex min-w-0 items-center gap-2.5">
                          <span
                            aria-hidden
                            className="size-2.5 shrink-0 rounded-full"
                            style={{ backgroundColor: t.branding.primaryColor }}
                          />
                          <span className="truncate text-sm font-medium">{t.name}</span>
                          <span className="truncate font-mono text-xs text-muted-foreground">
                            {t.key}
                          </span>
                        </span>
                        <StatusPill tone={t.status === 'ACTIVE' ? 'success' : 'warning'}>
                          {t.status.toLowerCase()}
                        </StatusPill>
                      </Link>
                    </li>
                  ))}
                </ul>
              )
            ) : (
              <ErrorPanel title="Could not load applications" error={tenants.error} />
            )}
            <Link
              href="/tenants"
              className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline"
            >
              Manage applications <ArrowRight className="size-3.5" />
            </Link>
          </CardContent>
        </Card>
      </section>
    </>
  );
}

function SummaryCard({
  icon,
  label,
  value,
  footer,
}: {
  icon?: React.ReactNode;
  label: string;
  value: string;
  footer: React.ReactNode;
}) {
  return (
    <Card size="sm">
      <CardContent className="space-y-2">
        <div className="flex items-center gap-2 text-xs font-medium text-muted-foreground uppercase tracking-wide">
          {icon}
          {label}
        </div>
        <p className="truncate text-2xl font-semibold tracking-tight capitalize">{value}</p>
        <div>{footer}</div>
      </CardContent>
    </Card>
  );
}
