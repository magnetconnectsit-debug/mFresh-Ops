// region Imports
import 'package:dio/dio.dart';
import 'package:core/logger/app_logger.dart';
import 'package:services/dio_client.dart';
import 'package:get/get.dart' hide Response, FormData;
// endregion

// region ApiService
class ApiService extends GetxService {
  // region Properties
  late final Dio _dio;
  // endregion

  // region Initialization
  @override
  void onInit() {
    super.onInit();
    _dio = Get.find<DioClient>().dio;
  }
  // endregion

  // region HTTP_Methods
  Future<dynamic> get(String path, {Map<String, dynamic>? query, Options? options}) async {
    // region get
    try {
      final response = await _dio.get(
        _normalizePath(path),
        queryParameters: query,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
    // endregion
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    // region post
    try {
      final response = await _dio.post(
        _normalizePath(path),
        data: data,
        queryParameters: query,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
    // endregion
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    // region put
    try {
      final response = await _dio.put(
        _normalizePath(path),
        data: data,
        queryParameters: query,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
    // endregion
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    // region delete
    try {
      final response = await _dio.delete(
        _normalizePath(path),
        data: data,
        queryParameters: query,
        options: options,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
    // endregion
  }
  // endregion

  // region Helpers
  String _normalizePath(String path) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }

  // region Helpers
  Exception _handleError(dynamic e) {
    // region _handleError
    if (e is DioException) {
      AppLogger.error('ApiService DioError', e.message, e.stackTrace);

      return e;
    }

    AppLogger.error('ApiService Generic Error', e, e.stackTrace);
    return Exception('An unexpected error occurred: $e');
    // endregion
  }

  // endregion
}

// endregion
