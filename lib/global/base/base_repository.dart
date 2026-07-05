import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:template/global/apiutils/api_base_helper.dart';
import 'package:template/global/utils/global_utility.dart';

// ============ RESULT WRAPPER ============

/// Clean Result wrapper for all operations (API, local, sync)
/// 
/// Usage:
/// ```dart
/// final result = await repository.getUser(id);
/// result.fold(
///   onSuccess: (user) => print(user.name),
///   onFailure: (error) => print(error),
/// );
/// ```
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);
  factory Result.failure(String error) => Result._(error: error, isSuccess: false);

  bool get isFailure => !isSuccess;

  /// Get data or throw
  T get dataOrThrow {
    if (isSuccess && data != null) return data as T;
    throw Exception(error ?? 'Unknown error');
  }

  /// Get data or default
  T getOrDefault(T defaultValue) => 
      isSuccess && data != null ? data as T : defaultValue;

  /// Transform success data
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) return Result.success(mapper(data as T));
    return Result.failure(error ?? 'Unknown error');
  }

  /// Handle both success and failure
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onFailure,
  }) {
    if (isSuccess && data != null) return onSuccess(data as T);
    return onFailure(error ?? 'Unknown error');
  }

  /// Execute on success only
  void onSuccess(void Function(T data) callback) {
    if (isSuccess && data != null) callback(data as T);
  }

  /// Execute on failure only
  void onFailure(void Function(String error) callback) {
    if (isFailure) callback(error ?? 'Unknown error');
  }
}

// ============ BASE REPOSITORY ============

/// Base Repository for API operations
/// 
/// Usage:
/// ```dart
/// class UserRepository extends BaseRepository {
///   Future<Result<User>> getUser(String id) => get(
///     url: '/users/$id',
///     parser: User.fromJson,
///   );
///   
///   Future<Result<List<User>>> getUsers() => getList(
///     url: '/users',
///     itemParser: User.fromJson,
///   );
/// }
/// ```
abstract class BaseRepository {
  ApiBaseHelper get api => apiHelper;

  // ============ API METHODS ============

  /// GET request with auto-parsing
  @protected
  Future<Result<T>> get<T>({
    required String url,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? params,
    String? dataKey,
  }) async {
    return _handleResponse(
      api.get(url: url, params: params),
      parser,
      dataKey,
    );
  }

  /// GET request for list data
  @protected
  Future<Result<List<T>>> getList<T>({
    required String url,
    required T Function(dynamic item) itemParser,
    Map<String, dynamic>? params,
    String? listKey,
  }) async {
    return _handleListResponse(
      api.get(url: url, params: params),
      itemParser,
      listKey,
    );
  }

  /// POST request with auto-parsing
  @protected
  Future<Result<T>> post<T>({
    required String url,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? params,
    String? dataKey,
  }) async {
    return _handleResponse(
      api.post(url: url, params: params),
      parser,
      dataKey,
    );
  }

  /// PUT request with auto-parsing
  @protected
  Future<Result<T>> put<T>({
    required String url,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? params,
    String? dataKey,
  }) async {
    return _handleResponse(
      api.put(url: url, params: params),
      parser,
      dataKey,
    );
  }

  /// DELETE request with auto-parsing
  @protected
  Future<Result<T>> delete<T>({
    required String url,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? params,
    String? dataKey,
  }) async {
    return _handleResponse(
      api.delete(url: url, params: params),
      parser,
      dataKey,
    );
  }

  /// Raw request (returns Response)
  @protected
  Future<Result<Response>> raw(Future<Response> apiCall) async {
    try {
      final response = await apiCall;
      if (response.statusCode == ApiResponseCode.success200) {
        return Result.success(response);
      }
      return Result.failure(_getErrorMessage(response));
    } catch (e) {
      return Result.failure(_handleException(e));
    }
  }

  // ============ LOCAL OPERATIONS ============

