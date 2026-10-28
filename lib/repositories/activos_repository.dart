import 'package:hive/hive.dart';
import '../models/activo.dart';
import '../services/activos_api_service.dart';

class ActivosRepository {
  final ActivosApiService _api;
  static const String cajaFavoritos = 'activos_favoritos_box';
  static const String claveFavoritos = 'favoritos_ids';

  ActivosRepository(this._api);

  Future<Box> _obtenerCaja() async {
    if (Hive.isBoxOpen(cajaFavoritos)) {
      return Hive.box(cajaFavoritos);
    }
    return await Hive.openBox(cajaFavoritos);
  }

  Future<List<Activo>> obtenerActivos() async {
    return await _api.obtenerActivos();
  }

  Future<Set<int>> obtenerFavoritosIds() async {
    final caja = await _obtenerCaja();
    final List? guardados = caja.get(claveFavoritos) as List?;
    if (guardados != null) {
      return guardados.cast<int>().toSet();
    }
    return {};
  }

  Future<Set<int>> alternarFavorito(int id) async {
    final caja = await _obtenerCaja();
    final Set<int> actuales = await obtenerFavoritosIds();
    if (actuales.contains(id)) {
      actuales.remove(id);
    } else {
      actuales.add(id);
    }
    await caja.put(claveFavoritos, actuales.toList());
    return actuales;
  }
}
