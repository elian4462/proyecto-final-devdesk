class Activo {
  final int id;
  final String nombre;
  final String tipo;
  final String ip;
  final String sistemaOperativo;
  final String estado;
  final String ubicacion;
  final double cpuUso;
  final double memoriaUso;
  final String descripcion;

  const Activo({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.ip,
    required this.sistemaOperativo,
    required this.estado,
    required this.ubicacion,
    required this.cpuUso,
    required this.memoriaUso,
    required this.descripcion,
  });

  factory Activo.fromJson(Map<String, dynamic> json) {
    return Activo(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      ip: json['ip'] as String,
      sistemaOperativo: (json['sistema_operativo'] ?? json['sistemaOperativo'] ?? 'Linux') as String,
      estado: (json['estado'] ?? 'Operativo') as String,
      ubicacion: (json['ubicacion'] ?? 'Datacenter') as String,
      cpuUso: (json['cpu_uso'] ?? json['cpuUso'] as num?)?.toDouble() ?? 0.0,
      memoriaUso: (json['memoria_uso'] ?? json['memoriaUso'] as num?)?.toDouble() ?? 0.0,
      descripcion: (json['descripcion'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'ip': ip,
        'sistema_operativo': sistemaOperativo,
        'estado': estado,
        'ubicacion': ubicacion,
        'cpu_uso': cpuUso,
        'memoria_uso': memoriaUso,
        'descripcion': descripcion,
      };
}
