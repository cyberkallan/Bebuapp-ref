import { Body, Param, Query } from '@nestjs/common';
import type { ZodType } from 'zod';

import { ZodValidationPipe } from '../pipes/zod-validation.pipe.js';

/** `@ValidatedBody(schema)` - parsed, typed request body. */
export const ValidatedBody = <T>(schema: ZodType<T>): ParameterDecorator =>
  Body(new ZodValidationPipe(schema));

/** `@ValidatedQuery(schema)` - parsed, typed query string. */
export const ValidatedQuery = <T>(schema: ZodType<T>): ParameterDecorator =>
  Query(new ZodValidationPipe(schema));

/** `@ValidatedParams(schema)` - parsed, typed route params. */
export const ValidatedParams = <T>(schema: ZodType<T>): ParameterDecorator =>
  Param(new ZodValidationPipe(schema));
