class Usuario {
  final int id;
  final String email;
  final String nombre;
  final String rol;

  const Usuario({
    required this.id,
    required this.email,
    this.nombre = '',
    this.rol = 'tecnico',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: (json['nombre'] ?? '') as String,
      rol: (json['rol'] ?? 'tecnico') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombre': nombre,
        'rol': rol,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario && runtimeType == other.runtimeType && id == other.id && email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
