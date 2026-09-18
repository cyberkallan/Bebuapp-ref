import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  type HealthCheckResult,
  HealthIndicatorService,
} from '@nestjs/terminus';
import { SkipThrottle } from '@nestjs/throttler';

import { PrismaService } from '../../infrastructure/database/prisma.service.js';
import { RedisService } from '../../infrastructure/redis/redis.service.js';
import { Public } from '../auth/decorators/public.decorator.js';

/**
 * Kubernetes-style probes.
 * - /health/live  : process is up (never touches dependencies).
 * - /health/ready : dependencies reachable; failing removes the pod from
 *                   the load balancer without restarting it.
 * - /health       : full report for humans/dashboards.
 */
@Controller({ path: 'health', version: VERSION_NEUTRAL })
@Public()
@SkipThrottle()
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly indicator: HealthIndicatorService,
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  @Get('live')
  @HealthCheck()
  live(): Promise<HealthCheckResult> {
    return this.health.check([
      () => this.indicator.check('process').up({ uptimeSeconds: Math.round(process.uptime()) }),
    ]);
  }

  @Get('ready')
  @HealthCheck()
  ready(): Promise<HealthCheckResult> {
    return this.health.check([() => this.checkDatabase(), () => this.checkRedis()]);
  }

  @Get()
  @HealthCheck()
  full(): Promise<HealthCheckResult> {
    return this.health.check([
      () => this.indicator.check('process').up({ uptimeSeconds: Math.round(process.uptime()) }),
      () => this.checkDatabase(),
      () => this.checkRedis(),
      () => this.checkMemory(),
    ]);
  }

  private async checkDatabase() {
    const session = this.indicator.check('postgres');
    const started = performance.now();
    try {
      await this.prisma.ping();
      return session.up({ latencyMs: Math.round(performance.now() - started) });
    } catch (err) {
      return session.down({ message: (err as Error).message });
    }
  }

  private async checkRedis() {
    const session = this.indicator.check('redis');
    const started = performance.now();
    try {
      await this.redis.ping();
      return session.up({ latencyMs: Math.round(performance.now() - started) });
    } catch (err) {
      return session.down({ message: (err as Error).message });
    }
  }

  private checkMemory() {
    const session = this.indicator.check('memory');
    const { heapUsed, heapTotal, rss } = process.memoryUsage();
    const data = {
      heapUsedMb: Math.round(heapUsed / 1_048_576),
      heapTotalMb: Math.round(heapTotal / 1_048_576),
      rssMb: Math.round(rss / 1_048_576),
    };
    // Degraded (still serving) above 1.5 GiB RSS; tune per deployment size.
    return rss > 1.5 * 1_073_741_824 ? session.degraded(data) : session.up(data);
  }
}
