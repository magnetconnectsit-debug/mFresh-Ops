// region Imports
import 'package:dio/dio.dart';
import 'package:core/constants/app_constants.dart';
import 'package:services/log_service.dart';
import 'package:services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// endregion

// region DioClient
class DioClient {
  late final Dio _dio;
  late final StorageService _storageService;

  Dio get dio => _dio;

  Future<DioClient> init() async {
    _storageService = Get.find<StorageService>();
    final loggerService = Get.find<LoggerService>();

    final String baseUrl = _storageService.getBaseUrl();
    AppConstants.baseUrl = baseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_storageService));
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

  AuthInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('AuthInterceptor: onRequest: ${options.path}');
    if (options.path.contains(AppConstants.login)) {
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










