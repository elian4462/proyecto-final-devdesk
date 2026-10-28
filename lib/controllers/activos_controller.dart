import 'package:get/get.dart';
import '../models/activo.dart';
import '../repositories/activos_repository.dart';
import '../services/activos_api_service.dart';
import '../services/api_client.dart';

enum EstadoCarga { cargando, exito, error }

class ActivosController extends GetxController {
  late final ActivosRepository _repository;

  final RxList<Activo> activos = <Activo>[].obs;
  final RxSet<int> favoritosIds = <int>{}.obs;
  final RxString filtroTipo = 'Todos'.obs;
  final RxString busqueda = ''.obs;
  final Rx<EstadoCarga> estado = EstadoCarga.cargando.obs;
  final RxString mensajeError = ''.obs;

  ActivosController({ActivosRepository? repository}) {
    if (repository != null) {
      _repository = repository;
    } else {
      final api = Get.find<ApiClient>();
      _repository = ActivosRepository(ActivosApiService(api));
    }
  }

  @override
  void onInit() {
    super.onInit();
    cargarActivos();
  }

  List<String> get tiposDisponibles => [
        'Todos',
        'Servidor',
        'Base de Datos',
        'Redes',
        'Seguridad',
        'Almacenamiento',
      ];

  List<Activo> get activosFiltrados {
    return activos.where((a) {
      final cumpleTipo =
          filtroTipo.value == 'Todos' || a.tipo.toLowerCase() == filtroTipo.value.toLowerCase();
      if (!cumpleTipo) return false;

      final query = busqueda.value.trim().toLowerCase();
      if (query.isEmpty) return true;

      return a.nombre.toLowerCase().contains(query) ||
          a.ip.toLowerCase().contains(query) ||
          a.sistemaOperativo.toLowerCase().contains(query) ||
          a.ubicacion.toLowerCase().contains(query) ||
          a.descripcion.toLowerCase().contains(query);
    }).toList();
  }

  List<Activo> get activosFavoritos {
    return activos.where((a) => favoritosIds.contains(a.id)).toList();
  }

  bool esFavorito(int id) => favoritosIds.contains(id);

  Future<void> cargarActivos() async {
    estado.value = EstadoCarga.cargando;
    mensajeError.value = '';
    try {
      final lista = await _repository.obtenerActivos();
      final favs = await _repository.obtenerFavoritosIds();
      activos.assignAll(lista);
      favoritosIds.assignAll(favs);
      estado.value = EstadoCarga.exito;
    } catch (e) {
      mensajeError.value = 'No se pudo cargar el inventario de activos TI: $e';
      estado.value = EstadoCarga.error;
    }
  }

  Future<void> alternarFavorito(int id) async {
    final actualizados = await _repository.alternarFavorito(id);
    favoritosIds.assignAll(actualizados);
  }

  void seleccionarTipo(String tipo) {
    filtroTipo.value = tipo;
  }

  void buscar(String query) {
    busqueda.value = query;
  }
}
