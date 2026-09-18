import {
  type CallHandler,
  type ExecutionContext,
  Injectable,
  type NestInterceptor,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { type Observable, tap } from 'rxjs';

import { MetricsService } from './metrics.service.js';

/**
 * Records request latency per route template (not per concrete URL, to keep
 * label cardinality bounded).
 */
@Injectable()
export class HttpMetricsInterceptor implements NestInterceptor {
  constructor(private readonly metrics: MetricsService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    if (context.getType() !== 'http') return next.handle();

    const http = context.switchToHttp();
    const req = http.getRequest<Request>();
    const res = http.getResponse<Response>();
    // Express types `req.route` as `any`; narrow it before use.
    const matched = (req as { route?: { path?: unknown } }).route?.path;
    const route = typeof matched === 'string' ? matched : req.path;
    const end = this.metrics.httpRequestDuration.startTimer();

    const observe = (status: number) =>
      end({ method: req.method, route, status: `${Math.floor(status / 100)}xx` });

    return next.handle().pipe(
      tap({
        next: () => observe(res.statusCode),
        error: (err: unknown) => {
          const status =
            typeof (err as { getStatus?: () => number }).getStatus === 'function'
              ? (err as { getStatus: () => number }).getStatus()
              : 500;
          observe(status);
        },
      }),
    );
  }
}
