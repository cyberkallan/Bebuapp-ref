import { Global, Module } from '@nestjs/common';
import { PinoLogger } from 'nestjs-pino';

import { AppConfig } from '../../config/app-config.js';
import { DevTokenVerifier } from './dev-token-verifier.js';
import { FirebaseTokenVerifier } from './firebase-token-verifier.js';
import { TOKEN_VERIFIER, type TokenVerifier } from './token-verifier.js';

/**
 * Provides the active {@link TokenVerifier}. Firebase Admin is only
 * initialised when AUTH_MODE=firebase, so local development works without
 * Google credentials. FCM sending will hang off the same Firebase app.
 */
@Global()
@Module({
  providers: [
    {
      provide: TOKEN_VERIFIER,
      inject: [AppConfig, PinoLogger],
      useFactory: (config: AppConfig, logger: PinoLogger): TokenVerifier => {
        logger.setContext('FirebaseModule');
        if (config.auth.mode === 'dev') {
          if (config.isProduction) throw new Error('AUTH_MODE=dev is forbidden in production');
          logger.warn(
            config.auth.devSecret
              ? 'AUTH_MODE=dev: accepting HMAC-signed dev tokens (staging).'
              : 'AUTH_MODE=dev: accepting unsigned dev tokens. Never use outside local development.',
          );
          return new DevTokenVerifier({
            secret: config.auth.devSecret,
            appEnv: config.appEnv,
          });
        }
        return new FirebaseTokenVerifier(config);
      },
    },
  ],
  exports: [TOKEN_VERIFIER],
})
export class FirebaseModule {}
