import 'server-only';

import type {
  TenantBranding,
  TenantFeatureFlag,
  TenantLegalUrls,
  TenantStatus,
} from '@bebu/shared';

import { apiFetch, type ApiResult } from './api-client';

/** Mirrors `AdminTenantView` from the API. */
export interface AdminTenant {
  id: string;
  key: string;
  name: string;
  status: TenantStatus;
  androidPackageName: string | null;
  iosBundleId: string | null;
  supportedCountries: readonly string[];
  branding: TenantBranding;
  legal: TenantLegalUrls;
  featureFlags: Record<TenantFeatureFlag, boolean>;
  pricing: {
    currency: string;
    platformCommissionBps: number;
    defaultAudioRatePerMinute: number;
    defaultVideoRatePerMinute: number;
    minimumBalanceToCall: number;
    minimumPayoutCoins: number;
  };
  createdAt: string;
  updatedAt: string;
}

export function listTenants(token: string): Promise<ApiResult<AdminTenant[]>> {
  return apiFetch<AdminTenant[]>('/api/v1/admin/tenants', { token });
}

export function getTenant(token: string, tenantId: string): Promise<ApiResult<AdminTenant>> {
  return apiFetch<AdminTenant>(`/api/v1/admin/tenants/${encodeURIComponent(tenantId)}`, { token });
}
