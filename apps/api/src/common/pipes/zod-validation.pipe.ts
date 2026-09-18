import { type ArgumentMetadata, Injectable, type PipeTransform } from '@nestjs/common';
import { ErrorCode } from '@bebu/shared';
import type { ZodType } from 'zod';

import { AppException } from '../errors/app.exception.js';

/**
 * Validates and parses a request part (body/query/params) with a zod schema.
 * Output is the *parsed* value, so defaults and coercions apply and handlers
 * receive fully typed input. Failures return VALIDATION_FAILED with per-field
 * details and never echo the offending raw values.
 */
@Injectable()
export class ZodValidationPipe<T> implements PipeTransform<unknown, T> {
  constructor(private readonly schema: ZodType<T>) {}

  transform(value: unknown, metadata: ArgumentMetadata): T {
    const result = this.schema.safeParse(value);
    if (result.success) return result.data;

    const location = metadata.type; // 'body' | 'query' | 'param' | 'custom'
    throw AppException.badRequest(
      ErrorCode.VALIDATION_FAILED,
      'Request validation failed',
      result.error.issues.map((issue) => ({
        path: [location, ...issue.path.map(String)].join('.'),
        message: issue.message,
      })),
    );
  }
}
