import { Global, Module } from '@nestjs/common';

import { HttpMetricsInterceptor } from './http-metrics.interceptor.js';
import { MetricsController } from './metrics.controller.js';
import { MetricsService } from './metrics.service.js';

@Global()
@Module({
  controllers: [MetricsController],
  providers: [MetricsService, HttpMetricsInterceptor],
  exports: [MetricsService, HttpMetricsInterceptor],
})
export class MetricsModule {}
