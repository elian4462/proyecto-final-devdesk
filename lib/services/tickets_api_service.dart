import '../models/ticket.dart';
import 'api_client.dart';

class TicketsApiService {
  final ApiClient _api;

  TicketsApiService(this._api);

  Future<List<Ticket>> obtenerTickets() async {
    final respuesta = await _api.get<dynamic>('/tickets/');
    final dynamic data = respuesta.data;
    if (data is List) {
      return data.map((json) => Ticket.fromJson(json as Map<String, dynamic>)).toList();
    } else if (data is Map && data['tickets'] is List) {
      return (data['tickets'] as List)
          .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Ticket> crearTicket({
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
    String equipoAfectado = 'General',
  }) async {
    final respuesta = await _api.post<Map<String, dynamic>>(
      '/tickets/',
      data: {
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'prioridad': prioridad,
        'equipo_afectado': equipoAfectado,
        'estado': 'abierto',
      },
    );
    return Ticket.fromJson(respuesta.data ?? {});
  }

  Future<Ticket> actualizarTicket(int id, Map<String, dynamic> cambios) async {
    final respuesta = await _api.patch<Map<String, dynamic>>(
      '/tickets/$id',
      data: cambios,
    );
    return Ticket.fromJson(respuesta.data ?? {});
  }

  Future<void> eliminarTicket(int id) async {
    await _api.delete<void>('/tickets/$id');
  }
}
