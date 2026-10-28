import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activos_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/activo.dart';
import 'login_screen.dart';
import 'ticket_form_screen.dart';

class ActivoDetailScreen extends StatelessWidget {
  final Activo activo;

  const ActivoDetailScreen({super.key, required this.activo});

  String _mapearCategoria(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'redes':
        return 'redes';
      case 'servidor':
      case 'base de datos':
        return 'servidores';
      case 'seguridad':
        return 'seguridad';
      default:
        return 'hardware';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activosCtrl = Get.find<ActivosController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(activo.nombre),
        actions: [
          Obx(() {
            final esFav = activosCtrl.esFavorito(activo.id);
            return IconButton(
              icon: Icon(
                esFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: esFav ? Colors.amber.shade700 : null,
              ),
              onPressed: () => activosCtrl.alternarFavorito(activo.id),
              tooltip: esFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            activo.tipo.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0D47A1),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            activo.estado,
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activo.nombre,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activo.descripcion,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Especificaciones de Red y Sistema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ficha Técnica y Ubicación',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    _filaDato(Icons.language, 'Dirección IP:', activo.ip),
                    _filaDato(Icons.computer, 'Sistema Operativo:', activo.sistemaOperativo),
                    _filaDato(Icons.location_on_outlined, 'Ubicación física:', activo.ubicacion),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Telemetría en Vivo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Telemetría de Recursos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _barraRecurso('Uso de CPU', activo.cpuUso),
                    const SizedBox(height: 16),
                    _barraRecurso('Uso de Memoria RAM', activo.memoriaUso),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (!authCtrl.estaAutenticado) {
                  Get.to(() => const LoginScreen());
                } else {
                  Get.to(
                    () => TicketFormScreen(
                      equipoInicial: activo.nombre,
                      categoriaInicial: _mapearCategoria(activo.tipo),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('Reportar Incidencia sobre este Activo', style: TextStyle(fontSize: 15)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaDato(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icono, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(etiqueta, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraRecurso(String etiqueta, double valor) {
    final color = valor > 80
        ? Colors.red
        : valor > 60
            ? Colors.orange
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${valor.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (valor / 100.0).clamp(0.0, 1.0),
          color: color,
          backgroundColor: Colors.grey.shade200,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
