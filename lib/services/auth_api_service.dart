import '../models/usuario.dart';
import 'api_client.dart';

class AuthApiService {
  final ApiClient _api;

  AuthApiService(this._api);

  Future<String> iniciarSesion(String email, String password) async {
    final respuesta = await _api.post<Map<String, dynamic>>(
      '/usuarios/token',
      data: {
        'username': email,
        'password': password,
      },
    );
    final data = respuesta.data ?? {};
    final token = (data['access_token'] ?? data['token']) as String?;
    if (token == null || token.isEmpty) {
      throw Exception('La respuesta del servidor no incluyó el token de acceso');
    }
    return token;
  }

  Future<Usuario> registrar(String email, String password, {String nombre = ''}) async {
    final respuesta = await _api.post<Map<String, dynamic>>(
      '/usuarios/',
      data: {
        'email': email,
        'password': password,
        'nombre': nombre,
        'rol': 'tecnico',
      },
    );
    return Usuario.fromJson(respuesta.data ?? {});
  }

  Future<Usuario> obtenerUsuarioActual() async {
    final respuesta = await _api.get<Map<String, dynamic>>('/usuarios/me');
    return Usuario.fromJson(respuesta.data ?? {});
  }

  Future<void> cambiarPassword(String actual, String nueva) async {
    await _api.patch<void>(
      '/usuarios/password',
      data: {
        'password_actual': actual,
        'password_nueva': nueva,
      },
    );
  }
}
