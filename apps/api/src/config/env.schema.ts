import { z } from 'zod';

const booleanString = z
  .enum(['true', 'false', '1', '0'])
  .transform((v) => v === 'true' || v === '1');

const csv = z
  .string()
  .default('')
  .transform((v) =>
    v
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean),
  );

/**
 * Every environment variable the API reads, validated once at boot. Anything
 * missing or malformed aborts startup with a precise message instead of
 * failing later at runtime.
 */
export const APP_ENVS = ['development', 'staging', 'production'] as const;
export type AppEnv = (typeof APP_ENVS)[number];

/**
 * `NODE_ENV` controls runtime behaviour (bundling, logging, caching).
 * `APP_ENV` describes the deployment: a *staging* VPS runs production builds
 * but may still use dev auth (behind a shared secret), whereas *production*
 * is fail-closed. When unset, it is derived from NODE_ENV.
 */
export function resolveAppEnv(source: { NODE_ENV?: string; APP_ENV?: string }): AppEnv {
  const explicit = source.APP_ENV;
  if (explicit && (APP_ENVS as readonly string[]).includes(explicit)) return explicit as AppEnv;
  return source.NODE_ENV === 'production' ? 'production' : 'development';
}

export const envSchema = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    APP_ENV: z.enum(APP_ENVS).optional(),
    API_PORT: z.coerce.number().int().min(1).max(65_535).default(4180),
    API_HOST: z.string().default('0.0.0.0'),
    API_PUBLIC_URL: z.url().default('http://127.0.0.1:4180'),

    LOG_LEVEL: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),
    LOG_PRETTY: booleanString.default(false),

    CORS_ORIGINS: csv,
    RATE_LIMIT_TTL_SECONDS: z.coerce.number().int().positive().default(60),
    RATE_LIMIT_MAX: z.coerce.number().int().positive().default(120),
    TRUST_PROXY_HOPS: z.coerce.number().int().min(0).max(10).default(0),

    DATABASE_URL: z.string().min(1).startsWith('postgres'),
    DATABASE_URL_TEST: z.string().startsWith('postgres').optional(),
    DATABASE_POOL_MAX: z.coerce.number().int().min(1).max(200).default(20),

    REDIS_URL: z.string().min(1).startsWith('redis'),
    REDIS_KEY_PREFIX: z
      .string()
      .regex(/^[a-zA-Z0-9:_-]+$/)
      .default('bebu'),

    AUTH_MODE: z.enum(['firebase', 'dev']).default('firebase'),
    /**
     * When set, dev tokens must carry an HMAC-SHA256 signature made with this
     * secret. Mandatory for AUTH_MODE=dev outside local development so a
     * publicly reachable staging API cannot be impersonated.
     */
    DEV_AUTH_SECRET: z.string().min(32).optional(),
    FIREBASE_PROJECT_ID: z.string().optional(),
    GOOGLE_APPLICATION_CREDENTIALS: z.string().optional(),
    FIREBASE_CLIENT_EMAIL: z.string().optional(),
    FIREBASE_PRIVATE_KEY: z
      .string()
      .optional()
      .transform((v) => v?.replace(/\\n/g, '\n')),

    AGORA_APP_ID: z.string().optional(),
    AGORA_APP_CERTIFICATE: z.string().optional(),
    AGORA_TOKEN_TTL_SECONDS: z.coerce.number().int().min(60).max(86_400).default(3_600),

    QUEUE_WORKERS_ENABLED: booleanString.default(true),

    METRICS_ENABLED: booleanString.default(true),
    METRICS_TOKEN: z.string().optional(),
  })
  .transform((env) => ({ ...env, APP_ENV: resolveAppEnv(env) }))
  .superRefine((env, ctx) => {
    const prod = env.APP_ENV === 'production';

    if (prod && env.AUTH_MODE !== 'firebase') {
      ctx.addIssue({
        code: 'custom',
        path: ['AUTH_MODE'],
        message: 'AUTH_MODE must be "firebase" in production',
      });
    }
    if (env.AUTH_MODE === 'dev' && env.APP_ENV !== 'development' && !env.DEV_AUTH_SECRET) {
      ctx.addIssue({
        code: 'custom',
        path: ['DEV_AUTH_SECRET'],
        message: 'AUTH_MODE=dev outside development requires DEV_AUTH_SECRET (>= 32 chars)',
      });
    }
    if (env.NODE_ENV === 'production' && env.LOG_PRETTY) {
      ctx.addIssue({
        code: 'custom',
        path: ['LOG_PRETTY'],
        message: 'LOG_PRETTY must be false in production (JSON logs)',
      });
    }
    if (env.AUTH_MODE === 'firebase') {
      const hasFile = Boolean(env.GOOGLE_APPLICATION_CREDENTIALS);
      const hasInline = Boolean(
        env.FIREBASE_PROJECT_ID && env.FIREBASE_CLIENT_EMAIL && env.FIREBASE_PRIVATE_KEY,
      );
      if (!hasFile && !hasInline) {
        ctx.addIssue({
          code: 'custom',
          path: ['FIREBASE_PROJECT_ID'],
          message:
            'AUTH_MODE=firebase requires GOOGLE_APPLICATION_CREDENTIALS or FIREBASE_PROJECT_ID + FIREBASE_CLIENT_EMAIL + FIREBASE_PRIVATE_KEY',
        });
      }
    }
    if (prod && (!env.AGORA_APP_ID || !env.AGORA_APP_CERTIFICATE)) {
      ctx.addIssue({
        code: 'custom',
        path: ['AGORA_APP_ID'],
        message: 'AGORA_APP_ID and AGORA_APP_CERTIFICATE are required in production',
      });
    }
  });

export type Env = z.infer<typeof envSchema>;

export class EnvValidationError extends Error {
  constructor(public readonly issues: readonly { path: string; message: string }[]) {
    super(
      `Invalid environment configuration:\n${issues
        .map((i) => `  - ${i.path}: ${i.message}`)
        .join('\n')}`,
    );
    this.name = 'EnvValidationError';
  }
}

export function parseEnv(source: NodeJS.ProcessEnv): Env {
  const result = envSchema.safeParse(source);
  if (!result.success) {
    throw new EnvValidationError(
      result.error.issues.map((i) => ({ path: i.path.join('.'), message: i.message })),
    );
  }
  return result.data;
}
