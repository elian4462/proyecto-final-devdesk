class AccionPropuesta {
  final String nombre;
  final Map<String, dynamic> argumentos;

  const AccionPropuesta({
    required this.nombre,
    required this.argumentos,
  });

  factory AccionPropuesta.fromJson(Map<String, dynamic> json) {
    return AccionPropuesta(
      nombre: json['nombre'] as String? ?? json['name'] as String? ?? 'crear_ticket',
      argumentos: (json['argumentos'] ?? json['args'] ?? <String, dynamic>{}) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'argumentos': argumentos,
      };
}

class MensajeIa {
  final String texto;
  final bool esUsuario;
  final AccionPropuesta? accionPropuesta;
  final DateTime fecha;

  MensajeIa({
    required this.texto,
    required this.esUsuario,
    this.accionPropuesta,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  factory MensajeIa.fromJson(Map<String, dynamic> json) {
    return MensajeIa(
      texto: json['texto'] as String? ?? json['content'] as String? ?? '',
      esUsuario: json['es_usuario'] as bool? ?? false,
      accionPropuesta: json['accion'] != null
          ? AccionPropuesta.fromJson(json['accion'] as Map<String, dynamic>)
          : null,
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'texto': texto,
        'es_usuario': esUsuario,
        if (accionPropuesta != null) 'accion': accionPropuesta!.toJson(),
        'fecha': fecha.toIso8601String(),
      };
}
