import { Controller, Get, Headers, Res, VERSION_NEUTRAL } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import type { Response } from 'express';

import { Public } from '../../modules/auth/decorators/public.decorator.js';
import { AppConfig } from '../../config/app-config.js';
import { AppException } from '../../common/errors/app.exception.js';
import { MetricsService } from './metrics.service.js';

/**
 * Prometheus scrape endpoint. Protected by a shared bearer token when
 * METRICS_TOKEN is set; must not be exposed on the public ingress otherwise.
 */
@Controller({ path: 'metrics', version: VERSION_NEUTRAL })
@SkipThrottle()
export class MetricsController {
  constructor(
    private readonly metrics: MetricsService,
    private readonly config: AppConfig,
  ) {}

  @Get()
  @Public()
  async scrape(
    @Headers('authorization') authorization: string | undefined,
    @Res() res: Response,
  ): Promise<void> {
    if (!this.config.metrics.enabled) throw AppException.notFound();
    const token = this.config.metrics.token;
    if (token && authorization !== `Bearer ${token}`) throw AppException.unauthorized();

    res.setHeader('Content-Type', this.metrics.contentType);
    res.send(await this.metrics.render());
  }
}
