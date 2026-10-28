import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/auth_api_service.dart';
import '../services/secure_token_storage.dart';

class AuthController extends GetxController {
  final ApiClient _api;
  final SecureTokenStorage _almacen;
  late final AuthApiService _service;

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  final RxBool cargando = false.obs;
  final RxBool restaurando = false.obs;
  final RxString mensajeError = ''.obs;
  final RxString avisoSesion = ''.obs;

  bool get estaAutenticado => usuario.value != null;

  AuthController({
    ApiClient? api,
    SecureTokenStorage? almacen,
  })  : _api = api ?? Get.find<ApiClient>(),
        _almacen = almacen ?? SecureTokenStorage() {
    _service = AuthApiService(_api);
  }

  @override
  void onInit() {
    super.onInit();
    _api.alSesionCaducada = sesionCaducada;
    restaurarSesion();
  }

  Future<void> restaurarSesion() async {
    restaurando.value = true;
    try {
      final tokenGuardado = await _almacen.leer();
      if (tokenGuardado != null && tokenGuardado.isNotEmpty) {
        _api.token = tokenGuardado;
        usuario.value = await _service.obtenerUsuarioActual();
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await cerrarSesion();
        avisoSesion.value = 'Tu sesión caducó, inicia sesión de nuevo.';
      } else {
        debugPrint('[DevDesk] error restaurando sesión: $e');
      }
    } catch (e) {
      debugPrint('[DevDesk] no se pudo restaurar sesión: $e');
    } finally {
      restaurando.value = false;
    }
  }

  Future<bool> iniciarSesion(String email, String password) async {
    cargando.value = true;
    mensajeError.value = '';
    avisoSesion.value = '';
    try {
      final token = await _service.iniciarSesion(email, password);
      _api.token = token;
      await _almacen.guardar(token);
      usuario.value = await _service.obtenerUsuarioActual();
      return true;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      return false;
    } catch (e) {
      mensajeError.value = 'No se pudo iniciar sesión. Verifica tu conexión.';
      return false;
    } finally {
      cargando.value = false;
    }
  }

  Future<bool> registrar(String email, String password, {String nombre = ''}) async {
    cargando.value = true;
    mensajeError.value = '';
    avisoSesion.value = '';
    try {
      await _service.registrar(email, password, nombre: nombre);
      // Auto login tras registro exitoso
      return await iniciarSesion(email, password);
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      return false;
    } catch (e) {
      mensajeError.value = 'Error al registrar usuario: $e';
      return false;
    } finally {
      cargando.value = false;
    }
  }

  Future<void> cerrarSesion() async {
    _api.token = null;
    usuario.value = null;
    await _almacen.borrar();
  }

  Future<void> sesionCaducada() async {
    await cerrarSesion();
    avisoSesion.value = 'Tu sesión caducó, inicia sesión de nuevo.';
  }

  Future<bool> cambiarPassword(String actual, String nueva) async {
    cargando.value = true;
    mensajeError.value = '';
    try {
      await _service.cambiarPassword(actual, nueva);
      return true;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      return false;
    } finally {
      cargando.value = false;
    }
  }
}
