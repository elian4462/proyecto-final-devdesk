import 'dart:convert';
import 'dart:typed_data';

import 'package:devdesk/controllers/auth_controller.dart';
import 'package:devdesk/services/api_client.dart';
import 'package:devdesk/services/secure_token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _ServidorAuth implements HttpClientAdapter {
  final Map<String, String> usuarios = {'admin@empresa.com': 'clave-admin-1234'};

  ResponseBody _json(Object? body, int status) => ResponseBody.fromString(
        body == null ? '' : jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        },
      );

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    final ruta = o.path;

    if (ruta == '/usuarios/' && o.method == 'POST') {
      final data = o.data is Map ? o.data as Map<String, dynamic> : <String, dynamic>{};
      final email = data['email'] as String? ?? '';
      final pass = data['password'] as String? ?? '';
      if (usuarios.containsKey(email)) {
        return _json({'detail': 'El usuario ya existe'}, 400);
      }
      usuarios[email] = pass;
      return _json({'id': usuarios.length, 'email': email, 'nombre': data['nombre'] ?? '', 'rol': 'tecnico'}, 201);
    }

    if (ruta == '/usuarios/token') {
      final data = o.data is Map ? o.data as Map<String, dynamic> : <String, dynamic>{};
      final email = data['username'] as String? ?? '';
      final pass = data['password'] as String? ?? '';
      if (usuarios[email] != pass) {
        return _json({'detail': 'Credenciales incorrectas'}, 401);
      }
      return _json({'access_token': 'jwt-token-valido-$email', 'token_type': 'bearer'}, 200);
    }

    if (ruta == '/usuarios/me') {
      final auth = o.headers['Authorization'] as String?;
      if (auth == null || !auth.contains('jwt-token-valido')) {
        return _json({'detail': 'Token inválido o expirado'}, 401);
      }
      return _json({'id': 1, 'email': 'admin@empresa.com', 'nombre': 'Administrador', 'rol': 'tecnico'}, 200);
    }

    return _json({'detail': 'No encontrado'}, 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('Autenticación completa: registro, login, almacenamiento de token y logout', () async {
    final servidor = _ServidorAuth();
    final dio = Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = servidor;
    final api = Get.put(ApiClient(dio: dio));
    final almacen = SecureTokenStorage();
    final auth = Get.put(AuthController(api: api, almacen: almacen));

    // Registro
    final okReg = await auth.registrar('nuevo@empresa.com', 'clave-segura-123', nombre: 'Nuevo Técnico');
    expect(okReg, isTrue);
    expect(auth.estaAutenticado, isTrue);
    expect(await almacen.leer(), isNotNull);

    // Cerrar sesión
    await auth.cerrarSesion();
    expect(auth.estaAutenticado, isFalse);
    expect(await almacen.leer(), isNull);

    // Login con credenciales inválidas
    final okFail = await auth.iniciarSesion('nuevo@empresa.com', 'clave-erronea');
    expect(okFail, isFalse);
    expect(auth.mensajeError.value, contains('Credenciales incorrectas'));

    // Login correcto
    final okLogin = await auth.iniciarSesion('nuevo@empresa.com', 'clave-segura-123');
    expect(okLogin, isTrue);
    expect(auth.estaAutenticado, isTrue);
  });
}
