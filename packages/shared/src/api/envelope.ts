/**
 * Successful responses return the resource directly (no wrapper) so that
 * clients can bind typed models with minimal ceremony. Lists use {@link Page}.
 * Errors always use {@link ApiErrorBody}.
 */
export type { Page } from '../schemas/common.js';
export type { ApiErrorBody, ApiErrorDetail } from '../errors/error-codes.js';

/** Health payload for /health/* endpoints. */
export interface HealthCheckResult {
  status: 'ok' | 'error' | 'shutting_down';
  info?: Record<string, { status: string; [key: string]: unknown }>;
  error?: Record<string, { status: string; [key: string]: unknown }>;
  details: Record<string, { status: string; [key: string]: unknown }>;
}

/** Public, unauthenticated metadata served at GET /. */
export interface ApiInfo {
  name: string;
  version: string;
  environment: string;
  docsUrl: string | null;
  time: string;
}
