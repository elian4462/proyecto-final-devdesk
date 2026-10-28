# Reglas y Convenciones para Agentes de Código — DevDesk

Este archivo define las instrucciones y convenciones para agentes de IA que colaboren en el desarrollo de **DevDesk** (Sistema de Gestión de Tickets TI y Monitoreo de Infraestructura).

## 1. Dominio del Proyecto

DevDesk es una aplicación móvil construida en Flutter para el área de Tecnologías de la Información y Comunicación (TIC). Permite:
- Monitorear el inventario de 20 activos críticos de infraestructura tecnológica (servidores cloud, bases de datos PostgreSQL, switches Cisco, firewalls Fortinet, routers BGP, etc.).
- Gestionar incidencias técnicas mediante un CRUD completo de tickets de soporte técnico.
- Asistir a los técnicos en el diagnóstico de fallas y proponer tickets automáticamente mediante DevDesk AI.
- Persistir activos favoritos y caché offline con Hive para soportar desconexiones de red.

## 2. Arquitectura en Capas

El proyecto sigue una arquitectura estricta en capas desacopladas:

```text
lib/
├── models/        # Entidades del dominio: Usuario, Ticket, Activo, MensajeIa
├── services/      # Comunicación HTTP con Dio, interceptores y SecureTokenStorage
├── repositories/  # Orquestación de datos remotos y persistencia local con Hive
├── controllers/   # Gestión de estado centralizada con GetX (.obs / Obx)
├── screens/       # Interfaz de usuario (sin llamadas HTTP directas)
├── widgets/       # Componentes visuales reutilizables y vistas de estado
├── theme/         # Sistema de diseño con AppTheme (Material 3 claro y oscuro)
└── utils/         # Validadores de formularios y ReporteErrores global
```

**Regla de oro**: Ninguna pantalla (`screens/`) debe invocar llamadas HTTP o interactuar directamente con `Dio` o `Hive`. Toda interacción pasa por su respectivo `GetxController` y repositorio.

## 3. Estado Centralizado con GetX

- Todo el estado compartido vive en clases que extienden `GetxController`.
- La reactividad se maneja con observables (`.obs`) y `Obx(() => ...)`.
- No utilizar `setState` disperso para datos compartidos entre pantallas.
- Inyección de dependencias centralizada mediante `AppBinding`.

## 4. Manejo de Errores y Experiencia de Usuario (UX)

- Toda pantalla con carga asíncrona de datos debe gestionar explícitamente tres estados:
  - `LoadingView`: Indicador visual durante la espera.
  - `ErrorView`: Mensaje claro con botón de reintento.
  - `EmptyView`: Vista ilustrada cuando no hay registros para el filtro o búsqueda actual.
- Las pantallas protegidas muestran `SinSesionView` cuando el usuario no está autenticado, proporcionando un acceso directo a `LoginScreen`.
- `ReporteErrores.instalar()` en `main.dart` reemplaza la pantalla roja de error por `ErrorPantallaView` y sanitiza los tokens JWT en los registros.

## 5. Seguridad y Secretos

- NUNCA incluir claves reales de API de IA, contraseñas o tokens en el código fuente.
- El cliente móvil se comunica con un backend propio (`server/server.js`); la app nunca interactúa directamente con APIs de proveedores de IA con credenciales privadas.
- El archivo `.env` está expresamente excluido en `.gitignore`.
- Se mantiene `.env.example` como plantilla de configuración.
- El token JWT de sesión se guarda en almacenamiento seguro del sistema operativo (`FlutterSecureStorage`).

## 6. Verificación de Calidad

Antes de confirmar cualquier cambio, ejecutar:
```bash
flutter analyze --no-fatal-infos
flutter test
```
Ambos comandos deben terminar con código de salida 0 (sin advertencias ni errores).
