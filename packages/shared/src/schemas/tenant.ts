import { z } from 'zod';

import { TenantFeatureFlag, TenantStatus } from '../domain/tenant.js';
import { basisPointsSchema, currencyCodeSchema, hexColorSchema, tenantKeySchema } from './common.js';

export const tenantBrandingSchema = z.object({
  displayName: z.string().min(1).max(80),
  logoUrl: z.url().nullable(),
  primaryColor: hexColorSchema,
  secondaryColor: hexColorSchema,
  accentColor: hexColorSchema,
});

export const tenantLegalUrlsSchema = z.object({
  privacyPolicyUrl: z.url().nullable(),
  termsUrl: z.url().nullable(),
  supportUrl: z.url().nullable(),
  refundPolicyUrl: z.url().nullable(),
});

export const tenantFeatureFlagsSchema = z
  .object(
    Object.fromEntries(
      Object.values(TenantFeatureFlag).map((flag) => [flag, z.boolean().optional()]),
    ) as Record<TenantFeatureFlag, z.ZodOptional<z.ZodBoolean>>,
  )
  .strict();

/** Tenant-wide default pricing; callers may override within tenant bounds. */
export const tenantPricingSchema = z.object({
  currency: currencyCodeSchema,
  /** Platform commission on caller earnings. */
  platformCommissionBps: basisPointsSchema,
  defaultAudioRatePerMinute: z.number().int().nonnegative(),
  defaultVideoRatePerMinute: z.number().int().nonnegative(),
  /** Minimum coins a user must hold to start a call (defaults to 1 interval). */
  minimumBalanceToCall: z.number().int().nonnegative(),
  /** Minimum caller earnings before a payout can be requested. */
  minimumPayoutCoins: z.number().int().positive(),
});

export const createTenantSchema = z.object({
  key: tenantKeySchema,
  name: z.string().min(1).max(80),
  androidPackageName: z
    .string()
    .regex(/^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$/)
    .nullable()
    .default(null),
  iosBundleId: z
    .string()
    .regex(/^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$/)
    .nullable()
    .default(null),
  supportedCountries: z.array(z.string().length(2).toUpperCase()).default([]),
  branding: tenantBrandingSchema.partial().optional(),
  legal: tenantLegalUrlsSchema.partial().optional(),
  featureFlags: tenantFeatureFlagsSchema.optional(),
  pricing: tenantPricingSchema.partial().optional(),
});
export type CreateTenantInput = z.infer<typeof createTenantSchema>;

export const updateTenantSchema = createTenantSchema
  .omit({ key: true })
  .partial()
  .extend({ status: z.enum(TenantStatus).optional() });
export type UpdateTenantInput = z.infer<typeof updateTenantSchema>;

/** What a mobile client is allowed to see about its own tenant at boot. */
export const tenantPublicConfigSchema = z.object({
  key: tenantKeySchema,
  name: z.string(),
  branding: tenantBrandingSchema,
  legal: tenantLegalUrlsSchema,
  featureFlags: z.record(z.enum(TenantFeatureFlag), z.boolean()),
  supportedCountries: z.array(z.string()),
  currency: currencyCodeSchema,
});
export type TenantPublicConfig = z.infer<typeof tenantPublicConfigSchema>;
