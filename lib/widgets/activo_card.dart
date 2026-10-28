import 'package:flutter/material.dart';
import '../models/activo.dart';

class ActivoCard extends StatelessWidget {
  final Activo activo;
  final bool esFavorito;
  final VoidCallback? onAlternarFavorito;
  final VoidCallback? onTap;

  const ActivoCard({
    super.key,
    required this.activo,
    this.esFavorito = false,
    this.onAlternarFavorito,
    this.onTap,
  });

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'operativo':
        return const Color(0xFF2E7D32);
      case 'alerta':
        return const Color(0xFFE65100);
      case 'mantenimiento':
        return const Color(0xFF0277BD);
      default:
        return Colors.grey;
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'servidor':
        return Icons.dns_rounded;
      case 'base de datos':
        return Icons.storage_rounded;
      case 'redes':
        return Icons.hub_rounded;
      case 'seguridad':
        return Icons.security_rounded;
      case 'almacenamiento':
        return Icons.folder_shared_rounded;
      default:
        return Icons.computer_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorEstado(activo.estado);

    return Semantics(
      label: 'Activo de infraestructura ${activo.nombre}, IP ${activo.ip}, estado ${activo.estado}',
      button: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_iconoTipo(activo.tipo), color: const Color(0xFF0D47A1), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activo.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${activo.ip} · ${activo.sistemaOperativo}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        esFavorito ? Icons.star_rounded : Icons.star_border_rounded,
                        color: esFavorito ? Colors.amber.shade700 : Colors.grey,
                      ),
                      tooltip: esFavorito ? 'Quitar de favoritos' : 'Agregar a favoritos',
                      onPressed: onAlternarFavorito,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(radius: 4, backgroundColor: color),
                          const SizedBox(width: 6),
                          Text(
                            activo.estado,
                            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activo.ubicacion,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'CPU: ${activo.cpuUso.toInt()}%  RAM: ${activo.memoriaUso.toInt()}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
