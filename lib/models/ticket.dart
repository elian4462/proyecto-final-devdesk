class Ticket {
  final int id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String prioridad;
  final String estado;
  final String equipoAfectado;
  final String fecha;
  final String? solucion;

  const Ticket({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.prioridad,
    this.estado = 'abierto',
    this.equipoAfectado = 'General',
    required this.fecha,
    this.solucion,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: (json['descripcion'] ?? '') as String,
      categoria: (json['categoria'] ?? 'software') as String,
      prioridad: (json['prioridad'] ?? 'media') as String,
      estado: (json['estado'] ?? 'abierto') as String,
      equipoAfectado: (json['equipo_afectado'] ?? json['equipoAfectado'] ?? 'General') as String,
      fecha: (json['fecha'] ?? DateTime.now().toIso8601String().substring(0, 10)) as String,
      solucion: json['solucion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'prioridad': prioridad,
        'estado': estado,
        'equipo_afectado': equipoAfectado,
        'fecha': fecha,
        if (solucion != null) 'solucion': solucion,
      };

  Ticket copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? categoria,
    String? prioridad,
    String? estado,
    String? equipoAfectado,
    String? fecha,
    String? solucion,
  }) {
    return Ticket(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      equipoAfectado: equipoAfectado ?? this.equipoAfectado,
      fecha: fecha ?? this.fecha,
      solucion: solucion ?? this.solucion,
    );
  }
}
