import type { Env } from './env.schema.js';

/**
 * Structured, read-only view of the validated environment. Modules depend on
 * this class (not on `process.env`) so configuration is testable and typed.
 */
export class AppConfig {
  readonly nodeEnv: Env['NODE_ENV'];
  /** Deployment environment; drives the fail-closed security rules. */
  readonly appEnv: Env['APP_ENV'];
  readonly isProduction: boolean;
  readonly isTest: boolean;

  readonly http: Readonly<{
    port: number;
    host: string;
    publicUrl: string;
    corsOrigins: readonly string[];
    trustProxyHops: number;
  }>;

  readonly logging: Readonly<{ level: Env['LOG_LEVEL']; pretty: boolean }>;
  readonly rateLimit: Readonly<{ ttlSeconds: number; max: number }>;
  readonly database: Readonly<{ url: string; poolMax: number }>;
  readonly redis: Readonly<{ url: string; keyPrefix: string }>;

  readonly auth: Readonly<{
    mode: Env['AUTH_MODE'];
    devSecret: string | undefined;
    firebaseProjectId: string | undefined;
    credentialsFile: string | undefined;
    clientEmail: string | undefined;
    privateKey: string | undefined;
  }>;

  readonly agora: Readonly<{
    appId: string | undefined;
    appCertificate: string | undefined;
    tokenTtlSeconds: number;
    isConfigured: boolean;
  }>;

  readonly queue: Readonly<{ workersEnabled: boolean }>;
  readonly metrics: Readonly<{ enabled: boolean; token: string | undefined }>;

  constructor(env: Env) {
    this.nodeEnv = env.NODE_ENV;
    this.appEnv = env.APP_ENV;
    this.isProduction = env.APP_ENV === 'production';
    this.isTest = env.NODE_ENV === 'test';

    this.http = {
      port: env.API_PORT,
      host: env.API_HOST,
      publicUrl: env.API_PUBLIC_URL,
      corsOrigins: env.CORS_ORIGINS,
      trustProxyHops: env.TRUST_PROXY_HOPS,
    };
    this.logging = { level: env.LOG_LEVEL, pretty: env.LOG_PRETTY };
    this.rateLimit = { ttlSeconds: env.RATE_LIMIT_TTL_SECONDS, max: env.RATE_LIMIT_MAX };
    this.database = { url: env.DATABASE_URL, poolMax: env.DATABASE_POOL_MAX };
    this.redis = { url: env.REDIS_URL, keyPrefix: env.REDIS_KEY_PREFIX };
    this.auth = {
      mode: env.AUTH_MODE,
      devSecret: env.DEV_AUTH_SECRET,
      firebaseProjectId: env.FIREBASE_PROJECT_ID,
      credentialsFile: env.GOOGLE_APPLICATION_CREDENTIALS,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY,
    };
    this.agora = {
      appId: env.AGORA_APP_ID,
      appCertificate: env.AGORA_APP_CERTIFICATE,
      tokenTtlSeconds: env.AGORA_TOKEN_TTL_SECONDS,
      isConfigured: Boolean(env.AGORA_APP_ID && env.AGORA_APP_CERTIFICATE),
    };
    this.queue = { workersEnabled: env.QUEUE_WORKERS_ENABLED };
    this.metrics = { enabled: env.METRICS_ENABLED, token: env.METRICS_TOKEN };
  }
}
