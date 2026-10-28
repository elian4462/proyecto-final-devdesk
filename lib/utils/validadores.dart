class Validadores {
  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(valor.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? password(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (valor.length < 8 || valor.length > 72) {
      return 'La contraseña debe tener entre 8 y 72 caracteres';
    }
    return null;
  }

  static String? requerido(String? valor, String nombreCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return '$nombreCampo es requerido';
    }
    return null;
  }
}
