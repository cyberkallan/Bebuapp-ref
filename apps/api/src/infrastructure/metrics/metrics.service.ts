import { Injectable } from '@nestjs/common';
import { Counter, Gauge, Histogram, Registry, collectDefaultMetrics } from 'prom-client';

/**
 * Prometheus metrics for the process. Domain modules increment the counters
 * below at the point where the event becomes durable (e.g. after the DB
 * transaction commits), never before.
 */
@Injectable()
export class MetricsService {
  readonly registry = new Registry();

  readonly httpRequestDuration = new Histogram({
    name: 'bebu_http_request_duration_seconds',
    help: 'HTTP request latency by route, method and status class',
    labelNames: ['method', 'route', 'status'] as const,
    buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
    registers: [this.registry],
  });

  readonly callsTotal = new Counter({
    name: 'bebu_calls_total',
    help: 'Calls reaching a terminal state, by tenant, type and final state',
    labelNames: ['tenant', 'type', 'state'] as const,
    registers: [this.registry],
  });

  readonly callBilledSeconds = new Counter({
    name: 'bebu_call_billed_seconds_total',
    help: 'Server-measured billed seconds',
    labelNames: ['tenant', 'type'] as const,
    registers: [this.registry],
  });

  readonly activeCalls = new Gauge({
    name: 'bebu_active_calls',
    help: 'Calls currently in an active (non-terminal) state',
    labelNames: ['tenant'] as const,
    registers: [this.registry],
  });

  readonly paymentsTotal = new Counter({
    name: 'bebu_payment_orders_total',
    help: 'Payment orders reaching a terminal status, by tenant, provider and status',
    labelNames: ['tenant', 'provider', 'status'] as const,
    registers: [this.registry],
  });

  readonly walletTransactionsTotal = new Counter({
    name: 'bebu_wallet_transactions_total',
    help: 'Posted ledger entries by tenant and type',
    labelNames: ['tenant', 'type'] as const,
    registers: [this.registry],
  });

  readonly notificationsTotal = new Counter({
    name: 'bebu_notifications_total',
    help: 'Notification decisions by tenant, category and delivery status',
    labelNames: ['tenant', 'category', 'status'] as const,
    registers: [this.registry],
  });

  constructor() {
    collectDefaultMetrics({ register: this.registry, prefix: 'bebu_' });
  }

  async render(): Promise<string> {
    return this.registry.metrics();
  }

  get contentType(): string {
    return this.registry.contentType;
  }
}
