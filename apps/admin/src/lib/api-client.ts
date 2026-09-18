import "server-only";

import type { ApiErrorBody } from "@bebu/shared";

import { adminConfig } from "./config";

export type ApiResult<T> =
  | { ok: true; data: T; status: number }
  | { ok: false; error: ApiErrorBody; status: number; unreachable: boolean; body: unknown };

interface ApiRequestOptions {
  method?: "GET" | "POST" | "PATCH" | "PUT" | "DELETE";
  token?: string | null;
  tenantKey?: string;
  body?: unknown;
}

/**
 * Thin typed wrapper around fetch for the bebu API. Never throws: network
 * failures and non-2xx responses are folded into the same discriminated union
 * so pages can render precise error states instead of crashing.
 */
export async function apiFetch<T>(path: string, options: ApiRequestOptions = {}): Promise<ApiResult<T>> {
  const headers = new Headers({ Accept: "application/json" });
  if (options.token) headers.set("Authorization", options.token);
  if (options.tenantKey) headers.set("X-Tenant-Key", options.tenantKey);
  if (options.body !== undefined) headers.set("Content-Type", "application/json");

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), adminConfig.requestTimeoutMs);

  try {
    const res = await fetch(`${adminConfig.apiUrl}${path}`, {
      method: options.method ?? "GET",
      headers,
      body: options.body === undefined ? undefined : JSON.stringify(options.body),
      cache: "no-store",
      signal: controller.signal,
    });

    const text = await res.text();
    const json: unknown = text.length > 0 ? safeJson(text) : null;

    if (res.ok) return { ok: true, data: json as T, status: res.status };

    return {
      ok: false,
      status: res.status,
      unreachable: false,
      body: json,
      error: isApiErrorBody(json)
        ? json
        : {
            statusCode: res.status,
            code: "INTERNAL_ERROR",
            message: `API responded with HTTP ${res.status}`,
            requestId: res.headers.get("x-request-id") ?? "",
          },
    };
  } catch (err) {
    const aborted = err instanceof Error && err.name === "AbortError";
    return {
      ok: false,
      status: 0,
      unreachable: true,
      body: null,
      error: {
        statusCode: 503,
        code: "SERVICE_UNAVAILABLE",
        message: aborted
          ? `API did not respond within ${adminConfig.requestTimeoutMs / 1000}s`
          : `API unreachable at ${adminConfig.apiUrl}`,
        requestId: "",
      },
    };
  } finally {
    clearTimeout(timer);
  }
}

function safeJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function isApiErrorBody(value: unknown): value is ApiErrorBody {
  return (
    typeof value === "object" &&
    value !== null &&
    typeof (value as ApiErrorBody).statusCode === "number" &&
    typeof (value as ApiErrorBody).code === "string" &&
    typeof (value as ApiErrorBody).message === "string"
  );
}
