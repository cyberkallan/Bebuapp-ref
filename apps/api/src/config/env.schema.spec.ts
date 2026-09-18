import { EnvValidationError, parseEnv } from './env.schema.js';

const base: NodeJS.ProcessEnv = {
  DATABASE_URL: 'postgresql://u:p@localhost:5432/db',
  REDIS_URL: 'redis://localhost:6379/0',
  AUTH_MODE: 'dev',
};

describe('environment schema', () => {
  it('applies defaults for optional values', () => {
    const env = parseEnv(base);
    expect(env.NODE_ENV).toBe('development');
    expect(env.API_PORT).toBe(4180);
    expect(env.CORS_ORIGINS).toEqual([]);
    expect(env.RATE_LIMIT_MAX).toBe(120);
    expect(env.QUEUE_WORKERS_ENABLED).toBe(true);
  });

  it('parses comma-separated origins and boolean strings', () => {
    const env = parseEnv({
      ...base,
      CORS_ORIGINS: ' http://a.test, http://b.test ',
      LOG_PRETTY: '1',
    });
    expect(env.CORS_ORIGINS).toEqual(['http://a.test', 'http://b.test']);
    expect(env.LOG_PRETTY).toBe(true);
  });

  it('fails fast on missing database url with a readable message', () => {
    expect(() => parseEnv({ REDIS_URL: 'redis://x', AUTH_MODE: 'dev' })).toThrow(
      EnvValidationError,
    );
    try {
      parseEnv({ REDIS_URL: 'redis://x', AUTH_MODE: 'dev' });
    } catch (err) {
      expect((err as Error).message).toContain('DATABASE_URL');
    }
  });

  it('refuses dev auth and pretty logs in production', () => {
    expect(() =>
      parseEnv({
        ...base,
        NODE_ENV: 'production',
        AGORA_APP_ID: 'a',
        AGORA_APP_CERTIFICATE: 'c',
      }),
    ).toThrow(/AUTH_MODE must be "firebase"/);

    expect(() =>
      parseEnv({
        ...base,
        NODE_ENV: 'production',
        AUTH_MODE: 'firebase',
        GOOGLE_APPLICATION_CREDENTIALS: '/secrets/sa.json',
        AGORA_APP_ID: 'a',
        AGORA_APP_CERTIFICATE: 'c',
        LOG_PRETTY: 'true',
      }),
    ).toThrow(/LOG_PRETTY/);
  });

  it('requires firebase credentials when AUTH_MODE=firebase', () => {
    expect(() => parseEnv({ ...base, AUTH_MODE: 'firebase' })).toThrow(
      /GOOGLE_APPLICATION_CREDENTIALS/,
    );
    const env = parseEnv({
      ...base,
      AUTH_MODE: 'firebase',
      FIREBASE_PROJECT_ID: 'p',
      FIREBASE_CLIENT_EMAIL: 'sa@p.iam.gserviceaccount.com',
      FIREBASE_PRIVATE_KEY: '-----BEGIN\\nabc\\n-----END',
    });
    expect(env.FIREBASE_PRIVATE_KEY).toBe('-----BEGIN\nabc\n-----END');
  });

  it('derives APP_ENV from NODE_ENV and lets staging use signed dev auth', () => {
    expect(parseEnv(base).APP_ENV).toBe('development');

    // Staging: production runtime, dev auth allowed only with a shared secret.
    expect(() => parseEnv({ ...base, NODE_ENV: 'production', APP_ENV: 'staging' })).toThrow(
      /DEV_AUTH_SECRET/,
    );
    const staging = parseEnv({
      ...base,
      NODE_ENV: 'production',
      APP_ENV: 'staging',
      DEV_AUTH_SECRET: 'x'.repeat(32),
    });
    expect(staging.APP_ENV).toBe('staging');
    expect(staging.AUTH_MODE).toBe('dev');

    // APP_ENV=production is fail-closed regardless of NODE_ENV.
    expect(() =>
      parseEnv({ ...base, APP_ENV: 'production', DEV_AUTH_SECRET: 'x'.repeat(32) }),
    ).toThrow(/AUTH_MODE must be "firebase"/);
  });

  it('requires Agora credentials in production', () => {
    expect(() =>
      parseEnv({
        ...base,
        NODE_ENV: 'production',
        AUTH_MODE: 'firebase',
        GOOGLE_APPLICATION_CREDENTIALS: '/secrets/sa.json',
      }),
    ).toThrow(/AGORA_APP_ID/);
  });
});
