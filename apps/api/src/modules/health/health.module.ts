import { Module } from '@nestjs/common';
import { TerminusModule } from '@nestjs/terminus';

import { HealthController } from './health.controller.js';

@Module({
  imports: [
    TerminusModule.forRoot({
      // Suppress terminus' own console logging; failures surface via pino.
      logger: false,
      errorLogStyle: 'json',
    }),
  ],
  controllers: [HealthController],
})
export class HealthModule {}
