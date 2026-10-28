import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/ticket.dart';
import '../services/tickets_api_service.dart';

class TicketsRepository {
  final TicketsApiService _api;
  static const String cajaNombre = 'tickets_cache_box';
  static const String claveTickets = 'tickets_guardados';
  static const String claveTimestamp = 'ultima_sincronizacion';

  String ultimaSincronizacion = '';

  TicketsRepository(this._api);

  Future<Box> _obtenerCaja() async {
    if (Hive.isBoxOpen(cajaNombre)) {
      return Hive.box(cajaNombre);
    }
    return await Hive.openBox(cajaNombre);
  }

  Future<({List<Ticket> tickets, bool desdeCache})> obtenerTickets() async {
    final caja = await _obtenerCaja();
    try {
      final ticketsRemotos = await _api.obtenerTickets();
      // Guardar en Hive
      final jsonList = ticketsRemotos.map((t) => jsonEncode(t.toJson())).toList();
      await caja.put(claveTickets, jsonList);
      final ahora = DateTime.now();
      ultimaSincronizacion =
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
      await caja.put(claveTimestamp, ultimaSincronizacion);

      return (tickets: ticketsRemotos, desdeCache: false);
    } catch (e) {
      // Fallback a caché local de Hive
      final guardados = caja.get(claveTickets) as List?;
      if (guardados != null && guardados.isNotEmpty) {
        final tickets = guardados.map((item) {
          final map = jsonDecode(item as String) as Map<String, dynamic>;
          return Ticket.fromJson(map);
        }).toList();
        ultimaSincronizacion = (caja.get(claveTimestamp) as String?) ?? 'recientemente';
        return (tickets: tickets, desdeCache: true);
      }
      rethrow;
    }
  }

  Future<Ticket> crearTicket({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
    String equipoAfectado = 'General',
  }) async {
    final nuevo = await _api.crearTicket(
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      prioridad: prioridad,
      equipoAfectado: equipoAfectado,
    );
    // Actualizar caché
    await _agregarACache(nuevo);
    return nuevo;
  }

  Future<Ticket> actualizarTicket(int id, Map<String, dynamic> cambios) async {
    final actualizado = await _api.actualizarTicket(id, cambios);
    await _actualizarEnCache(actualizado);
    return actualizado;
  }

  Future<void> eliminarTicket(int id) async {
    await _api.eliminarTicket(id);
    await _eliminarDeCache(id);
  }

  Future<void> _agregarACache(Ticket t) async {
    final caja = await _obtenerCaja();
    final guardados = (caja.get(claveTickets) as List?)?.cast<String>().toList() ?? [];
    guardados.insert(0, jsonEncode(t.toJson()));
    await caja.put(claveTickets, guardados);
  }

  Future<void> _actualizarEnCache(Ticket t) async {
    final caja = await _obtenerCaja();
    final guardados = (caja.get(claveTickets) as List?)?.cast<String>().toList() ?? [];
    final idx = guardados.indexWhere((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return map['id'] == t.id;
    });
    if (idx != -1) {
      guardados[idx] = jsonEncode(t.toJson());
      await caja.put(claveTickets, guardados);
    }
  }

  Future<void> _eliminarDeCache(int id) async {
    final caja = await _obtenerCaja();
    final guardados = (caja.get(claveTickets) as List?)?.cast<String>().toList() ?? [];
    guardados.removeWhere((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return map['id'] == id;
    });
    await caja.put(claveTickets, guardados);
  }

  Future<void> limpiarCache() async {
    final caja = await _obtenerCaja();
    await caja.clear();
  }
}
