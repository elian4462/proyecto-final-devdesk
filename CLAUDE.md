# Comandos y Convenciones de Desarrollo — DevDesk

## Comandos Principales

- **Descargar dependencias**: `flutter pub get`
- **Análisis estático**: `flutter analyze`
- **Ejecutar pruebas unitarias y de widgets**: `flutter test`
- **Ejecutar aplicación en emulador / dispositivo**: `flutter run`
- **Compilar APK Release**: `flutter build apk --release`
- **Levantar servidor backend**: `node server/server.js`
- **Pruebas E2E del backend**: `node server/test-e2e.js`

## Stack Tecnológico

- **Framework**: Flutter 3.x / Dart 3.x
- **Gestión de Estado**: GetX (`get`)
- **Cliente HTTP**: Dio con interceptores JWT y traductor de errores
- **Persistencia Local**: Hive & Hive Flutter (Favoritos y Caché offline de tickets)
- **Almacenamiento Seguro**: Flutter Secure Storage (Tokens JWT)
- **Backend**: Node.js REST API con proxy de diagnóstico de IA
