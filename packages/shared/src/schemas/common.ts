import { z } from 'zod';

/** UUID v4/v7 primary keys. */
export const idSchema = z.uuid();

/**
 * Public tenant key sent in the X-Tenant-Key header. Lowercase slug so it is
 * safe in URLs, Redis keys and logs.
 */
export const tenantKeySchema = z
  .string()
  .min(2)
  .max(64)
  .regex(/^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/, 'must be a lowercase slug (a-z, 0-9, -)');

/** Integer coin amount, never negative. */
export const coinAmountSchema = z.number().int().nonnegative().safe();

/** Strictly positive integer coin amount for charges, purchases, grants. */
export const positiveCoinAmountSchema = z.number().int().positive().safe();

/** Fiat amount in minor units (paise, cents). */
export const minorUnitsSchema = z.number().int().nonnegative().safe();

/** ISO 4217 currency code. */
export const currencyCodeSchema = z.string().length(3).toUpperCase();

/** Basis points for commission/pricing (0 - 10000). */
export const basisPointsSchema = z.number().int().min(0).max(10_000);

/**
 * Idempotency key supplied by clients on every mutating financial request.
 * Opaque to the server; uniqueness is enforced per (tenant, principal).
 */
export const idempotencyKeySchema = z.string().min(8).max(128);

export const paginationQuerySchema = z.object({
  /** Opaque cursor from a previous response. */
  cursor: z.string().max(512).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});
export type PaginationQuery = z.infer<typeof paginationQuerySchema>;

export interface Page<T> {
  items: readonly T[];
  nextCursor: string | null;
}

/** Hex color like #1a2b3c. */
export const hexColorSchema = z.string().regex(/^#[0-9a-fA-F]{6}$/, 'must be a #rrggbb hex color');

/** IANA timezone identifier (loosely validated; runtime checks with Intl). */
export const timezoneSchema = z
  .string()
  .min(1)
  .max(64)
  .refine((tz) => {
    try {
      new Intl.DateTimeFormat('en-US', { timeZone: tz });
      return true;
    } catch {
      return false;
    }
  }, 'must be a valid IANA timezone');
