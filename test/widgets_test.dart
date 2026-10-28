import 'dart:io';
import 'package:devdesk/controllers/auth_controller.dart';
import 'package:devdesk/screens/pantalla_con_fallo.dart';
import 'package:devdesk/services/api_client.dart';
import 'package:devdesk/utils/reporte_errores.dart';
import 'package:devdesk/utils/validadores.dart';
import 'package:devdesk/widgets/error_pantalla_view.dart';
import 'package:devdesk/widgets/sin_sesion_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('hive_widgets');
    Hive.init(tempDir.path);
  });

  setUp(() {
    Get.reset();
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Validadores de Formulario', () {
    test('Validador de email detecta formatos válidos e inválidos', () {
      expect(Validadores.email(''), 'El correo electrónico es requerido');
      expect(Validadores.email('correo_invalido'), 'Ingresa un correo electrónico válido');
      expect(Validadores.email('tecnico@empresa.com'), isNull);
    });

    test('Validador de contraseña exige entre 8 y 72 caracteres', () {
      expect(Validadores.password(''), 'La contraseña es requerida');
      expect(Validadores.password('12345'), 'La contraseña debe tener entre 8 y 72 caracteres');
      expect(Validadores.password('clave-segura-1234'), isNull);
    });

    test('Validador de campo requerido', () {
      expect(Validadores.requerido('', 'El título'), 'El título es requerido');
      expect(Validadores.requerido('SRV-DB-PRIMARY', 'El título'), isNull);
    });
  });

  group('ReporteErrores y Vistas de Error', () {
    test('limpiar() enmascara tokens y cabeceras Bearer', () {
      const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c3VhcmlvIn0.firma';
      const texto = 'Error con Authorization: Bearer $jwt y token $jwt';
      final limpio = ReporteErrores.limpiar(texto);
      expect(limpio, isNot(contains('eyJ')));
      expect(limpio, contains('Bearer ***'));
    });

    testWidgets('SinSesionView muestra mensaje explicativo y botón para acceder', (tester) async {
      final api = Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba'))));
      Get.put(AuthController(api: api));

      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: SinSesionView())));
      await tester.pump();

      expect(find.text('Sesión Requerida'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('ReporteErrores.instalar() intercepta pantalla roja y muestra ErrorPantallaView', (tester) async {
      final originalOnError = FlutterError.onError;
      final originalBuilder = ErrorWidget.builder;
      final originalPlatform = PlatformDispatcher.instance.onError;

      addTearDown(() {
        FlutterError.onError = originalOnError;
        ErrorWidget.builder = originalBuilder;
        PlatformDispatcher.instance.onError = originalPlatform;
      });

      ReporteErrores.instalar();

      await tester.pumpWidget(const MaterialApp(home: PantallaConFallo()));
      expect(find.byType(ErrorPantallaView), findsOneWidget);
      expect(find.text('Esta pantalla tuvo un problema'), findsOneWidget);
    });
  });
}
