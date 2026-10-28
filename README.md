# DevDesk — Sistema de Soporte TI y Monitoreo de Infraestructura

> Proyecto Final.

**DevDesk** es una solución móvil integral orientada al área de Tecnologías de la Información y Comunicación (TIC). Permite a los equipos de infraestructura y soporte técnico supervisar en tiempo real un catálogo de activos tecnológicos (servidores cloud, clusters de bases de datos, switches core, firewalls y gateways VPN), gestionar incidencias técnicas mediante un CRUD completo de tickets de soporte y diagnosticar fallas con la asistencia de un copiloto de inteligencia artificial (DevDesk AI) mediante un backend intermedio seguro.

---

## Qué incluye

- [x] **Autenticación con JWT**: Registro e inicio de sesión de técnicos con contraseñas cifradas y almacenamiento seguro del token mediante `flutter_secure_storage`.
- [x] **Lista principal de datos reales**: Catálogo de 20 activos de infraestructura tecnológica con estados visuales explícitos de carga (`LoadingView`), vacío (`EmptyView`) y error con reintento (`ErrorView`).
- [x] **Persistencia local con Hive**: Marcadores de activos críticos/favoritos y respaldo offline de tickets con banner informativo de sincronización que sobrevive al cierre completo de la app.
- [x] **Persistencia remota protegida (CRUD)**: Creación, listado, actualización parcial (`PATCH`) y eliminación de tickets de soporte técnico protegidos por autorización Bearer.
- [x] **Asistente de IA sin claves en la app**: Chat técnico y diagnóstico de infraestructura (DevDesk AI) conectado a través de un backend propio (`/api/chat`) con confirmación humana (*Human-in-the-Loop*) para la creación automática de tickets.
- [x] **Estado centralizado con GetX**: Controladores reactivos desacoplados (`AuthController`, `ActivosController`, `TicketsController`, `AssistantController`) sin `setState` disperso para datos compartidos.
- [x] **Calidad y Reporte de Errores**: Interceptores de red Dio para códigos 400, 401 (cierre de sesión automático), 404, 422 y 500. `ReporteErrores.instalar()` que sustituye la pantalla roja por una interfaz amistosa y sanitiza tokens.
- [x] **Integración y Entrega Continua (CI/CD)**: Workflows de GitHub Actions para verificación de código (`ci.yml`) y generación automatizada de APK de release (`release-apk.yml`).

---

## Cómo ejecutar el proyecto

### Requisitos previos
- **Flutter SDK**: versión 3.5.0 o superior
- **Node.js**: versión 18 o superior para el servidor backend.

---

### 1. Levantar el Backend

El backend de DevDesk es completamente autónomo y no requiere dependencias externas.

```bash
# 1. Entrar a la carpeta del servidor
cd server

# 2. Iniciar el servidor HTTP REST
node server.js
```

El servidor iniciará escuchando en `http://localhost:3000`.

```bash
node server/test-e2e.js
```

---

### 2. Ejecutar la Aplicación Móvil en Flutter

Desde la raíz del proyecto (`PROYECTO FINAL`):

```bash
# 1. Descargar las dependencias
flutter pub get

# 2. Ejecutar las pruebas unitarias y de widgets
flutter test

# 3. Lanzar la aplicación
flutter run
```

---

### 3. Direcciones y Configuración por Entorno

La URL del backend se puede configurar al compilar o ejecutar mediante `--dart-define=API_URL=...`:

- **Emulador Android**:
  ```bash
  flutter run --dart-define=API_URL=http://10.0.2.2:3000
  ```
- **Dispositivo físico (misma red WiFi)**:
  ```bash
  flutter run --dart-define=API_URL=http://192.168.1.X:3000
  ```
- **Windows / macOS / Linux / Web**:
  ```bash
  flutter run --dart-define=API_URL=http://localhost:3000
  ```

---

### Usuarios de Prueba Precargados

Para acceder de inmediato al sistema y probar las funcionalidades protegidas:

| Rol | Correo | Contraseña |
| :--- | :--- | :--- |
| **Administrador TI** | `admin@empresa.com` | `admin-1234` |
| **Técnico de Soporte** | `tecnico@empresa.com` | `tecnico-1234` |

*También se puede registrar un nuevo usuario desde la pantalla de Registro de la aplicación.*

---

## APK de Release

El APK instalable se compila y publica de manera automática en la sección **Releases** de este repositorio al publicar una etiqueta de versión (ejemplo: `v1.0.0`) a través del flujo de GitHub Actions ubicado en `.github/workflows/release-apk.yml`.

Para compilarlo localmente en tu equipo:
```bash
flutter build apk --release --dart-define=API_URL=http://10.0.2.2:3000
```
El archivo generado se ubicará en: `build/app/outputs/flutter-apk/app-release.apk`.

---

## Arquitectura

El proyecto implementa una arquitectura en capas limpias y desacopladas:

```text
lib/
├── models/        # Entidades: Usuario, Ticket, Activo, MensajeIa
├── services/      # ApiClient (Dio), SecureTokenStorage, servicios REST
├── repositories/  # TicketsRepository (Hive cache), ActivosRepository
├── controllers/   # GetxController (Auth, Activos, Tickets, Assistant)
├── screens/       # Vistas de interfaz de usuario
├── widgets/       # Vistas de estado (Loading, Error, Empty, SinSesion) y tarjetas
├── theme/         # AppTheme con Material 3 claro y oscuro
└── utils/         # Validadores y ReporteErrores global
```

### Cómo viaja un dato en DevDesk
Cuando el usuario crea o consulta un ticket de soporte:
1. La vista `TicketsScreen` interactúa exclusivamente con `TicketsController`.
2. El controlador delega la petición a `TicketsRepository`.
3. El repositorio utiliza `ApiClient` (Dio) inyectando el token JWT en el encabezado `Authorization: Bearer <token>`.
4. Si la red responde favorablemente, los datos se almacenan en la caja de caché local de Hive (`tickets_cache_box`) y se actualiza la interfaz reactivamente con `Obx`.
5. Si el servidor se apaga o la conexión falla, el repositorio recupera inmediatamente los datos guardados en Hive y el controlador activa el `MaterialBanner` offline para informar al técnico.

## Tecnologías y Paquetes Principales

| Paquete | Versión | Propósito en el Proyecto |
| :--- | :--- | :--- |
| **get** | `^4.6.6` | Gestión de estado reactiva, inyección de dependencias y navegación |
| **dio** | `^5.11.1` | Cliente HTTP avanzado con interceptores de autenticación y manejo de errores |
| **flutter_secure_storage** | `^11.2.0` | Almacenamiento seguro del token JWT cifrado a nivel de sistema operativo |
| **hive** / **hive_flutter** | `^2.2.3` | Base de datos NoSQL local ultrarrápida para favoritos y caché offline |
| **path_provider** | `^2.1.4` | Acceso a directorios locales del dispositivo para la base de datos Hive |

## Seguridad

- **Tokens seguros**: Los tokens de sesión nunca se imprimen en consola y se almacenan en el Keychain (iOS) / Keystore (Android) a través de `flutter_secure_storage`.
- **Sanitización de registros**: `ReporteErrores.limpiar()` elimina expresiones con formato `Bearer ...` y tokens JWT antes de cualquier registro de log.

## Licencia

Este proyecto se distribuye bajo la licencia MIT.
