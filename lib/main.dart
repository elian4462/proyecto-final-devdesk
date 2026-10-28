import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bindings/app_binding.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';
import 'utils/reporte_errores.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para persistencia local de activos y caché
  await Hive.initFlutter();

  // Instalar manejadores globales de errores (elimina pantalla roja)
  ReporteErrores.instalar();

  runApp(const DevDeskApp());
}

class DevDeskApp extends StatelessWidget {
  const DevDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DevDesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: AppBinding(),
      home: const RootShell(),
    );
  }
}
