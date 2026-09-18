import type { Metadata } from 'next';
import Link from 'next/link';

import { ErrorPanel } from '@/components/error-panel';
import { PageHeader } from '@/components/page-header';
import { RefreshButton } from '@/components/refresh-button';
import { StatusPill } from '@/components/status-pill';
import { Card, CardContent } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { formatBps, formatDate } from '@/lib/format';
import { requireSession } from '@/lib/require-session';
import { listTenants } from '@/lib/tenants';

export const metadata: Metadata = { title: 'Applications' };
export const dynamic = 'force-dynamic';

export default async function TenantsPage() {
  const { token } = await requireSession();
  const tenants = await listTenants(token);

  return (
    <>
      <PageHeader
        title="Applications"
        description="Each application is a branded mobile app (tenant) with its own users, pricing, feature flags and store identifiers. Creation and editing land with the admin stage."
        actions={<RefreshButton />}
      />

      {!tenants.ok ? (
        <ErrorPanel title="Could not load applications" error={tenants.error} />
      ) : tenants.data.length === 0 ? (
        <Card>
          <CardContent className="py-10 text-center">
            <p className="font-medium">No applications yet</p>
            <p className="mt-1 text-sm text-muted-foreground">
              Seed the default <span className="font-mono">bebu</span> application with{' '}
              <code className="font-mono">pnpm db:seed</code>.
            </p>
          </CardContent>
        </Card>
      ) : (
        <Card className="py-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Application</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="hidden md:table-cell">Store identifiers</TableHead>
                <TableHead className="hidden lg:table-cell">Pricing</TableHead>
                <TableHead className="hidden sm:table-cell text-right">Updated</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {tenants.data.map((t) => (
                <TableRow key={t.id}>
                  <TableCell>
                    <Link
                      href={`/tenants/${t.id}`}
                      className="flex items-center gap-3 hover:underline"
                    >
                      <span
                        aria-hidden
                        className="size-8 shrink-0 rounded-lg ring-1 ring-foreground/10"
                        style={{ backgroundColor: t.branding.primaryColor }}
                      />
                      <span className="min-w-0">
                        <span className="block truncate font-medium">{t.name}</span>
                        <span className="block truncate font-mono text-xs text-muted-foreground">
                          {t.key}
                        </span>
                      </span>
                    </Link>
                  </TableCell>
                  <TableCell>
                    <StatusPill tone={t.status === 'ACTIVE' ? 'success' : 'warning'}>
                      {t.status.toLowerCase()}
                    </StatusPill>
                  </TableCell>
                  <TableCell className="hidden md:table-cell">
                    <div className="space-y-0.5 font-mono text-xs">
                      <p className="truncate">
                        {t.androidPackageName ?? (
                          <span className="text-muted-foreground">no Android id</span>
                        )}
                      </p>
                      <p className="truncate">
                        {t.iosBundleId ?? <span className="text-muted-foreground">no iOS id</span>}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell className="hidden lg:table-cell text-xs">
                    <p>
                      {t.pricing.defaultAudioRatePerMinute} / {t.pricing.defaultVideoRatePerMinute}{' '}
                      coins·min
                    </p>
                    <p className="text-muted-foreground">
                      {formatBps(t.pricing.platformCommissionBps)} commission
                    </p>
                  </TableCell>
                  <TableCell className="hidden sm:table-cell text-right text-xs text-muted-foreground">
                    {formatDate(t.updatedAt)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Card>
      )}
    </>
  );
}
