import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;

  const ErrorView({
    super.key,
    required this.mensaje,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar conexión'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
