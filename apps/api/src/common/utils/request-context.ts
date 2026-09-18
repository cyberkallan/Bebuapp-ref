import { randomUUID } from 'node:crypto';

import { REQUEST_ID_HEADER } from '@bebu/shared';
import type { IncomingMessage, ServerResponse } from 'node:http';

import type { Principal } from '../../modules/auth/principal.js';
import type { TenantContext } from '../../modules/tenants/tenant-context.js';

/** Per-request state attached by middleware/guards. */
export interface RequestContext {
  id?: string;
  principal?: Principal;
  tenant?: TenantContext;
}

/** Express/Node request augmented with our per-request context. */
export type ContextualRequest = IncomingMessage & RequestContext;

const REQUEST_ID_PATTERN = /^[A-Za-z0-9._:-]{8,128}$/;

/**
 * Reuses a well-formed inbound X-Request-Id (from a gateway/load balancer) or
 * generates one, and echoes it on the response. Used as pino-http `genReqId`
 * so the same id appears in every log line for the request.
 */
export function ensureRequestId(req: IncomingMessage, res: ServerResponse): string {
  const contextual = req as ContextualRequest;
  if (contextual.id) return contextual.id;

  const inbound = req.headers[REQUEST_ID_HEADER];
  const candidate = Array.isArray(inbound) ? inbound[0] : inbound;
  const id = candidate && REQUEST_ID_PATTERN.test(candidate) ? candidate : randomUUID();

  contextual.id = id;
  if (!res.headersSent) res.setHeader(REQUEST_ID_HEADER, id);
  return id;
}

export function getRequestId(req: IncomingMessage): string {
  return (req as ContextualRequest).id ?? 'unknown';
}
