import { afterEach, describe, expect, it, vi } from 'vitest';

import { apiFetch } from './api-client';

const fetchMock = vi.fn<typeof fetch>();
vi.stubGlobal('fetch', fetchMock);

function jsonResponse(
  status: number,
  body: unknown,
  headers: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json', ...headers },
  });
}

afterEach(() => {
  fetchMock.mockReset();
});

describe('apiFetch', () => {
  it('returns parsed data for 2xx responses and sends the expected headers', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse(200, { name: 'bebu-api' }));

    const result = await apiFetch<{ name: string }>('/', {
      token: 'Bearer abc',
      tenantKey: 'bebu',
    });

    expect(result).toEqual({ ok: true, status: 200, data: { name: 'bebu-api' } });
    const [url, init] = fetchMock.mock.calls[0]!;
    expect(String(url)).toBe('http://127.0.0.1:4180/');
    const headers = new Headers(init?.headers);
    expect(headers.get('authorization')).toBe('Bearer abc');
    expect(headers.get('x-tenant-key')).toBe('bebu');
    expect(init?.cache).toBe('no-store');
  });

  it('passes through the API error envelope on non-2xx responses', async () => {
    const envelope = { statusCode: 403, code: 'FORBIDDEN', message: 'No access', requestId: 'r-1' };
    fetchMock.mockResolvedValueOnce(jsonResponse(403, envelope));

    const result = await apiFetch('/api/v1/admin/me');

    expect(result.ok).toBe(false);
    if (result.ok) throw new Error('unreachable');
    expect(result.status).toBe(403);
    expect(result.unreachable).toBe(false);
    expect(result.error).toEqual(envelope);
    expect(result.body).toEqual(envelope);
  });

  it('synthesises an error envelope when the body is not one (e.g. terminus 503)', async () => {
    const terminus = { status: 'error', details: { redis: { status: 'down' } } };
    fetchMock.mockResolvedValueOnce(jsonResponse(503, terminus, { 'x-request-id': 'req-9' }));

    const result = await apiFetch('/health');

    if (result.ok) throw new Error('unreachable');
    expect(result.error.code).toBe('INTERNAL_ERROR');
    expect(result.error.requestId).toBe('req-9');
    expect(result.body).toEqual(terminus);
  });

  it('reports network failures as unreachable without throwing', async () => {
    fetchMock.mockRejectedValueOnce(new TypeError('fetch failed'));

    const result = await apiFetch('/');

    if (result.ok) throw new Error('unreachable');
    expect(result.unreachable).toBe(true);
    expect(result.status).toBe(0);
    expect(result.error.code).toBe('SERVICE_UNAVAILABLE');
    expect(result.error.message).toContain('unreachable');
  });
});
