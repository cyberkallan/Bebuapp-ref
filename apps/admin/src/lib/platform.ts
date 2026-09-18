import "server-only";

import type { ApiInfo, HealthCheckResult } from "@bebu/shared";

import { apiFetch, type ApiResult } from "./api-client";

export type DependencyState = "up" | "down" | "unknown";

export interface DependencyStatus {
  key: string;
  label: string;
  state: DependencyState;
  detail: string | null;
}

export interface PlatformStatus {
  info: ApiResult<ApiInfo>;
  health: ApiResult<HealthCheckResult>;
  dependencies: DependencyStatus[];
  checkedAt: string;
}

const DEPENDENCY_LABELS: Record<string, string> = {
  process: "API process",
  postgres: "PostgreSQL",
  redis: "Redis",
  memory: "Memory",
};

/** Fetches API metadata and the full health report in parallel. */
export async function loadPlatformStatus(): Promise<PlatformStatus> {
  const [info, health] = await Promise.all([
    apiFetch<ApiInfo>("/"),
    apiFetch<HealthCheckResult>("/health"),
  ]);
  return {
    info,
    health,
    dependencies: toDependencies(health),
    checkedAt: new Date().toISOString(),
  };
}

function toDependencies(health: ApiResult<HealthCheckResult>): DependencyStatus[] {
  // Terminus returns the full report with HTTP 503 when any check fails, so a
  // non-ok result may still carry a usable body.
  const body: HealthCheckResult | null = health.ok
    ? health.data
    : isHealthBody(health.body)
      ? health.body
      : null;

  if (!body) {
    return Object.entries(DEPENDENCY_LABELS).map(([key, label]) => ({
      key,
      label,
      state: "unknown",
      detail: null,
    }));
  }

  return Object.entries(body.details).map(([key, value]) => {
    const { status, ...rest } = value;
    return {
      key,
      label: DEPENDENCY_LABELS[key] ?? key,
      state: status === "up" ? "up" : status === "down" ? "down" : "unknown",
      detail: describeDetail(rest),
    };
  });
}

/** Turns indicator metadata into a short human string, e.g. "latency 14 ms". */
function describeDetail(rest: Record<string, unknown>): string | null {
  if (typeof rest.message === "string") return rest.message;
  const parts: string[] = [];
  if (typeof rest.latencyMs === "number") parts.push(`latency ${rest.latencyMs} ms`);
  if (typeof rest.uptimeSeconds === "number") parts.push(`uptime ${formatUptime(rest.uptimeSeconds)}`);
  if (typeof rest.heapUsedMb === "number" && typeof rest.heapTotalMb === "number") {
    parts.push(`heap ${rest.heapUsedMb}/${rest.heapTotalMb} MB`);
  }
  if (typeof rest.rssMb === "number") parts.push(`rss ${rest.rssMb} MB`);
  return parts.length > 0 ? parts.join(" · ") : null;
}

function formatUptime(seconds: number): string {
  if (seconds < 60) return `${Math.round(seconds)}s`;
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m`;
  if (seconds < 86_400) return `${Math.floor(seconds / 3600)}h ${Math.floor((seconds % 3600) / 60)}m`;
  return `${Math.floor(seconds / 86_400)}d ${Math.floor((seconds % 86_400) / 3600)}h`;
}

function isHealthBody(value: unknown): value is HealthCheckResult {
  return typeof value === "object" && value !== null && "details" in value && "status" in value;
}
