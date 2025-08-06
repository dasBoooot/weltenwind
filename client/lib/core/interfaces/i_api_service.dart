/// 🌐 API Service Interface
/// 
/// Defines the contract for HTTP API communication
library;


abstract class IApiService {
  /// GET request
  /// Returns response data, throws NetworkException if failed
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });
  
  /// POST request
  /// Returns response data, throws NetworkException if failed
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });
  
  /// PUT request
  /// Returns response data, throws NetworkException if failed
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });
  
  /// DELETE request
  /// Returns response data, throws NetworkException if failed
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  });
  
  /// PATCH request
  /// Returns response data, throws NetworkException if failed
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });
  
  /// Upload file
  /// Returns response data, throws NetworkException if failed
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    Map<String, String>? headers,
    Map<String, String>? fields,
  });
  
  /// Download file
  /// Returns file bytes, throws NetworkException if failed
  Future<List<int>> downloadFile(String endpoint);
  
  /// Set authentication token
  /// Updates authentication headers for subsequent requests
  void setAuthToken(String token);
  
  /// Clear authentication token
  /// Removes authentication headers
  void clearAuthToken();
  
  /// Set API base URL
  /// Updates the base URL for API requests
  void setBaseUrl(String baseUrl);
  
  /// Get current API base URL
  String getBaseUrl();
  
  /// Add request interceptor
  /// Allows modification of requests before sending
  void addRequestInterceptor(RequestInterceptor interceptor);
  
  /// Add response interceptor
  /// Allows modification of responses after receiving
  void addResponseInterceptor(ResponseInterceptor interceptor);
  
  /// Remove request interceptor
  void removeRequestInterceptor(RequestInterceptor interceptor);
  
  /// Remove response interceptor
  void removeResponseInterceptor(ResponseInterceptor interceptor);
  
  /// Get request statistics
  /// Returns performance and usage statistics
  Map<String, dynamic> getRequestStatistics();
  
  /// Clear request statistics
  void clearRequestStatistics();
  
  /// Health check
  /// Checks if API is available and responsive
  Future<bool> healthCheck();
}

/// Request interceptor function type
typedef RequestInterceptor = Future<Map<String, dynamic>?> Function(
  String method,
  String endpoint,
  Map<String, dynamic>? data,
  Map<String, String>? headers,
);

/// Response interceptor function type
typedef ResponseInterceptor = Future<Map<String, dynamic>?> Function(
  String method,
  String endpoint,
  int statusCode,
  Map<String, dynamic>? responseData,
);