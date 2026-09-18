import { HttpException, HttpStatus } from '@nestjs/common';
import { type ApiErrorDetail, type ErrorCode, ErrorCode as Codes } from '@bebu/shared';

/**
 * The only exception type handlers should throw. Carries a stable `code` the
 * client can branch on. Messages are safe to show to end users.
 */
export class AppException extends HttpException {
  constructor(
    public readonly code: ErrorCode,
    message: string,
    status: HttpStatus,
    public readonly details?: readonly ApiErrorDetail[],
  ) {
    super({ code, message, details }, status);
    this.name = 'AppException';
  }

  static badRequest(code: ErrorCode, message: string, details?: readonly ApiErrorDetail[]) {
    return new AppException(code, message, HttpStatus.BAD_REQUEST, details);
  }
  static unauthorized(code: ErrorCode = Codes.AUTH_REQUIRED, message = 'Authentication required') {
    return new AppException(code, message, HttpStatus.UNAUTHORIZED);
  }
  static forbidden(code: ErrorCode = Codes.FORBIDDEN, message = 'You do not have access to this resource') {
    return new AppException(code, message, HttpStatus.FORBIDDEN);
  }
  static notFound(code: ErrorCode = Codes.NOT_FOUND, message = 'Resource not found') {
    return new AppException(code, message, HttpStatus.NOT_FOUND);
  }
  static conflict(code: ErrorCode = Codes.CONFLICT, message = 'Conflict') {
    return new AppException(code, message, HttpStatus.CONFLICT);
  }
  static unprocessable(code: ErrorCode, message: string) {
    return new AppException(code, message, HttpStatus.UNPROCESSABLE_ENTITY);
  }
  static serviceUnavailable(code: ErrorCode = Codes.SERVICE_UNAVAILABLE, message = 'Service unavailable') {
    return new AppException(code, message, HttpStatus.SERVICE_UNAVAILABLE);
  }
}
