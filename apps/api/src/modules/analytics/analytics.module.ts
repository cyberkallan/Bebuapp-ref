import { Module } from '@nestjs/common';

/**
 * Analytics. Runtime metrics are exposed by MetricsModule (Prometheus). This
 * module will own business rollups on the ANALYTICS queue (daily active
 * users, call minutes, revenue, conversion per tenant) read by the admin
 * dashboard. Aggregations are derived from PostgreSQL facts, never from
 * client-reported numbers.
 */
@Module({})
export class AnalyticsModule {}