  /// Wrap async operation in Result
  @protected
  Future<Result<T>> execute<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Wrap sync operation in Result
  @protected
  Result<T> executeSync<T>(T Function() action) {
    try {
      return Result.success(action());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ============ PRIVATE HELPERS ============

  Future<Result<T>> _handleResponse<T>(
    Future<Response> apiCall,
    T Function(dynamic data) parser,
    String? dataKey,
  ) async {
    try {
      final response = await apiCall;
      if (response.statusCode == ApiResponseCode.success200) {
        final data = dataKey != null ? response.data[dataKey] : response.data;
        return Result.success(parser(data));
      }
      return Result.failure(_getErrorMessage(response));
    } catch (e) {
      return Result.failure(_handleException(e));
    }
  }

  Future<Result<List<T>>> _handleListResponse<T>(
    Future<Response> apiCall,
    T Function(dynamic item) itemParser,
    String? listKey,
  ) async {
    try {
      final response = await apiCall;
      if (response.statusCode == ApiResponseCode.success200) {
        final data = listKey != null ? response.data[listKey] : response.data;
        if (data is List) {
          return Result.success(data.map((e) => itemParser(e)).toList());
        }
        return Result.failure('Expected list data');
      }
      return Result.failure(_getErrorMessage(response));
    } catch (e) {
      return Result.failure(_handleException(e));
    }
  }

  String _getErrorMessage(Response response) {
    if (response.statusCode == ApiResponseCode.internetUnavailable) {
      return 'No internet connection';
    }
    return response.statusMessage ?? 'Request failed';
  }

  String _handleException(Object e) {
    if (e is DioException) {
      // Try to get exact error from API response first
      final apiError = _extractApiError(e.response);
      if (apiError != null) return apiError;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Please try again.';
        case DioExceptionType.sendTimeout:
          return 'Request timeout. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Server took too long to respond.';
        case DioExceptionType.transformTimeout:
          return 'Response transform timeout. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.badCertificate:
          return 'Security certificate error.';
        case DioExceptionType.badResponse:
          return 'Error ${e.response?.statusCode ?? ''}: ${e.response?.statusMessage ?? 'Request failed'}';
        case DioExceptionType.unknown:
          if (e.message?.contains('SocketException') == true) {
            return 'No internet connection.';
          }
          return 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }

  /// Extract error message from API response body
  String? _extractApiError(Response? response) {
    if (response?.data == null) return null;

    final data = response!.data;

    // Handle Map response
    if (data is Map<String, dynamic>) {
      // Common error message keys
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String? ??
          data['errorMessage'] as String? ??
          (data['error'] is Map ? data['error']['message'] as String? : null) ??
          (data['errors'] is List && (data['errors'] as List).isNotEmpty
              ? (data['errors'] as List).first.toString()
              : null);
    }

    // Handle String response
    if (data is String && data.isNotEmpty && data.length < 200) {
      return data;
    }

    return null;
  }

  /// Debug log (only in debug mode)
  @protected
  void log(String message) {
    if (kDebugMode) printLog(msg:'[${runtimeType.toString()}] $message');
  }
}

// ============ CACHEABLE MIXIN ============

/// Simple in-memory caching for repositories
/// 
/// Usage:
/// ```dart
/// class UserRepository extends BaseRepository with Cacheable {
///   Future<Result<User>> getUser(String id) => cached(
///     key: 'user_$id',
///     fetcher: () => get(url: '/users/$id', parser: User.fromJson),
///   );
/// }
/// ```
mixin Cacheable on BaseRepository {
  final Map<String, _CacheEntry> _cache = {};

  /// Get from cache or fetch
  Future<Result<T>> cached<T>({
    required String key,
    required Future<Result<T>> Function() fetcher,
    Duration duration = const Duration(minutes: 5),
  }) async {
    // Return cached if valid
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return Result.success(entry.data as T);
    }
    
    // Fetch and cache
    final result = await fetcher();
    if (result.isSuccess && result.data != null) {
      _cache[key] = _CacheEntry(result.data, DateTime.now().add(duration));
    }
    return result;
  }

  /// Clear specific cache
  void invalidate(String key) => _cache.remove(key);

  /// Clear all cache
  void invalidateAll() => _cache.clear();

  /// Check if cached
  bool isCached(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiry;
  _CacheEntry(this.data, this.expiry);
  bool get isExpired => DateTime.now().isAfter(expiry);
}
