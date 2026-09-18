import { Global, Module, type DynamicModule } from '@nestjs/common';

import { AppConfig } from './app-config.js';
import { type Env, parseEnv } from './env.schema.js';
import { loadRootEnv } from './load-env.js';

/**
 * Global configuration module. `forRoot()` reads and validates the process
 * environment once; `forTest()` lets tests inject an explicit environment
 * without touching `process.env`.
 */
@Global()
@Module({})
export class ConfigModule {
  static forRoot(): DynamicModule {
    loadRootEnv();
    const config = new AppConfig(parseEnv(process.env));
    return ConfigModule.withConfig(config);
  }

  static forTest(overrides: Partial<Env> = {}): DynamicModule {
    const base: NodeJS.ProcessEnv = {
      NODE_ENV: 'test',
      DATABASE_URL: 'postgresql://bebu:bebu@127.0.0.1:5432/bebu_test?schema=public',
      REDIS_URL: 'redis://127.0.0.1:6379/1',
      AUTH_MODE: 'dev',
      LOG_LEVEL: 'fatal',
    };
    const merged: NodeJS.ProcessEnv = { ...base };
    for (const [key, value] of Object.entries(overrides)) {
      merged[key] = Array.isArray(value) ? value.join(',') : String(value);
    }
    return ConfigModule.withConfig(new AppConfig(parseEnv(merged)));
  }

  private static withConfig(config: AppConfig): DynamicModule {
    return {
      module: ConfigModule,
      providers: [{ provide: AppConfig, useValue: config }],
      exports: [AppConfig],
    };
  }
}
