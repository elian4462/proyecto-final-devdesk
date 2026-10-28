import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activos_controller.dart';
import '../widgets/activo_card.dart';
import '../widgets/empty_view.dart';
import 'activo_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activosCtrl = Get.find<ActivosController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activos Críticos & Favoritos'),
      ),
      body: Obx(() {
        final favoritos = activosCtrl.activosFavoritos;

        if (favoritos.isEmpty) {
          return const EmptyView(
            mensaje: 'No has guardado activos como favoritos.\n'
                'Toca el ícono de estrella en cualquier servidor para monitorearlo rápidamente desde aquí.',
            icono: Icons.star_border_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: favoritos.length,
          itemBuilder: (context, index) {
            final activo = favoritos[index];
            return ActivoCard(
              activo: activo,
              esFavorito: true,
              onAlternarFavorito: () => activosCtrl.alternarFavorito(activo.id),
              onTap: () => Get.to(() => ActivoDetailScreen(activo: activo)),
            );
          },
        );
      }),
    );
  }
}
