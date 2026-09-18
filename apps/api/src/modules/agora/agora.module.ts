import { Module } from '@nestjs/common';

import { AgoraTokenService } from './agora-token.service.js';

@Module({
  providers: [AgoraTokenService],
  exports: [AgoraTokenService],
})
export class AgoraModule {}
