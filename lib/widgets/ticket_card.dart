import 'package:flutter/material.dart';
import '../models/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
  final ValueChanged<String>? onCambiarEstado;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onEditar,
    this.onEliminar,
    this.onCambiarEstado,
  });

  Color _colorPrioridad(String p) {
    switch (p.toLowerCase()) {
      case 'alta':
        return const Color(0xFFD32F2F);
      case 'media':
        return const Color(0xFFF57C00);
      case 'baja':
        return const Color(0xFF388E3C);
      default:
        return Colors.grey;
    }
  }

  Color _colorEstado(String e) {
    switch (e.toLowerCase()) {
      case 'abierto':
        return const Color(0xFF1976D2);
      case 'en_progreso':
      case 'en progreso':
        return const Color(0xFF7B1FA2);
      case 'resuelto':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorP = _colorPrioridad(ticket.prioridad);
    final colorE = _colorEstado(ticket.estado);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorP.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ticket.prioridad.toUpperCase(),
                              style: TextStyle(color: colorP, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorE.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ticket.estado.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(color: colorE, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '#${ticket.id}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticket.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (valor) {
                    if (valor == 'editar' && onEditar != null) {
                      onEditar!();
                    } else if (valor == 'eliminar' && onEliminar != null) {
                      onEliminar!();
                    } else if (onCambiarEstado != null) {
                      onCambiarEstado!(valor);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar ticket')],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'abierto',
                      child: Row(
                        children: [Icon(Icons.lock_open, size: 18, color: Colors.blue), SizedBox(width: 8), Text('Marcar Abierto')],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'en_progreso',
                      child: Row(
                        children: [Icon(Icons.timelapse, size: 18, color: Colors.purple), SizedBox(width: 8), Text('Marcar En Progreso')],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'resuelto',
                      child: Row(
                        children: [Icon(Icons.check_circle_outline, size: 18, color: Colors.green), SizedBox(width: 8), Text('Marcar Resuelto')],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ticket.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.dns_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  ticket.equipoAfectado,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  ticket.fecha,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
