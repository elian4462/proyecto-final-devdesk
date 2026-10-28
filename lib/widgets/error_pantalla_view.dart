import 'package:flutter/material.dart';

class ErrorPantallaView extends StatelessWidget {
  final FlutterErrorDetails? detalles;

  const ErrorPantallaView({super.key, this.detalles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bug_report_outlined,
                size: 64,
                color: Color(0xFFD32F2F),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta pantalla tuvo un problema',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ocurrió un error inesperado al renderizar la interfaz. Ya lo registramos internamente para corregirlo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver a la pantalla anterior'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
