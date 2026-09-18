import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';
import type { ApiInfo } from '@bebu/shared';

import { AppConfig } from './config/app-config.js';
import { Public } from './modules/auth/decorators/public.decorator.js';

const API_VERSION = process.env['npm_package_version'] ?? '0.1.0';

@Controller({ version: VERSION_NEUTRAL })
export class AppController {
  constructor(private readonly config: AppConfig) {}

  @Get()
  @Public()
  info(): ApiInfo {
    return {
      name: 'bebu-api',
      version: API_VERSION,
      environment: this.config.nodeEnv,
      docsUrl: null,
      time: new Date().toISOString(),
    };
  }
}
