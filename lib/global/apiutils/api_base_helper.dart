import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:template/global/constant/api_const.dart';
import 'package:template/global/constant/string_const.dart';
import 'package:template/global/utils/env_helper.dart';
import 'package:template/global/utils/widget_helper.dart';

class ApiBaseHelper {
  late Dio _dio;

  ApiBaseHelper(String baseUrl) {
    final options = BaseOptions(
      receiveTimeout: Duration(seconds: ApiConstant.timeout),
      connectTimeout: Duration(seconds: ApiConstant.timeout),
      baseUrl: baseUrl,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    _dio = Dio(options);
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
    }
  }

  Future<Response> _handleNoInternet(String url) async {
    return Response(
      requestOptions: RequestOptions(path: url),
      statusCode: ApiResponseCode.internetUnavailable,
      statusMessage: StringConst.noInternetConnection,
    );
  }

  Response _handleApiException(Object e, String url) {
    String message = StringConst.somethingWentWrong;
    int statusCode = ApiResponseCode.unknown;
    if (e is DioException) {
      statusCode = e.response?.statusCode ?? ApiResponseCode.unknown;
      message = _getCleanErrorMessage(e);
    }
    return Response(
      requestOptions: RequestOptions(path: url),
      statusCode: statusCode,
      statusMessage: message,
    );
  }

  String _getCleanErrorMessage(DioException e) {
    final apiError = _extractApiError(e.response);
    if (apiError != null) return apiError;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return StringConst.noInternetConnection;
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return StringConst.somethingWentWrong;
    }
  }

  String? _extractApiError(Response? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    if (data is String && data.isNotEmpty && data.length < 200) return data;
    return null;
  }

  Future<bool> _isInternetAvailable() async => checkInternetConnection();

  Map<String, dynamic>? _sanitizeParams(Map<String, dynamic>? params) {
    params?.removeWhere((_, value) => value == null || (value is String && value.isEmpty));
    return params;
  }

  Future<Response> get({required String url, Map<String, dynamic>? params}) async {
    try {
      if (!await _isInternetAvailable()) return _handleNoInternet(url);
      return await _dio.get(url, queryParameters: _sanitizeParams(params));
    } catch (e) {
      return _handleApiException(e, url);
    }
  }

  Future<Response> post({required String url, Map<String, dynamic>? params}) async {
    try {
      if (!await _isInternetAvailable()) return _handleNoInternet(url);
      return await _dio.post(url, data: _sanitizeParams(params));
    } catch (e) {
      return _handleApiException(e, url);
    }
  }

  Future<Response> put({required String url, Map<String, dynamic>? params}) async {
    try {
      if (!await _isInternetAvailable()) return _handleNoInternet(url);
      return await _dio.put(url, data: _sanitizeParams(params));
    } catch (e) {
      return _handleApiException(e, url);
    }
  }

  Future<Response> delete({required String url, Map<String, dynamic>? params}) async {
    try {
      if (!await _isInternetAvailable()) return _handleNoInternet(url);
      return await _dio.delete(url, data: _sanitizeParams(params));
    } catch (e) {
      return _handleApiException(e, url);
    }
  }
}

class ApiResponseCode {
  static const int success200 = 200;
  static const int internetUnavailable = 999;
  static const int unknown = 533;
}

String _resolveBaseUrl() {
  return envOr('API_BASE_URL', ApiConstant.baseUrl);
}

final apiHelper = ApiBaseHelper(_resolveBaseUrl());
