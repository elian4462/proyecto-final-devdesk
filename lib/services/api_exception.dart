class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;
  final dynamic detail;

  const ApiException(this.mensaje, {this.statusCode, this.detail});

  @override
  String toString() => mensaje;
}
