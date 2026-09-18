import { randomInt } from 'node:crypto';

import { Injectable } from '@nestjs/common';
import { ErrorCode, type RtcCredentials } from '@bebu/shared';
// agora-token is CommonJS; Node cannot statically detect its named exports.
import agoraToken from 'agora-token';

import { AppException } from '../../common/errors/app.exception.js';
import { AppConfig } from '../../config/app-config.js';

const { RtcRole, RtcTokenBuilder } = agoraToken;

/**
 * Issues short-lived Agora RTC tokens. The App Certificate stays on the
 * server; clients receive only (appId, channel, uid, token). Tokens are bound
 * to one channel and one uid so a leaked token cannot join another call.
 */
@Injectable()
export class AgoraTokenService {
  constructor(private readonly config: AppConfig) {}

  get isConfigured(): boolean {
    return this.config.agora.isConfigured;
  }

  /** Channel names are opaque and unguessable; never derived from user ids. */
  static channelNameForCall(callId: string): string {
    return `call_${callId.replace(/-/g, '')}`;
  }

  /** Agora uids are 32-bit unsigned, non-zero. */
  static randomUid(): number {
    return randomInt(1, 2 ** 31 - 1);
  }

  issueRtcToken(channelName: string, uid: number, ttlSeconds = this.config.agora.tokenTtlSeconds): RtcCredentials {
    const { appId, appCertificate } = this.config.agora;
    if (!appId || !appCertificate) {
      throw AppException.serviceUnavailable(ErrorCode.SERVICE_UNAVAILABLE, 'Real-time calling is not configured');
    }
    if (!Number.isInteger(uid) || uid <= 0 || uid >= 2 ** 32) {
      throw new RangeError('uid must be a positive 32-bit integer');
    }
    if (!/^[A-Za-z0-9_-]{1,64}$/.test(channelName)) {
      throw new RangeError('invalid channel name');
    }

    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      RtcRole.PUBLISHER,
      ttlSeconds,
      ttlSeconds,
    );
    return {
      appId,
      channelName,
      uid,
      token,
      expiresAt: new Date(Date.now() + ttlSeconds * 1000).toISOString(),
    };
  }
}
