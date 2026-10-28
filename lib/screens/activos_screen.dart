import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activos_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/activo_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'activo_detail_screen.dart';
import 'login_screen.dart';

class ActivosScreen extends StatelessWidget {
  const ActivosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activosCtrl = Get.find<ActivosController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infraestructura & Activos TI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar inventario',
            onPressed: activosCtrl.cargarActivos,
          ),
          Obx(() {
            if (authCtrl.estaAutenticado) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF0D47A1),
                  child: Text(
                    authCtrl.usuario.value?.email.substring(0, 1).toUpperCase() ?? 'T',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              );
            }
            return TextButton.icon(
              onPressed: () => Get.to(() => const LoginScreen()),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Acceso'),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              onChanged: activosCtrl.buscar,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, IP, SO o ubicación...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                suffixIcon: Obx(() => activosCtrl.busqueda.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => activosCtrl.buscar(''),
                      )
                    : const SizedBox.shrink()),
              ),
            ),
          ),
          // Chips de categorías
          Obx(() {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: activosCtrl.tiposDisponibles.map((tipo) {
                  final seleccionado = activosCtrl.filtroTipo.value == tipo;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(tipo),
                      selected: seleccionado,
                      onSelected: (_) => activosCtrl.seleccionarTipo(tipo),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 4),
          // Contenido principal reactivo
          Expanded(
            child: Obx(() {
              if (activosCtrl.estado.value == EstadoCarga.cargando) {
                return const LoadingView(mensaje: 'Consultando inventario de infraestructura...');
              }

              if (activosCtrl.estado.value == EstadoCarga.error) {
                return ErrorView(
                  mensaje: activosCtrl.mensajeError.value,
                  onReintentar: activosCtrl.cargarActivos,
                );
              }

              final lista = activosCtrl.activosFiltrados;
              if (lista.isEmpty) {
                return const EmptyView(
                  mensaje: 'No se encontraron activos TI que coincidan con la búsqueda o filtro seleccionado.',
                  icono: Icons.devices_other_rounded,
                );
              }

              return RefreshIndicator(
                onRefresh: activosCtrl.cargarActivos,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 4, bottom: 20),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    return Obx(() {
                      final esFav = activosCtrl.esFavorito(item.id);
                      return ActivoCard(
                        activo: item,
                        esFavorito: esFav,
                        onAlternarFavorito: () => activosCtrl.alternarFavorito(item.id),
                        onTap: () => Get.to(() => ActivoDetailScreen(activo: item)),
                      );
                    });
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
