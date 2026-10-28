import 'package:flutter/material.dart';

class PantallaConFallo extends StatelessWidget {
  const PantallaConFallo({super.key});

  @override
  Widget build(BuildContext context) {
    // Provoca un error intencionado para demostrar el manejo de fallos
    // capturado por ErrorWidget.builder -> ErrorPantallaView
    throw StateError('Fallo provocado intencionalmente para la prueba de calidad');
  }
}
