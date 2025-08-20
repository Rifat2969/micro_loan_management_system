// lib/services/api_client.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient I = ApiClient._();

  static const String _defaultBaseUrl = 'https://cod-concord-dental-mas.trycloudflare.com';

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<void> init() async {
    // Auth header from secure storage (if present)
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        final token = await _secure.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      }),
    );

    // Debug logging
    if (!kReleaseMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ));
    }

    // Simple retry interceptor
    dio.interceptors.add(_RetryInterceptor(dio: dio));
  }

  // Token helpers
  Future<void> saveToken(String token) => _secure.write(key: 'auth_token', value: token);
  Future<void> clearToken() => _secure.delete(key: 'auth_token');
  Future<String?> readToken() => _secure.read(key: 'auth_token');

  // Quick connectivity
  Future<bool> ping() async {
    try {
      final r = await dio.get('/health');
      return (r.statusCode ?? 0) >= 200 && (r.statusCode ?? 0) < 500;
    } catch (_) {
      try {
        final r = await dio.get('/docs');
        return (r.statusCode ?? 0) >= 200 && (r.statusCode ?? 0) < 500;
      } catch (_) {
        return false;
      }
    }
  }

  // Update base URL at runtime if your tunnel changes
  void setBaseUrl(String baseUrl) {
    if (baseUrl.isNotEmpty) dio.options.baseUrl = baseUrl;
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(seconds: 3),
  });

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) return true;
    final code = e.response?.statusCode ?? 0;
    return code >= 500 && code < 600 && code != 501 && code != 505;
  }

  Duration _backoff(int attempt) {
    final exp = baseDelay.inMilliseconds * math.pow(2, attempt).toInt();
    final capped = math.min(exp, maxDelay.inMilliseconds);
    final jitter = math.Random().nextInt(baseDelay.inMilliseconds + 1);
    return Duration(milliseconds: capped + jitter);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final attempt = (req.extra['retry_attempt'] as int?) ?? 0;

    if (_shouldRetry(err) && attempt < maxRetries) {
      await Future.delayed(_backoff(attempt));
      try {
        final resp = await dio.request(
          req.path,
          data: req.data,
          queryParameters: req.queryParameters,
          options: Options(
            method: req.method,
            headers: req.headers,
            responseType: req.responseType,
            contentType: req.contentType,
            followRedirects: req.followRedirects,
            sendTimeout: req.sendTimeout,
            receiveTimeout: req.receiveTimeout,
            validateStatus: req.validateStatus,
            receiveDataWhenStatusError: req.receiveDataWhenStatusError,
            extra: {...req.extra, 'retry_attempt': attempt + 1},
          ),
          cancelToken: req.cancelToken,
          onReceiveProgress: req.onReceiveProgress,
          onSendProgress: req.onSendProgress,
        );
        return handler.resolve(resp);
      } catch (_) {}
    }
    return handler.next(err);
  }
}
