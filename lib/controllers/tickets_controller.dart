import 'package:get/get.dart';
import '../models/ticket.dart';
import '../repositories/tickets_repository.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/tickets_api_service.dart';
import 'activos_controller.dart' show EstadoCarga;
import 'auth_controller.dart';

class TicketsController extends GetxController {
  final AuthController _auth;
  late final TicketsRepository _repository;

  final RxList<Ticket> tickets = <Ticket>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.exito.obs;
  final RxString mensajeError = ''.obs;
  final RxBool desdeCache = false.obs;

  final RxString filtroEstado = 'Todos'.obs;
  final RxString filtroPrioridad = 'Todas'.obs;
  final RxString filtroCategoria = 'Todas'.obs;

  String get ultimaSincronizacion => _repository.ultimaSincronizacion;

  TicketsController({
    AuthController? auth,
    TicketsRepository? repository,
  }) : _auth = auth ?? Get.find<AuthController>() {
    if (repository != null) {
      _repository = repository;
    } else {
      final api = Get.find<ApiClient>();
      _repository = TicketsRepository(TicketsApiService(api));
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(_auth.usuario, (u) {
      if (u != null) {
        cargarTickets();
      } else {
        tickets.clear();
        _repository.limpiarCache();
      }
    });

    if (_auth.estaAutenticado) {
      cargarTickets();
    }
  }

  List<String> get estadosDisponibles => ['Todos', 'abierto', 'en_progreso', 'resuelto'];
  List<String> get prioridadesDisponibles => ['Todas', 'alta', 'media', 'baja'];
  List<String> get categoriasDisponibles =>
      ['Todas', 'redes', 'servidores', 'hardware', 'software', 'seguridad'];

  List<Ticket> get ticketsFiltrados {
    return tickets.where((t) {
      final cumpleEstado = filtroEstado.value == 'Todos' ||
          t.estado.toLowerCase() == filtroEstado.value.toLowerCase();
      final cumplePrioridad = filtroPrioridad.value == 'Todas' ||
          t.prioridad.toLowerCase() == filtroPrioridad.value.toLowerCase();
      final cumpleCategoria = filtroCategoria.value == 'Todas' ||
          t.categoria.toLowerCase() == filtroCategoria.value.toLowerCase();

      return cumpleEstado && cumplePrioridad && cumpleCategoria;
    }).toList();
  }

  Future<void> cargarTickets() async {
    if (!_auth.estaAutenticado) return;

    estado.value = EstadoCarga.cargando;
    mensajeError.value = '';
    try {
      final resultado = await _repository.obtenerTickets();
      tickets.assignAll(resultado.tickets);
      desdeCache.value = resultado.desdeCache;
      estado.value = EstadoCarga.exito;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoCarga.error;
    } catch (e) {
      mensajeError.value = 'Error al cargar los tickets de soporte: $e';
      estado.value = EstadoCarga.error;
    }
  }

  Future<bool> crearTicket({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
    String equipoAfectado = 'General',
  }) async {
    try {
      final nuevo = await _repository.crearTicket(
        titulo: titulo,
        descripcion: descripcion,
        categoria: categoria,
        prioridad: prioridad,
        equipoAfectado: equipoAfectado,
      );
      tickets.insert(0, nuevo);
      _mostrarNotificacion('Ticket Creado', 'Ticket #${nuevo.id} registrado correctamente.');
      return true;
    } on ApiException catch (e) {
      _mostrarNotificacion('Error', e.mensaje);
      return false;
    } catch (e) {
      _mostrarNotificacion('Error', 'No se pudo crear el ticket: $e');
      return false;
    }
  }

  Future<bool> actualizarTicket(int id, Map<String, dynamic> cambios) async {
    try {
      final actualizado = await _repository.actualizarTicket(id, cambios);
      final idx = tickets.indexWhere((t) => t.id == id);
      if (idx != -1) {
        tickets[idx] = actualizado;
      }
      _mostrarNotificacion('Ticket Actualizado', 'Los cambios en el ticket #$id fueron guardados.');
      return true;
    } on ApiException catch (e) {
      _mostrarNotificacion('Error', e.mensaje);
      return false;
    } catch (e) {
      _mostrarNotificacion('Error', 'No se pudo actualizar el ticket: $e');
      return false;
    }
  }

  Future<bool> cambiarEstado(int id, String nuevoEstado) async {
    return await actualizarTicket(id, {'estado': nuevoEstado});
  }

  Future<bool> eliminarTicket(int id) async {
    try {
      await _repository.eliminarTicket(id);
      tickets.removeWhere((t) => t.id == id);
      _mostrarNotificacion('Ticket Eliminado', 'El ticket #$id fue eliminado correctamente.');
      return true;
    } on ApiException catch (e) {
      _mostrarNotificacion('Error', e.mensaje);
      return false;
    } catch (e) {
      _mostrarNotificacion('Error', 'No se pudo eliminar el ticket: $e');
      return false;
    }
  }

  void _mostrarNotificacion(String titulo, String mensaje) {
    try {
      if (Get.key.currentState != null || Get.overlayContext != null) {
        Get.snackbar(titulo, mensaje, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {}
  }

  void seleccionarEstado(String est) => filtroEstado.value = est;
  void seleccionarPrioridad(String prio) => filtroPrioridad.value = prio;
  void seleccionarCategoria(String cat) => filtroCategoria.value = cat;
}
