import 'dart:io';
import 'package:devdesk/controllers/activos_controller.dart';
import 'package:devdesk/repositories/activos_repository.dart';
import 'package:devdesk/services/activos_api_service.dart';
import 'package:devdesk/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_activos_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    Get.reset();
    Get.testMode = true;
    if (Hive.isBoxOpen(ActivosRepository.cajaFavoritos)) {
      await Hive.box(ActivosRepository.cajaFavoritos).clear();
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('ActivosController carga los 20 activos TI reales de infraestructura', () async {
    final api = ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba')));
    final repo = ActivosRepository(ActivosApiService(api));
    final controller = Get.put(ActivosController(repository: repo));

    await controller.cargarActivos();

    expect(controller.activos.length, 20);
    expect(controller.estado.value, EstadoCarga.exito);
    expect(controller.activos.any((a) => a.nombre == 'SRV-DB-PRIMARY'), isTrue);
    expect(controller.activos.any((a) => a.nombre == 'FW-CORE-FORTINET'), isTrue);
  });

  test('ActivosController filtra en tiempo real por búsqueda y tipo', () async {
    final api = ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba')));
    final repo = ActivosRepository(ActivosApiService(api));
    final controller = Get.put(ActivosController(repository: repo));
    await controller.cargarActivos();

    // Filtro por tipo Base de Datos
    controller.seleccionarTipo('Base de Datos');
    expect(controller.activosFiltrados.length, 3); // PRIMARY, REPLICA, REDIS
    expect(controller.activosFiltrados.every((a) => a.tipo == 'Base de Datos'), isTrue);

    // Búsqueda por texto
    controller.seleccionarTipo('Todos');
    controller.buscar('192.168.10.20');
    expect(controller.activosFiltrados.length, 1);
    expect(controller.activosFiltrados.first.nombre, 'SRV-DB-PRIMARY');
  });

  test('ActivosController persiste favoritos con Hive entre llamadas', () async {
    final api = ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba')));
    final repo = ActivosRepository(ActivosApiService(api));
    final controller = Get.put(ActivosController(repository: repo));
    await controller.cargarActivos();

    expect(controller.activosFavoritos, isEmpty);

    // Marcar como favorito el activo #1 (SRV-WEB-01) y #2 (SRV-DB-PRIMARY)
    await controller.alternarFavorito(1);
    await controller.alternarFavorito(2);

    expect(controller.esFavorito(1), isTrue);
    expect(controller.esFavorito(2), isTrue);
    expect(controller.activosFavoritos.length, 2);

    // Desmarcar #1
    await controller.alternarFavorito(1);
    expect(controller.esFavorito(1), isFalse);
    expect(controller.activosFavoritos.length, 1);
    expect(controller.activosFavoritos.first.id, 2);
  });
}
