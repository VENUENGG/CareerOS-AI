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
      final data = e.response?.data;
      String message = 'Unable to reach CareerOS backend.';
      if (data is Map) {
        message = (data['message'] ?? data['error'] ?? data['detail'] ?? message).toString();
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
      throw ApiException(message, statusCode: e.response?.statusCode);
    }
  }
}
