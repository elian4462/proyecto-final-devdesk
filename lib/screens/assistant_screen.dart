import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assistant_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/mensaje_ia.dart';
import 'login_screen.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _enviar(AssistantController ctrl) {
    final texto = _inputCtrl.text.trim();
    if (texto.isEmpty) return;
    _inputCtrl.clear();
    ctrl.enviarMensaje(texto);
    _desplazarAlFinal();
  }

  void _desplazarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _confirmarAccion(BuildContext context, AssistantController ctrl, AccionPropuesta accion) {
    final auth = Get.find<AuthController>();
    if (!auth.estaAutenticado) {
      Get.to(() => const LoginScreen());
      return;
    }

    final args = accion.argumentos;
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: Color(0xFF0D47A1)),
            SizedBox(width: 8),
            Text('Confirmar Acción'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DevDesk AI propone registrar el siguiente ticket en el sistema:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Título: ${args['titulo'] ?? 'Sin título'}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Activo: ${args['equipo_afectado'] ?? 'General'}'),
                  Text('Categoría: ${args['categoria'] ?? 'servidores'}'),
                  Text('Prioridad: ${args['prioridad'] ?? 'media'}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Descartar'),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();
              final ok = await ctrl.ejecutarAccion(accion);
              if (ok) {
                Get.snackbar(
                  'Acción Ejecutada',
                  'El ticket fue creado exitosamente por el asistente.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Confirmar y Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AssistantController>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: Color(0xFF00ACC1)),
            SizedBox(width: 8),
            Text('DevDesk AI Copilot'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Preguntas sugeridas en carrusel horizontal
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: ctrl.preguntasSugeridas.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      avatar: const Icon(Icons.bolt, size: 16, color: Color(0xFF0D47A1)),
                      label: Text(p, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        _inputCtrl.text = p;
                        _enviar(ctrl);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Lista de mensajes
          Expanded(
            child: Obx(() {
              _desplazarAlFinal();
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.mensajes.length,
                itemBuilder: (context, index) {
                  final m = ctrl.mensajes[index];
                  return _burbujaMensaje(context, m, ctrl);
                },
              );
            }),
          ),
          // Indicador de escribiendo
          Obx(() {
            if (!ctrl.cargando.value) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'DevDesk AI está analizando...',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          }),
          // Input de texto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Pregunta sobre fallas, comandos, redes...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _enviar(ctrl),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _enviar(ctrl),
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _burbujaMensaje(BuildContext context, MensajeIa mensaje, AssistantController ctrl) {
    final esUsuario = mensaje.esUsuario;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: esUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!esUsuario) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF00ACC1).withValues(alpha: 0.15),
                  child: const Icon(Icons.smart_toy, size: 16, color: Color(0xFF00838F)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: esUsuario ? const Color(0xFF0D47A1) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(esUsuario ? 14 : 2),
                      bottomRight: Radius.circular(esUsuario ? 2 : 14),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    mensaje.texto,
                    style: TextStyle(
                      color: esUsuario ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (mensaje.accionPropuesta != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 6),
              child: Card(
                elevation: 0,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: Color(0xFF0D47A1), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Propuesta de Incidencia: ${mensaje.accionPropuesta!.argumentos['titulo'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FilledButton.tonalIcon(
                        onPressed: () => _confirmarAccion(context, ctrl, mensaje.accionPropuesta!),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Revisar y Confirmar Ticket', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
