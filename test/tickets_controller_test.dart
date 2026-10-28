import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:devdesk/controllers/activos_controller.dart' show EstadoCarga;
import 'package:devdesk/controllers/auth_controller.dart';
import 'package:devdesk/controllers/tickets_controller.dart';
import 'package:devdesk/models/usuario.dart';
import 'package:devdesk/repositories/tickets_repository.dart';
import 'package:devdesk/services/api_client.dart';
import 'package:devdesk/services/tickets_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class _ServidorFalso implements HttpClientAdapter {
  final List<Map<String, dynamic>> tickets = [
    {
      'id': 1,
      'titulo': 'Alta latencia en enlace VPN',
      'descripcion': 'Latencia mayor a 250ms hacia Datacenter Quito',
      'categoria': 'redes',
      'prioridad': 'alta',
      'estado': 'abierto',
      'equipo_afectado': 'SRV-VPN-GATEWAY',
      'fecha': '2026-10-27',
    },
    {
      'id': 2,
      'titulo': 'Revisión de logs en PostgreSQL',
      'descripcion': 'Monitoreo de conexiones lentas en cluster principal',
      'categoria': 'servidores',
      'prioridad': 'media',
      'estado': 'en_progreso',
      'equipo_afectado': 'SRV-DB-PRIMARY',
      'fecha': '2026-10-27',
    },
  ];

  int _siguienteId = 3;

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

    if (ruta == '/tickets/' && o.method == 'GET') {
      return _json(tickets, 200);
    }

    if (ruta == '/tickets/' && o.method == 'POST') {
      final data = o.data is Map ? o.data as Map<String, dynamic> : <String, dynamic>{};
      final nuevo = {
        'id': _siguienteId++,
        'fecha': '2026-10-27',
        ...data,
      };
      tickets.insert(0, nuevo);
      return _json(nuevo, 201);
    }

    final match = RegExp(r'^/tickets/(\d+)$').firstMatch(ruta);
    if (match != null) {
      final id = int.parse(match.group(1)!);
      final idx = tickets.indexWhere((t) => t['id'] == id);
      if (idx == -1) return _json({'detail': 'Ticket no encontrado'}, 404);

      if (o.method == 'PATCH') {
        final data = o.data is Map ? o.data as Map<String, dynamic> : <String, dynamic>{};
        tickets[idx] = {...tickets[idx], ...data};
        return _json(tickets[idx], 200);
      }

      if (o.method == 'DELETE') {
        tickets.removeAt(idx);
        return ResponseBody.fromString('', 204);
      }
    }

    return _json({'detail': 'No encontrado'}, 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_tickets_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    Get.reset();
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
    if (Hive.isBoxOpen(TicketsRepository.cajaNombre)) {
      await Hive.box(TicketsRepository.cajaNombre).clear();
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('CRUD completo de Tickets: crear, listar, filtrar, cambiar estado y eliminar', () async {
    final servidor = _ServidorFalso();
    final dio = Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = servidor;
    final api = Get.put(ApiClient(dio: dio));
    final auth = Get.put(AuthController(api: api));
    auth.usuario.value = const Usuario(id: 1, email: 'tecnico@empresa.com');

    final repo = TicketsRepository(TicketsApiService(api));
    final controller = Get.put(TicketsController(auth: auth, repository: repo));

    // 1. Cargar tickets
    await controller.cargarTickets();
    expect(controller.tickets.length, 2);
    expect(controller.estado.value, EstadoCarga.exito);

    // 2. Filtros por estado y categoría
    controller.seleccionarEstado('abierto');
    expect(controller.ticketsFiltrados.length, 1);
    expect(controller.ticketsFiltrados.first.titulo, 'Alta latencia en enlace VPN');

    controller.seleccionarEstado('Todos');
    controller.seleccionarCategoria('servidores');
    expect(controller.ticketsFiltrados.length, 1);
    expect(controller.ticketsFiltrados.first.equipoAfectado, 'SRV-DB-PRIMARY');

    controller.seleccionarCategoria('Todas');

    // 3. Crear nuevo ticket
    final okCrear = await controller.crearTicket(
      titulo: 'Falla en Switch de Piso 3',
      descripcion: 'Puerto 24 sin link',
      categoria: 'redes',
      prioridad: 'alta',
      equipoAfectado: 'SW-CORE-CISCO',
    );
    expect(okCrear, isTrue);
    expect(controller.tickets.length, 3);
    expect(controller.tickets.first.titulo, 'Falla en Switch de Piso 3');

    // 4. Cambiar estado
    final nuevoId = controller.tickets.first.id;
    final okEstado = await controller.cambiarEstado(nuevoId, 'resuelto');
    expect(okEstado, isTrue);
    expect(controller.tickets.first.estado, 'resuelto');

    // 5. Eliminar ticket
    final okEliminar = await controller.eliminarTicket(nuevoId);
    expect(okEliminar, isTrue);
    expect(controller.tickets.length, 2);
  });

  test('Fallback a caché local de Hive cuando el servidor no responde', () async {
    final servidor = _ServidorFalso();
    final dio = Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = servidor;
    final api = Get.put(ApiClient(dio: dio));
    final auth = Get.put(AuthController(api: api));
    auth.usuario.value = const Usuario(id: 1, email: 'tecnico@empresa.com');

    final repo = TicketsRepository(TicketsApiService(api));
    final controller = Get.put(TicketsController(auth: auth, repository: repo));

    // Primera carga exitosa guarda en Hive
    await controller.cargarTickets();
    expect(controller.desdeCache.value, isFalse);

    // Ahora simulamos caída del servidor
    dio.httpClientAdapter = _ServidorCaido();

    await controller.cargarTickets();
    // Debe haber recuperado los datos desde Hive con flag desdeCache en true
    expect(controller.tickets.length, 2);
    expect(controller.desdeCache.value, isTrue);
  });
}

class _ServidorCaido implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    throw DioException(
      requestOptions: o,
      type: DioExceptionType.connectionError,
      error: 'Conexión rechazada',
    );
  }

  @override
  void close({bool force = false}) {}
}
