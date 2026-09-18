/**
 * A tenant is one branded mobile application running on the shared platform.
 * Every tenant-owned row carries `tenantId`; isolation is enforced server-side.
 */
export const TenantStatus = {
  ACTIVE: 'ACTIVE',
  SUSPENDED: 'SUSPENDED',
  ARCHIVED: 'ARCHIVED',
} as const;
export type TenantStatus = (typeof TenantStatus)[keyof typeof TenantStatus];

/**
 * HTTP header every client (mobile app, admin panel) sends to identify the
 * tenant it belongs to. The value is the tenant's public `key`, never its id.
 */
export const TENANT_HEADER = 'x-tenant-key';

/** Request-correlation header echoed back in every response. */
export const REQUEST_ID_HEADER = 'x-request-id';

/**
 * Feature flags a tenant can toggle. Kept as a closed set so the admin UI and
 * the API agree on what exists. Unknown keys are rejected by validation.
 */
export const TenantFeatureFlag = {
  VOICE_CALLS: 'voiceCalls',
  VIDEO_CALLS: 'videoCalls',
  RANDOM_MATCHING: 'randomMatching',
  CHAT: 'chat',
  SHARED_CALLER_POOL: 'sharedCallerPool',
  BECOME_CALLER: 'becomeCaller',
  DAILY_LOGIN_BONUS: 'dailyLoginBonus',
  IN_APP_PURCHASES: 'inAppPurchases',
  WEB_PAYMENTS: 'webPayments',
} as const;
export type TenantFeatureFlag = (typeof TenantFeatureFlag)[keyof typeof TenantFeatureFlag];

export type TenantFeatureFlags = Partial<Record<TenantFeatureFlag, boolean>>;

/** Default flags applied when a tenant has not overridden a value. */
export const DEFAULT_TENANT_FEATURE_FLAGS: Record<TenantFeatureFlag, boolean> = {
  voiceCalls: true,
  videoCalls: true,
  randomMatching: false,
  chat: false,
  sharedCallerPool: false,
  becomeCaller: false,
  dailyLoginBonus: false,
  inAppPurchases: false,
  webPayments: false,
};

export interface TenantBranding {
  displayName: string;
  logoUrl: string | null;
  primaryColor: string;
  secondaryColor: string;
  accentColor: string;
}

export interface TenantLegalUrls {
  privacyPolicyUrl: string | null;
  termsUrl: string | null;
  supportUrl: string | null;
  refundPolicyUrl: string | null;
}

export interface TenantPlatformIds {
  androidPackageName: string | null;
  iosBundleId: string | null;
}
