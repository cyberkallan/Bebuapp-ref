import { Injectable } from '@nestjs/common';
import {
  type CreateTenantInput,
  DEFAULT_TENANT_FEATURE_FLAGS,
  ErrorCode,
  type TenantBranding,
  type TenantFeatureFlag,
  type TenantLegalUrls,
  type TenantPublicConfig,
  type UpdateTenantInput,
  tenantBrandingSchema,
  tenantFeatureFlagsSchema,
  tenantLegalUrlsSchema,
  tenantPricingSchema,
} from '@bebu/shared';
import { PinoLogger } from 'nestjs-pino';
import type { ZodType, z } from 'zod';

import { AppException } from '../../common/errors/app.exception.js';
import { PrismaService } from '../../infrastructure/database/prisma.service.js';
import { RedisService } from '../../infrastructure/redis/redis.service.js';
import type { Tenant } from '../../generated/prisma/client.js';
import type { TenantContext } from './tenant-context.js';

const CONTEXT_CACHE_TTL_SECONDS = 60;

/** Branding/legal/pricing defaults applied when a tenant has not set a value. */
const DEFAULT_BRANDING = {
  logoUrl: null,
  primaryColor: '#6d28d9',
  secondaryColor: '#0f172a',
  accentColor: '#f97316',
};
const DEFAULT_LEGAL = { privacyPolicyUrl: null, termsUrl: null, supportUrl: null, refundPolicyUrl: null };
const DEFAULT_PRICING = {
  currency: 'INR',
  platformCommissionBps: 3_000,
  defaultAudioRatePerMinute: 10,
  defaultVideoRatePerMinute: 20,
  minimumBalanceToCall: 10,
  minimumPayoutCoins: 1_000,
};

