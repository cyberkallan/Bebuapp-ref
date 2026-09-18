import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft, ExternalLink } from "lucide-react";

import { ErrorPanel } from "@/components/error-panel";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { formatBps, formatCoins, formatDate, humanize } from "@/lib/format";
import { requireSession } from "@/lib/require-session";
import { getTenant } from "@/lib/tenants";

export const dynamic = "force-dynamic";

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function generateMetadata({ params }: PageProps<"/tenants/[tenantId]">): Promise<Metadata> {
  const { tenantId } = await params;
  return { title: `Application ${tenantId.slice(0, 8)}` };
}

export default async function TenantDetailPage({ params }: PageProps<"/tenants/[tenantId]">) {
  const { tenantId } = await params;
  if (!UUID_PATTERN.test(tenantId)) notFound();

  const { token } = await requireSession();
  const result = await getTenant(token, tenantId);
  if (!result.ok && (result.status === 404 || result.status === 403)) notFound();

  if (!result.ok) {
    return (
      <>
        <BackLink />
        <ErrorPanel title="Could not load this application" error={result.error} />
      </>
    );
  }

  const t = result.data;
  const enabledFlags = Object.entries(t.featureFlags).filter(([, on]) => on).map(([k]) => k);
  const disabledFlags = Object.entries(t.featureFlags).filter(([, on]) => !on).map(([k]) => k);

  return (
    <>
      <BackLink />
      <PageHeader
        title={t.name}
        description={`Tenant key ${t.key} · created ${formatDate(t.createdAt)}`}
        actions={<StatusPill tone={t.status === "ACTIVE" ? "success" : "warning"}>{t.status.toLowerCase()}</StatusPill>}
      />

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Branding</CardTitle>
            <CardDescription>Applied by the mobile app at launch from the public tenant config.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-4">
              <div
                aria-hidden
                className="grid size-16 place-items-center rounded-2xl text-lg font-semibold text-white shadow-inner"
                style={{ backgroundColor: t.branding.primaryColor }}
              >
                {t.branding.displayName.slice(0, 1).toUpperCase()}
              </div>
              <div>
                <p className="font-medium">{t.branding.displayName}</p>
                <p className="text-xs text-muted-foreground">
                  {t.branding.logoUrl ? (
                    <a href={t.branding.logoUrl} className="inline-flex items-center gap-1 hover:underline" target="_blank" rel="noreferrer">
                      Logo <ExternalLink className="size-3" />
                    </a>
                  ) : (
                    "No logo uploaded"
                  )}
                </p>
              </div>
            </div>
            <dl className="grid grid-cols-3 gap-3">
              <Swatch label="Primary" value={t.branding.primaryColor} />
              <Swatch label="Secondary" value={t.branding.secondaryColor} />
              <Swatch label="Accent" value={t.branding.accentColor} />
            </dl>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Pricing defaults</CardTitle>
            <CardDescription>Callers may set their own rates within the bounds the tenant allows.</CardDescription>
          </CardHeader>
          <CardContent>
            <dl className="grid grid-cols-2 gap-x-6 gap-y-3 text-sm">
              <Fact label="Currency" value={t.pricing.currency} mono />
              <Fact label="Platform commission" value={formatBps(t.pricing.platformCommissionBps)} />
              <Fact label="Audio rate" value={`${t.pricing.defaultAudioRatePerMinute} coins / min`} />
              <Fact label="Video rate" value={`${t.pricing.defaultVideoRatePerMinute} coins / min`} />
              <Fact label="Minimum balance to call" value={formatCoins(t.pricing.minimumBalanceToCall)} />
              <Fact label="Minimum payout" value={formatCoins(t.pricing.minimumPayoutCoins)} />
            </dl>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Feature flags</CardTitle>
            <CardDescription>Server-side switches; the app reads them from the tenant config.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <FlagList label="Enabled" flags={enabledFlags} tone="success" />
            <FlagList label="Disabled" flags={disabledFlags} tone="neutral" />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Stores & legal</CardTitle>
            <CardDescription>Identifiers used for IAP verification and links surfaced in the app.</CardDescription>
          </CardHeader>
          <CardContent>
            <dl className="grid gap-3 text-sm">
              <Fact label="Android package" value={t.androidPackageName ?? "Not set"} mono={Boolean(t.androidPackageName)} />
              <Fact label="iOS bundle id" value={t.iosBundleId ?? "Not set"} mono={Boolean(t.iosBundleId)} />
              <Fact
                label="Supported countries"
                value={t.supportedCountries.length > 0 ? t.supportedCountries.join(", ") : "All countries"}
                mono={t.supportedCountries.length > 0}
              />
              <LegalLink label="Privacy policy" href={t.legal.privacyPolicyUrl} />
              <LegalLink label="Terms of service" href={t.legal.termsUrl} />
              <LegalLink label="Refund policy" href={t.legal.refundPolicyUrl} />
              <LegalLink label="Support" href={t.legal.supportUrl} />
            </dl>
          </CardContent>
        </Card>
      </div>
    </>
  );
}

function BackLink() {
  return (
    <Link href="/tenants" className="mb-4 inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground">
      <ArrowLeft className="size-3.5" /> All applications
    </Link>
  );
}

function Swatch({ label, value }: { label: string; value: string }) {
  return (
    <div className="space-y-1.5">
      <div className="h-10 rounded-lg ring-1 ring-foreground/10" style={{ backgroundColor: value }} />
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd className="font-mono text-xs">{value}</dd>
    </div>
  );
}

function Fact({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="space-y-0.5">
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd className={mono ? "font-mono text-xs" : "font-medium"}>{value}</dd>
    </div>
  );
}

function LegalLink({ label, href }: { label: string; href: string | null }) {
  return (
    <div className="space-y-0.5">
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd>
        {href ? (
          <a href={href} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1 text-primary hover:underline">
            <span className="truncate">{href}</span> <ExternalLink className="size-3 shrink-0" />
          </a>
        ) : (
          <span className="text-muted-foreground">Not set</span>
        )}
      </dd>
    </div>
  );
}

function FlagList({ label, flags, tone }: { label: string; flags: string[]; tone: "success" | "neutral" }) {
  return (
    <div>
      <p className="mb-1.5 text-xs text-muted-foreground">{label}</p>
      {flags.length === 0 ? (
        <p className="text-sm text-muted-foreground">None</p>
      ) : (
        <div className="flex flex-wrap gap-1.5">
          {flags.map((flag) => (
            <StatusPill key={flag} tone={tone}>
              {humanize(flag)}
            </StatusPill>
          ))}
        </div>
      )}
    </div>
  );
}
