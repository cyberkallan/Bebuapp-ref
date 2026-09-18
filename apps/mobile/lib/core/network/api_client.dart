import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../config/app_flavor.dart';
import '../config/server_settings.dart';
import 'api_error.dart';

/// Supplies the current bearer token, if the user is signed in.
typedef TokenProvider = Future<String?> Function();

/// Provider for the token source. Overridden by the auth feature once it is
/// implemented; the default keeps unauthenticated calls (tenant config) working.
final tokenProviderProvider = Provider<TokenProvider>((_) => () async => null);

final apiClientProvider = Provider<ApiClient>((ref) {
  final flavor = ref.watch(appFlavorProvider);
  final baseUrl = ref.watch(effectiveApiBaseUrlProvider);
  final tokenProvider = ref.watch(tokenProviderProvider);
  return ApiClient(
    baseUrl: baseUrl,
    tenantKey: flavor.tenantKey,
    tokenProvider: tokenProvider,
  );
});

/// Thin wrapper over Dio that enforces the platform's HTTP contract:
///  - `X-Tenant-Key` on every request
///  - `Authorization: Bearer <token>` when signed in
///  - a fresh `X-Request-Id` per request (echoed by the API; include it in bug reports)
///  - API error envelopes surfaced as [ApiException] with a stable `code`
class ApiClient {
  ApiClient({
    required String baseUrl,
    required String tenantKey,
    required TokenProvider tokenProvider,
  })  : _tokenProvider = tokenProvider,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 6),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'X-Tenant-Key': tenantKey,
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['X-Request-Id'] = _uuid.v4();
          final token = await _tokenProvider();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  static const _uuid = Uuid();
  final Dio _dio;
  final TokenProvider _tokenProvider;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Object? json) decode,
  }) =>
      _run(() => _dio.get<Object?>(path, queryParameters: query), decode);

  Future<T> post<T>(
    String path, {
    Object? body,
    String? idempotencyKey,
    required T Function(Object? json) decode,
  }) =>
      _run(
        () => _dio.post<Object?>(
          path,
          data: body,
          options: Options(
            headers: idempotencyKey == null ? null : {'Idempotency-Key': idempotencyKey},
          ),
        ),
        decode,
      );

  Future<T> _run<T>(
    Future<Response<Object?>> Function() send,
    T Function(Object? json) decode,
  ) async {
    try {
      final response = await send();
      return decode(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
