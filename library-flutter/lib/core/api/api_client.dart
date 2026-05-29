import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/secure_token_storage.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';

final secureTokenStorageProvider = Provider<SecureTokenStorage>(
  (ref) => SecureTokenStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureTokenStorageProvider);

  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  dio.interceptors.add(AuthInterceptor(storage));
  dio.interceptors.add(InterceptorsWrapper(
    onError: (e, handler) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final api = ApiException.fromMap(
          e.response!.statusCode ?? 500,
          data,
        );
        return handler.reject(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          error: api,
          type: e.type,
        ));
      }
      handler.next(e);
    },
  ));
  return dio;
});
