import 'package:dio/dio.dart';

/// Mirrors the API's `ApiErrorBody` envelope. UI code branches on [code]
/// (stable) and shows [message] (human-readable, may change).
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.requestId,
  });

  final int statusCode;
  final String code;
  final String message;
  final String? requestId;

  bool get isNetworkError => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
  bool get isTenantProblem => code.startsWith('TENANT_');

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['message'] is String) {
      return ApiException(
        statusCode: e.response?.statusCode ?? 500,
        code: data['code'] as String,
        message: data['message'] as String,
        requestId: data['requestId'] as String?,
      );
    }

    final isTimeout = e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
    final noResponse = e.response == null;

    return ApiException(
      statusCode: noResponse ? 0 : (e.response?.statusCode ?? 500),
      code: noResponse
          ? (isTimeout ? 'NETWORK_TIMEOUT' : 'NETWORK_UNREACHABLE')
          : 'INTERNAL_ERROR',
      message: noResponse
          ? (isTimeout
              ? 'The server took too long to respond.'
              : 'Could not reach the server. Check your connection.')
          : 'Something went wrong (HTTP ${e.response?.statusCode}).',
    );
  }

  @override
  String toString() => 'ApiException($statusCode $code: $message)';
}
