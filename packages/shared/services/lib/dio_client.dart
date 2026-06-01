// region Imports
import 'package:dio/dio.dart';
import 'package:services/log_service.dart';
import 'package:services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:core/utils/app_common_toast_message.dart';// endregion

// region DioClient
class DioClient {
  late final Dio _dio;
  late final StorageService _storageService;

  Dio get dio => _dio;

  Future<DioClient> init({List<String> publicPaths = const []}) async {
    _storageService = Get.find<StorageService>();
    final loggerService = Get.find<LoggerService>();

    final String baseUrl = _storageService.getBaseUrl();
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

    _dio = Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
        connectTimeout: const Duration(milliseconds: 100000),
        receiveTimeout: const Duration(milliseconds: 100000),
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_storageService, publicPaths: publicPaths));
    _dio.interceptors.add(LoggerInterceptor(loggerService: loggerService));

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }


    return this;
  }
}
// endregion

// region AuthInterceptor
class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final List<String> publicPaths;
  static bool _isLoggingOut = false;

  AuthInterceptor(this._storageService, {this.publicPaths = const []});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('AuthInterceptor: onRequest: ${options.path}');
    
    final isPublic = publicPaths.any((path) => options.path.contains(path));
    
    if (isPublic) {
      debugPrint('AuthInterceptor: Path is public, skipping token.');
      return super.onRequest(options, handler);
    }
    final token = _storageService.getToken();
    debugPrint('AuthInterceptor: Attaching token: "$token"');
    if (token != null && token.isNotEmpty) {
      debugPrint('AuthInterceptor: Token found, adding to headers.');
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      debugPrint(
        'AuthInterceptor: Token is null or empty, not adding to headers.',
      );
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401) {
      debugPrint('AuthInterceptor: 401 Unauthorized detected in response. Logging out...');
      _handleLogout(response.data);
      return; // Stop further processing
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      debugPrint('AuthInterceptor: 401 Unauthorized detected in error. Logging out...');
      _handleLogout(err.response?.data);
    }
    return super.onError(err, handler);
  }

  void _handleLogout(dynamic responseData) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    final message = responseData is Map ? responseData['message']?.toString() : null;
    
    AppCommonToastMessage.show(
      message: message ?? 'Session expired, logging out...',
      type: ToastType.warning,
    );
    
    await _storageService.clearAllStorage();
    
    // Using a small delay to ensure the UI can handle the transition
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.offAllNamed('/login');
      // Reset after redirect to allow future logins
      _isLoggingOut = false;
    });
  }
}
// endregion

// region LoggerInterceptor
class LoggerInterceptor extends Interceptor {
  final LoggerService loggerService;

  LoggerInterceptor({required this.loggerService});

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    loggerService.addLog(
      LogMessage(
        request: response.requestOptions,
        response: response,
        timestamp: DateTime.now(),
      ),
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    loggerService.addLog(
      LogMessage(
        request: err.requestOptions,
        error: err,
        timestamp: DateTime.now(),
      ),
    );

    super.onError(err, handler);
  }
}

// endregion










