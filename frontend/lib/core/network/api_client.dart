import 'dart:convert';
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  final TokenStorage tokenStorage;
  late final Dio dio;

  ApiClient(this.tokenStorage) {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _request(() => dio.get<T>(path, queryParameters: queryParameters));
  Future<List<int>> getBytes(String path) => _request(
        () => dio.get<List<int>>(path, options: Options(responseType: ResponseType.bytes)),
      ).then((r) => r.data ?? <int>[]);
  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _request(() => dio.post<T>(path, data: data));
  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _request(() => dio.put<T>(path, data: data));
  Future<Response<T>> delete<T>(String path) =>
      _request(() => dio.delete<T>(path));

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data, e);
      throw ApiException(message, statusCode: e.response?.statusCode);
    }
  }

  static String _extractErrorMessage(dynamic data, DioException e) {
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? data['detail'] ?? 'Request failed.').toString();
    }
    if (data is List<int> && data.isNotEmpty) {
      try {
        final decoded = utf8.decode(data);
        try {
          final json = jsonDecode(decoded);
          if (json is Map) {
            return (json['message'] ?? json['error'] ?? json['detail'] ?? decoded).toString();
          }
        } catch (_) {}
        if (decoded.trim().isNotEmpty) return decoded.trim();
      } catch (_) {}
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final json = jsonDecode(data);
        if (json is Map) {
          return (json['message'] ?? json['error'] ?? json['detail'] ?? data).toString();
        }
      } catch (_) {}
      return data.trim();
    }
    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }
    return 'Unable to reach CareerOS backend.';
  }
}
