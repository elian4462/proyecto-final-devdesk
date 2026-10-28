import 'dart:async';
import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio dio;
  String? token;
  Future<void> Function()? alSesionCaducada;

  ApiClient({Dio? dio, String? baseUrl})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ??
                    const String.fromEnvironment(
                      'API_URL',
                      defaultValue: 'http://localhost:3000',
                    ),
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 7),
              ),
            ) {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (token != null && token!.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
            onError: (DioException error, handler) async {
              if (error.response?.statusCode == 401) {
                token = null;
                if (alSesionCaducada != null) {
                  await alSesionCaducada!();
                }
              }
              handler.next(error);
            },
          ),
        );
  }

  ApiException procesarError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    String mensaje = 'Ocurrió un error inesperado';
    dynamic detail;

    if (data is Map) {
      detail = data['detail'] ?? data['mensaje'] ?? data['error'];
      if (detail is String && detail.isNotEmpty) {
        mensaje = detail;
      } else if (detail is List && detail.isNotEmpty) {
        mensaje = detail.first['msg']?.toString() ?? 'Error de validación';
      }
    }

    if (mensaje == 'Ocurrió un error inesperado') {
      if (status == 400) {
        mensaje = 'Solicitud inválida. Revisa los datos enviados.';
      } else if (status == 401) {
        mensaje = 'Tu sesión caducó, inicia sesión de nuevo.';
      } else if (status == 404) {
        mensaje = 'El recurso solicitado no fue encontrado.';
      } else if (status == 422) {
        mensaje = 'Los datos proporcionados no cumplen con el formato requerido.';
      } else if (status != null && status >= 500) {
        mensaje = 'Error interno en el servidor ($status). Por favor reintenta más tarde.';
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      mensaje = 'No se pudo conectar con el backend. Verifica que el servidor esté activo.';
    }

    return ApiException(mensaje, statusCode: status, detail: detail);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw procesarError(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.post<T>(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw procesarError(e);
    }
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) async {
    try {
      return await dio.patch<T>(path, data: data);
    } on DioException catch (e) {
      throw procesarError(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await dio.delete<T>(path);
    } on DioException catch (e) {
      throw procesarError(e);
    }
  }
}
