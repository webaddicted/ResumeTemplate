import 'package:dio/dio.dart';
import 'package:template/global/apiutils/api_base_helper.dart';
import 'package:template/global/base/base_repository.dart';
import 'package:template/global/constant/string_const.dart';

/// Enum for API/UI state
enum ApiStatus { noInternet, warning, loading, success, error }

/// API Response wrapper for UI state management
class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String? message;

  const ApiResponse._({required this.status, this.data, this.message});

  /// Loading state
  factory ApiResponse.loading() => 
      const ApiResponse._(status: ApiStatus.loading);

  /// Success state
  factory ApiResponse.success(T data) => 
      ApiResponse._(status: ApiStatus.success, data: data);

  /// Error state
  factory ApiResponse.error([String? message]) => 
      ApiResponse._(status: ApiStatus.error, message: message);

  /// No internet state
  factory ApiResponse.noInternet() => 
      const ApiResponse._(status: ApiStatus.noInternet);

  /// Create from Dio Response
  factory ApiResponse.fromResponse(Response? response, T? data) {
    if (response?.statusCode == ApiResponseCode.success200) {
      return ApiResponse.success(data as T);
    }
    if (response?.statusCode == ApiResponseCode.internetUnavailable) {
      return ApiResponse.noInternet();
    }
    return ApiResponse.error(
      response?.statusMessage ?? StringConst.somethingWentWrong,
    );
  }

  /// Create from Result (for converting repository result to UI state)
  factory ApiResponse.fromResult(Result<T> result) {
    return result.fold(
      onSuccess: (data) => ApiResponse.success(data),
      onFailure: (error) => error.toLowerCase().contains('internet')
          ? ApiResponse.noInternet()
          : ApiResponse.error(error),
    );
  }

  /// Check states
  bool get isLoading => status == ApiStatus.loading;
  bool get isSuccess => status == ApiStatus.success;
  bool get isError => status == ApiStatus.error;
  bool get hasData => data != null;

  @override
  String toString() => 'ApiResponse(status: $status, data: $data, message: $message)';
}

/// Extension to convert Result to ApiResponse
extension ResultToApiResponse<T> on Result<T> {
  ApiResponse<T> toApiResponse() => ApiResponse.fromResult(this);
}
