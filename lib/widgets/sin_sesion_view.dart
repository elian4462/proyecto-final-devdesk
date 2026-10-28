import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../screens/login_screen.dart';

class SinSesionView extends StatelessWidget {
  final String? mensaje;

  const SinSesionView({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                size: 54,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sesión Requerida',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              final textoAviso = auth.avisoSesion.value.isNotEmpty
                  ? auth.avisoSesion.value
                  : (mensaje ??
                      'Para registrar, gestionar y editar tickets de soporte de infraestructura necesitas autenticarte como técnico.');
              return Text(
                textoAviso,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              );
            }),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Get.to(() => const LoginScreen()),
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
