import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activos_controller.dart' show EstadoCarga;
import '../controllers/auth_controller.dart';
import '../controllers/tickets_controller.dart';
import '../models/ticket.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/sin_sesion_view.dart';
import '../widgets/ticket_card.dart';
import 'cambiar_password_screen.dart';
import 'pantalla_con_fallo.dart';
import 'ticket_form_screen.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final ticketsCtrl = Get.find<TicketsController>();

    return Obx(() {
      if (!auth.estaAutenticado) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mesa de Ayuda & Tickets'),
          ),
          body: const SinSesionView(),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text('Tickets (${ticketsCtrl.tickets.length})')),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar tickets',
              onPressed: ticketsCtrl.cargarTickets,
            ),
            PopupMenuButton<String>(
              onSelected: (valor) {
                if (valor == 'salir') {
                  auth.cerrarSesion();
                } else if (valor == 'password') {
                  Get.to(() => const CambiarPasswordScreen());
                } else if (valor == 'acerca') {
                  showLicensePage(
                    context: context,
                    applicationName: 'DevDesk',
                    applicationVersion: '1.0.0',
                  );
                } else if (valor == 'error_demo') {
                  Get.to(() => const PantallaConFallo());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'password',
                  child: Row(
                    children: [Icon(Icons.password, size: 18), SizedBox(width: 8), Text('Cambiar contraseña')],
                  ),
                ),
                const PopupMenuItem(
                  value: 'acerca',
                  child: Row(
                    children: [Icon(Icons.info_outline, size: 18), SizedBox(width: 8), Text('Acerca de DevDesk')],
                  ),
                ),
                if (kDebugMode)
                  const PopupMenuItem(
                    value: 'error_demo',
                    child: Row(
                      children: [Icon(Icons.bug_report, size: 18, color: Colors.orange), SizedBox(width: 8), Text('Demostrar pantalla de error')],
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'salir',
                  child: Row(
                    children: [Icon(Icons.logout, size: 18, color: Colors.red), SizedBox(width: 8), Text('Cerrar sesión', style: TextStyle(color: Colors.red))],
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const TicketFormScreen()),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Ticket'),
        ),
        body: Obx(() {
          if (ticketsCtrl.estado.value == EstadoCarga.cargando) {
            return const LoadingView(mensaje: 'Consultando tickets de soporte...');
          }

          if (ticketsCtrl.estado.value == EstadoCarga.error) {
            return ErrorView(
              mensaje: ticketsCtrl.mensajeError.value,
              onReintentar: ticketsCtrl.cargarTickets,
            );
          }

          return Column(
            children: [
              // Banner offline de Hive
              if (ticketsCtrl.desdeCache.value)
                MaterialBanner(
                  leading: const Icon(Icons.cloud_off, color: Colors.orange),
                  backgroundColor: Colors.amber.shade50,
                  content: Text(
                    'Sin conexión — mostrando tickets guardados en caché local (sincronizado: ${ticketsCtrl.ultimaSincronizacion})',
                    style: const TextStyle(fontSize: 12),
                  ),
                  actions: [
                    TextButton(
                      onPressed: ticketsCtrl.cargarTickets,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),

              // Filtros horizontales por Estado
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: ticketsCtrl.estadosDisponibles.map((estado) {
                    final sel = ticketsCtrl.filtroEstado.value == estado;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(estado.replaceAll('_', ' ').capitalizeFirst ?? estado),
                        selected: sel,
                        onSelected: (_) => ticketsCtrl.seleccionarEstado(estado),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Filtros horizontales por Categoría
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  children: ticketsCtrl.categoriasDisponibles.map((cat) {
                    final sel = ticketsCtrl.filtroCategoria.value == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(cat.capitalizeFirst ?? cat),
                        selected: sel,
                        onSelected: (_) => ticketsCtrl.seleccionarCategoria(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),

              // Lista de tickets
              Expanded(
                child: Builder(
                  builder: (context) {
                    final lista = ticketsCtrl.ticketsFiltrados;
                    if (lista.isEmpty) {
                      return const EmptyView(
                        mensaje: 'No hay tickets que coincidan con los filtros seleccionados.',
                        icono: Icons.task_alt_rounded,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: ticketsCtrl.cargarTickets,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final item = lista[index];
                          return TicketCard(
                            ticket: item,
                            onEditar: () => Get.to(() => TicketFormScreen(ticket: item)),
                            onCambiarEstado: (nuevoEstado) => ticketsCtrl.cambiarEstado(item.id, nuevoEstado),
                            onEliminar: () => _confirmarEliminar(context, item, ticketsCtrl),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      );
    });
  }

  void _confirmarEliminar(BuildContext context, Ticket ticket, TicketsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar Ticket'),
        content: Text('¿Estás seguro de que deseas eliminar permanentemente el ticket #${ticket.id} (${ticket.titulo})?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.eliminarTicket(ticket.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
