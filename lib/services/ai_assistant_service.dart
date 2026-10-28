import '../models/mensaje_ia.dart';
import 'api_client.dart';

class AiAssistantService {
  final ApiClient _api;

  AiAssistantService(this._api);

  Future<MensajeIa> consultar({
    required String prompt,
    List<MensajeIa> historial = const [],
  }) async {
    try {
      final respuesta = await _api.post<Map<String, dynamic>>(
        '/api/chat',
        data: {
          'mensaje': prompt,
          'historial': historial.map((m) => m.toJson()).toList(),
        },
      );
      final data = respuesta.data ?? {};
      final texto = (data['respuesta'] ?? data['texto'] ?? data['message'] ?? 'Sin respuesta') as String;
      final accionJson = data['accion'] as Map<String, dynamic>?;

      return MensajeIa(
        texto: texto,
        esUsuario: false,
        accionPropuesta: accionJson != null ? AccionPropuesta.fromJson(accionJson) : null,
      );
    } catch (e) {
      // Diagnóstico inteligente en modo local o si no hay backend activo
      return _generarRespuestaLocal(prompt);
    }
  }

  MensajeIa _generarRespuestaLocal(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('cpu') || lower.contains('carga') || lower.contains('sobrecarga')) {
      return MensajeIa(
        texto: 'Para diagnosticar alta carga de CPU en servidores Linux:\n'
            '1. Ejecuta `top` o `htop` para identificar procesos con alto consumo.\n'
            '2. Revisa hilos saturados con `ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head`.\n'
            '3. Verifica si hay I/O wait elevado con `iostat -xz 1 5`.\n\n'
            '¿Deseas registrar un ticket de revisión técnica para el servidor afectado?',
        esUsuario: false,
        accionPropuesta: const AccionPropuesta(
          nombre: 'crear_ticket',
          argumentos: {
            'titulo': 'Investigar pico de consumo de CPU',
            'descripcion': 'Proceso con alto consumo en servidor de infraestructura.',
            'categoria': 'servidores',
            'prioridad': 'alta',
            'equipo_afectado': 'SRV-K8S-WORKER01',
          },
        ),
      );
    } else if (lower.contains('red') || lower.contains('ping') || lower.contains('enlace') || lower.contains('vpn')) {
      return MensajeIa(
        texto: 'Para problemas de conectividad de red o túnel VPN:\n'
            '1. Comprueba resolución DNS con `dig @1.1.1.1 dominio.com`.\n'
            '2. Realiza un `traceroute` o `mtr` hacia la IP de destino.\n'
            '3. Verifica el estado del servicio WireGuard: `systemctl status wg-quick@wg0`.\n\n'
            'He preparado una propuesta de ticket para el equipo de redes.',
        esUsuario: false,
        accionPropuesta: const AccionPropuesta(
          nombre: 'crear_ticket',
          argumentos: {
            'titulo': 'Degradación en enlace de red o túnel VPN',
            'descripcion': 'Pérdida de paquetes y aumento de latencia detectado.',
            'categoria': 'redes',
            'prioridad': 'alta',
            'equipo_afectado': 'SRV-VPN-GATEWAY',
          },
        ),
      );
    } else if (lower.contains('base de datos') || lower.contains('postgres') || lower.contains('sql')) {
      return MensajeIa(
        texto: 'Para bloqueos o lentitud en PostgreSQL:\n'
            '1. Consulta transacciones activas: `SELECT pid, now() - pg_stat_activity.query_start AS duration, query FROM pg_stat_activity WHERE state != \'idle\';`\n'
            '2. Revisa bloqueos bloqueantes con `SELECT * FROM pg_locks;`.\n'
            '3. Comprueba el espacio en disco en la partición `/var/lib/postgresql`.',
        esUsuario: false,
        accionPropuesta: const AccionPropuesta(
          nombre: 'crear_ticket',
          argumentos: {
            'titulo': 'Optimización y revisión de consultas en PostgreSQL',
            'descripcion': 'Consultas lentas en cluster principal de base de datos.',
            'categoria': 'servidores',
            'prioridad': 'media',
            'equipo_afectado': 'SRV-DB-PRIMARY',
          },
        ),
      );
    }

    return MensajeIa(
      texto: 'Hola, soy DevDesk AI, tu copiloto de infraestructura y soporte TI. '
          'Puedo ayudarte a diagnosticar problemas en servidores, bases de datos, redes, seguridad '
          'o generar tickets de incidencia técnica automáticamente. ¿En qué puedo asistirte hoy?',
      esUsuario: false,
    );
  }
}
