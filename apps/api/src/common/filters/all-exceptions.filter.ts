import {
  type ArgumentsHost,
  Catch,
  type ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ThrottlerException } from '@nestjs/throttler';
import { type ApiErrorBody, type ApiErrorDetail, ErrorCode, REQUEST_ID_HEADER } from '@bebu/shared';
import type { Request, Response } from 'express';
import { PinoLogger } from 'nestjs-pino';

import { AppException } from '../errors/app.exception.js';
import { getRequestId } from '../utils/request-context.js';

interface NestErrorBody {
  message?: string | string[];
  error?: string;
  code?: string;
  details?: readonly ApiErrorDetail[];
}

/**
 * Converts every thrown error into the {@link ApiErrorBody} envelope.
 * Unknown errors become a generic 500: stack traces, driver messages and SQL
 * never leave the process. Everything 5xx is logged with the request id.
 */
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(private readonly logger: PinoLogger) {
    this.logger.setContext(AllExceptionsFilter.name);
  }

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const requestId = getRequestId(request);

    const body = this.toBody(exception, requestId);

    if (body.statusCode >= 500) {
      this.logger.error(
        { err: exception, requestId, path: request.originalUrl, method: request.method },
        'unhandled exception',
      );
    } else if (body.statusCode === STATUS_TOO_MANY_REQUESTS) {
      this.logger.warn({ requestId, path: request.originalUrl }, 'rate limited');
    }

    if (!response.headersSent) {
      response.setHeader(REQUEST_ID_HEADER, requestId);
      response.status(body.statusCode).json(body);
    }
  }

  private toBody(exception: unknown, requestId: string): ApiErrorBody {
    if (exception instanceof AppException) {
      return {
        statusCode: exception.getStatus(),
        code: exception.code,
        message: exception.message,
        requestId,
        ...(exception.details ? { details: exception.details } : {}),
      };
    }

    if (exception instanceof ThrottlerException) {
      return {
        statusCode: HttpStatus.TOO_MANY_REQUESTS,
        code: ErrorCode.RATE_LIMITED,
        message: 'Too many requests. Please slow down.',
        requestId,
      };
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const raw = exception.getResponse();
      const nestBody: NestErrorBody = typeof raw === 'string' ? { message: raw } : raw;
      const message = Array.isArray(nestBody.message)
        ? nestBody.message.join('; ')
        : (nestBody.message ?? exception.message);
      return {
        statusCode: status,
        code: this.codeForStatus(status),
        message: status >= 500 ? 'Internal server error' : message,
        requestId,
      };
    }

    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      code: ErrorCode.INTERNAL_ERROR,
      message: 'Internal server error',
      requestId,
    };
  }

  private codeForStatus(status: number): ErrorCode {
    return (
      STATUS_TO_CODE[status] ?? (status >= 500 ? ErrorCode.INTERNAL_ERROR : ErrorCode.VALIDATION_FAILED)
    );
  }
}

const STATUS_TOO_MANY_REQUESTS: number = HttpStatus.TOO_MANY_REQUESTS;

const STATUS_TO_CODE: Readonly<Record<number, ErrorCode>> = {
  [HttpStatus.BAD_REQUEST]: ErrorCode.VALIDATION_FAILED,
  [HttpStatus.UNAUTHORIZED]: ErrorCode.AUTH_REQUIRED,
  [HttpStatus.FORBIDDEN]: ErrorCode.FORBIDDEN,
  [HttpStatus.NOT_FOUND]: ErrorCode.NOT_FOUND,
  [HttpStatus.CONFLICT]: ErrorCode.CONFLICT,
  [HttpStatus.TOO_MANY_REQUESTS]: ErrorCode.RATE_LIMITED,
  [HttpStatus.SERVICE_UNAVAILABLE]: ErrorCode.SERVICE_UNAVAILABLE,
};
