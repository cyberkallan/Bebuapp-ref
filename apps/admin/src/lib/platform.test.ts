import { describe, expect, it, vi } from 'vitest';

import type { ApiResult } from './api-client';

vi.mock('./api-client', () => ({ apiFetch: vi.fn() }));

import { apiFetch } from './api-client';
import { loadPlatformStatus } from './platform';

const apiFetchMock = vi.mocked(apiFetch);

function ok<T>(data: T): ApiResult<T> {
  return { ok: true, status: 200, data };
}

describe('loadPlatformStatus', () => {
  it('maps a healthy terminus report to dependency rows with human details', async () => {
    apiFetchMock.mockImplementation(async (path: string) => {
      if (path === '/')
        return ok({
          name: 'bebu-api',
          version: '0.1.0',
          environment: 'test',
          docsUrl: null,
          time: '',
        });
      return ok({
        status: 'ok',
        details: {
          process: { status: 'up', uptimeSeconds: 125 },
          postgres: { status: 'up', latencyMs: 14 },
          redis: { status: 'up', latencyMs: 4 },
          memory: { status: 'up', heapUsedMb: 50, heapTotalMb: 122, rssMb: 227 },
        },
      });
    });

    const status = await loadPlatformStatus();

    expect(status.info.ok).toBe(true);
    expect(status.dependencies.map((d) => [d.label, d.state, d.detail])).toEqual([
      ['API process', 'up', 'uptime 2m'],
      ['PostgreSQL', 'up', 'latency 14 ms'],
      ['Redis', 'up', 'latency 4 ms'],
      ['Memory', 'up', 'heap 50/122 MB · rss 227 MB'],
    ]);
  });

  it('still reads dependency states from a 503 health body', async () => {
    apiFetchMock.mockImplementation(async (path: string) => {
      if (path === '/')
        return ok({
          name: 'bebu-api',
          version: '0.1.0',
          environment: 'test',
          docsUrl: null,
          time: '',
        });
      const body = {
        status: 'error',
        details: {
          postgres: { status: 'up', latencyMs: 9 },
          redis: { status: 'down', message: 'connect ECONNREFUSED' },
        },
      };
      return {
        ok: false,
        status: 503,
        unreachable: false,
        body,
        error: { statusCode: 503, code: 'INTERNAL_ERROR', message: 'HTTP 503', requestId: '' },
      };
    });

    const status = await loadPlatformStatus();

    expect(status.dependencies).toEqual([
      { key: 'postgres', label: 'PostgreSQL', state: 'up', detail: 'latency 9 ms' },
      { key: 'redis', label: 'Redis', state: 'down', detail: 'connect ECONNREFUSED' },
    ]);
  });

  it('marks every known dependency unknown when the API is unreachable', async () => {
    apiFetchMock.mockResolvedValue({
      ok: false,
      status: 0,
      unreachable: true,
      body: null,
      error: {
        statusCode: 503,
        code: 'SERVICE_UNAVAILABLE',
        message: 'API unreachable',
        requestId: '',
      },
    });

    const status = await loadPlatformStatus();

    expect(status.dependencies.length).toBeGreaterThan(0);
    expect(status.dependencies.every((d) => d.state === 'unknown')).toBe(true);
  });
});
