import { Module } from '@nestjs/common';

import { CallersService } from './callers.service.js';

@Module({
  providers: [CallersService],
  exports: [CallersService],
})
export class CallersModule {}