@Injectable()
export class TenantsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext(TenantsService.name);
  }

  /**
   * Resolves the request tenant from its public key. Hot path for every
   * request, so the compact context is cached in Redis for a short TTL.
   */
  async resolveContextByKey(key: string): Promise<TenantContext | null> {
    const cacheKey = this.redis.key('tenant', 'ctx', key);
    const cached = await this.redis.client.get(cacheKey).catch(() => null);
    if (cached) return JSON.parse(cached) as TenantContext;

    const tenant = await this.prisma.tenant.findUnique({ where: { key } });
    if (!tenant) return null;

    const context = this.toContext(tenant);
    await this.redis.client
      .set(cacheKey, JSON.stringify(context), 'EX', CONTEXT_CACHE_TTL_SECONDS)
      .catch((err: unknown) => this.logger.warn({ err }, 'tenant cache write failed'));
    return context;
  }

  async invalidateContextCache(key: string): Promise<void> {
    await this.redis.client.del(this.redis.key('tenant', 'ctx', key)).catch(() => undefined);
  }

  /** Configuration a mobile client may see at boot (no secrets, no pricing internals). */
  async getPublicConfig(tenantId: string): Promise<TenantPublicConfig> {
    const tenant = await this.requireById(tenantId);
    const pricing = this.pricingOf(tenant);
    return {
      key: tenant.key,
      name: tenant.name,
      branding: this.brandingOf(tenant),
      legal: this.legalOf(tenant),
      featureFlags: this.flagsOf(tenant),
      supportedCountries: tenant.supportedCountries,
      currency: pricing.currency,
    };
  }

  async requireById(id: string): Promise<Tenant> {
    const tenant = await this.prisma.tenant.findUnique({ where: { id } });
    if (!tenant) throw AppException.notFound(ErrorCode.TENANT_NOT_FOUND, 'Tenant not found');
    return tenant;
  }

  list(): Promise<Tenant[]> {
    return this.prisma.tenant.findMany({ orderBy: { createdAt: 'asc' } });
  }

  async create(input: CreateTenantInput): Promise<Tenant> {
    const existing = await this.prisma.tenant.findUnique({ where: { key: input.key } });
    if (existing) throw AppException.conflict(ErrorCode.CONFLICT, `Tenant key "${input.key}" is taken`);

    return this.prisma.tenant.create({
      data: {
        key: input.key,
        name: input.name,
        androidPackageName: input.androidPackageName,
        iosBundleId: input.iosBundleId,
        supportedCountries: input.supportedCountries,
        branding: { ...DEFAULT_BRANDING, displayName: input.name, ...stripUndefined(input.branding ?? {}) },
        legal: { ...DEFAULT_LEGAL, ...(input.legal ?? {}) },
        featureFlags: input.featureFlags ?? {},
        pricing: { ...DEFAULT_PRICING, ...(input.pricing ?? {}) },
      },
    });
  }

  async update(id: string, input: UpdateTenantInput): Promise<{ before: Tenant; after: Tenant }> {
    const before = await this.requireById(id);
    const after = await this.prisma.tenant.update({
      where: { id },
      data: {
        ...(input.name !== undefined ? { name: input.name } : {}),
        ...(input.status !== undefined ? { status: input.status } : {}),
        ...(input.androidPackageName !== undefined ? { androidPackageName: input.androidPackageName } : {}),
        ...(input.iosBundleId !== undefined ? { iosBundleId: input.iosBundleId } : {}),
        ...(input.supportedCountries !== undefined ? { supportedCountries: input.supportedCountries } : {}),
        ...(input.branding ? { branding: { ...this.brandingOf(before), ...stripUndefined(input.branding) } } : {}),
        ...(input.legal ? { legal: { ...this.legalOf(before), ...stripUndefined(input.legal) } } : {}),
        ...(input.featureFlags
          ? { featureFlags: { ...this.rawFlagsOf(before), ...stripUndefined(input.featureFlags) } }
          : {}),
        ...(input.pricing ? { pricing: { ...this.pricingOf(before), ...stripUndefined(input.pricing) } } : {}),
      },
    });
    await this.invalidateContextCache(before.key);
    return { before, after };
  }

  // --- JSON column accessors with defaults -------------------------------------

  toContext(tenant: Tenant): TenantContext {
    return {
      id: tenant.id,
      key: tenant.key,
      name: tenant.name,
      status: tenant.status,
      featureFlags: this.flagsOf(tenant),
    };
  }

  flagsOf(tenant: Tenant): Record<TenantFeatureFlag, boolean> {
    return { ...DEFAULT_TENANT_FEATURE_FLAGS, ...this.rawFlagsOf(tenant) };
  }

  private rawFlagsOf(tenant: Tenant): Partial<Record<TenantFeatureFlag, boolean>> {
    return this.parseColumn(tenant, 'featureFlags', tenantFeatureFlagsSchema, tenant.featureFlags);
  }

  brandingOf(tenant: Tenant): TenantBranding {
    const stored = this.parseColumn(tenant, 'branding', tenantBrandingSchema.partial(), tenant.branding);
    return { ...DEFAULT_BRANDING, displayName: tenant.name, ...stripUndefined(stored) };
  }

  legalOf(tenant: Tenant): TenantLegalUrls {
    const stored = this.parseColumn(tenant, 'legal', tenantLegalUrlsSchema.partial(), tenant.legal);
    return { ...DEFAULT_LEGAL, ...stripUndefined(stored) };
  }

  pricingOf(tenant: Tenant): TenantPricing {
    const stored = this.parseColumn(tenant, 'pricing', tenantPricingSchema.partial(), tenant.pricing);
    return { ...DEFAULT_PRICING, ...stripUndefined(stored) };
  }

  /**
   * JSON columns are written only through validated inputs, so a parse
   * failure means corrupted configuration. Fail loudly rather than serving
   * defaults that would hide the problem (e.g. wrong pricing).
   */
  private parseColumn<T>(tenant: Tenant, column: string, schema: ZodType<T>, value: unknown): T {
    const parsed = schema.safeParse(value);
    if (!parsed.success) {
      this.logger.error({ tenantId: tenant.id, column, issues: parsed.error.issues }, 'corrupt tenant configuration');
      throw new AppException(ErrorCode.INTERNAL_ERROR, 'Tenant configuration is invalid', 500);
    }
    return parsed.data;
  }
}

/** Removes keys whose value is undefined so spreads do not clobber defaults. */
function stripUndefined<T extends object>(value: T): Partial<T> {
  return Object.fromEntries(Object.entries(value).filter(([, v]) => v !== undefined)) as Partial<T>;
}

type TenantPricing = z.infer<typeof tenantPricingSchema>;
