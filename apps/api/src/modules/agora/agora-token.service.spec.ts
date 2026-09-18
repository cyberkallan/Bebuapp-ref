import { AppConfig } from '../../config/app-config.js';
import { parseEnv } from '../../config/env.schema.js';
import { AgoraTokenService } from './agora-token.service.js';

const configWith = (overrides: NodeJS.ProcessEnv = {}) =>
  new AppConfig(
    parseEnv({
      DATABASE_URL: 'postgresql://u:p@localhost:5432/db',
      REDIS_URL: 'redis://localhost:6379/0',
      AUTH_MODE: 'dev',
      ...overrides,
    }),
  );

describe('AgoraTokenService', () => {
  const service = new AgoraTokenService(
    configWith({
      AGORA_APP_ID: '970CA35de60c44645bbae8a215061b33',
      AGORA_APP_CERTIFICATE: '5CFd2fd1755d40ecb72977518be15d3b',
      AGORA_TOKEN_TTL_SECONDS: '600',
    }),
  );

  it('issues a channel- and uid-bound AccessToken2 with an expiry', () => {
    const before = Date.now();
    const creds = service.issueRtcToken('call_abc123', 42);
    expect(creds.appId).toBe('970CA35de60c44645bbae8a215061b33');
    expect(creds.channelName).toBe('call_abc123');
    expect(creds.uid).toBe(42);
    expect(creds.token.startsWith('007')).toBe(true);
    expect(creds.token.length).toBeGreaterThan(50);
    const expiresIn = new Date(creds.expiresAt).getTime() - before;
    expect(expiresIn).toBeGreaterThan(590_000);
    expect(expiresIn).toBeLessThanOrEqual(600_500);
  });

  it('never leaks the app certificate', () => {
    const creds = service.issueRtcToken('call_abc123', 42);
    expect(JSON.stringify(creds)).not.toContain('5CFd2fd1755d40ecb72977518be15d3b');
  });

  it('rejects invalid uids and channel names', () => {
    expect(() => service.issueRtcToken('call_abc', 0)).toThrow(RangeError);
    expect(() => service.issueRtcToken('call_abc', 1.5)).toThrow(RangeError);
    expect(() => service.issueRtcToken('bad channel!', 1)).toThrow(RangeError);
  });

  it('derives opaque channel names and random uids', () => {
    expect(AgoraTokenService.channelNameForCall('0b8fd4a0-9c21-4a4e-9d4b-6ea3fd9a8b31')).toBe(
      'call_0b8fd4a09c214a4e9d4b6ea3fd9a8b31',
    );
    const uid = AgoraTokenService.randomUid();
    expect(uid).toBeGreaterThan(0);
    expect(uid).toBeLessThan(2 ** 31);
  });

  it('reports unavailability when not configured', () => {
    const unconfigured = new AgoraTokenService(configWith());
    expect(unconfigured.isConfigured).toBe(false);
    expect(() => unconfigured.issueRtcToken('call_abc', 1)).toThrow(/not configured/);
  });
});
