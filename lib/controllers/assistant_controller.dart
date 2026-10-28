import 'package:get/get.dart';
import '../models/mensaje_ia.dart';
import '../services/ai_assistant_service.dart';
import '../services/api_client.dart';
import 'tickets_controller.dart';

class AssistantController extends GetxController {
  late final AiAssistantService _service;
  final RxList<MensajeIa> mensajes = <MensajeIa>[].obs;
  final RxBool cargando = false.obs;

  final List<String> preguntasSugeridas = [
    '¿Cómo diagnosticar alta carga de CPU en Linux?',
    'Falla en enlace de red o túnel VPN',
    'Optimización de consultas en PostgreSQL',
    'Comprobar certificados SSL expirados',
  ];

  AssistantController({AiAssistantService? service}) {
    if (service != null) {
      _service = service;
    } else {
      final api = Get.find<ApiClient>();
      _service = AiAssistantService(api);
    }
  }

  @override
  void onInit() {
    super.onInit();
    mensajes.add(
      MensajeIa(
        texto: 'Hola, soy DevDesk AI, tu asistente técnico para infraestructura y soporte TI. '
            'Puedo analizar incidencias, sugerir comandos de diagnóstico y proponer la creación de tickets automáticos. '
            '¿En qué puedo ayudarte?',
        esUsuario: false,
      ),
    );
  }

  Future<void> enviarMensaje(String texto) async {
    final limpio = texto.trim();
    if (limpio.isEmpty || cargando.value) return;

    mensajes.add(MensajeIa(texto: limpio, esUsuario: true));
    cargando.value = true;

    try {
      final respuesta = await _service.consultar(
        prompt: limpio,
        historial: mensajes.toList(),
      );
      mensajes.add(respuesta);
    } catch (e) {
      mensajes.add(
        MensajeIa(
          texto: 'Lo siento, no pude procesar la consulta en este momento ($e).',
          esUsuario: false,
        ),
      );
    } finally {
      cargando.value = false;
    }
  }

  Future<bool> ejecutarAccion(AccionPropuesta accion) async {
    if (accion.nombre == 'crear_ticket') {
      final args = accion.argumentos;
      final ticketsCtrl = Get.find<TicketsController>();
      return await ticketsCtrl.crearTicket(
        titulo: args['titulo']?.toString() ?? 'Incidencia técnica reportada por IA',
        descripcion: args['descripcion']?.toString() ?? 'Generado por asistente virtual',
        categoria: args['categoria']?.toString() ?? 'servidores',
        prioridad: args['prioridad']?.toString() ?? 'media',
        equipoAfectado: args['equipo_afectado']?.toString() ?? 'General',
      );
    }
    return false;
  }
}
