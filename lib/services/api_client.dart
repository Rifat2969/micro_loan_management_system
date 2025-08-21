// lib/services/api_client.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient I = ApiClient._();

  static const String _defaultBaseUrl = 'https://mattress-bacon-refrigerator-refuse.trycloudflare.com';

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
    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
    dio.interceptors.add(_RetryInterceptor(dio: dio));
  }

  void setBaseUrl(String baseUrl) {
    if (baseUrl.isNotEmpty) dio.options.baseUrl = baseUrl;
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(seconds: 2),
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
    return code >= 500 && code < 600;
  }

  Duration _backoff(int attempt) {
    final exp = baseDelay.inMilliseconds * math.pow(2, attempt).toInt();
    final capped = math.min(exp, maxDelay.inMilliseconds);
    return Duration(milliseconds: capped);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    final currentAttempt = (err.requestOptions.extra['attempt'] as int?) ?? 0;
    if (_shouldRetry(err) && currentAttempt < maxRetries) {
      await Future.delayed(_backoff(currentAttempt));
      final newOptions = Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
        responseType: err.requestOptions.responseType,
        contentType: err.requestOptions.contentType,
        sendTimeout: err.requestOptions.sendTimeout,
        receiveTimeout: err.requestOptions.receiveTimeout,
        extra: Map<String, dynamic>.from(err.requestOptions.extra)..['attempt'] = currentAttempt + 1,
      );
      try {
        final res = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: newOptions,
          cancelToken: err.requestOptions.cancelToken,
          onSendProgress: err.requestOptions.onSendProgress,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
        );
        return handler.resolve(res);
      } catch (_) {}
    }
    return handler.next(err);
  }
}
