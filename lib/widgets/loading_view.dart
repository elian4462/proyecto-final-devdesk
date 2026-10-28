import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String mensaje;

  const LoadingView({super.key, this.mensaje = 'Cargando información...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
