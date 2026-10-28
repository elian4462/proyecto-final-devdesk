# DevDesk Backend

Servidor HTTP REST y Proxy de Asistente de IA para el sistema **DevDesk** (Gestión de Incidentes TI y Monitoreo de Infraestructura).

## Características

- **Sin dependencias pesadas**: Construido con módulos estándar de Node.js (`http`, `crypto`, `fs`). Se ejecuta al instante sin requerir instalaciones complejas.
- **Autenticación JWT / Bearer**: Registro de técnicos, inicio de sesión seguro con hash SHA-256 de contraseñas y validación de tokens.
- **Inventario de Infraestructura**: 20 activos de TI precargados (servidores web, bases de datos PostgreSQL, firewalls Fortinet, switches Cisco, clusters Kubernetes, etc.).
- **CRUD de Tickets de Soporte**: Endpoints protegidos para crear, listar, modificar (PATCH con campos parciales) y eliminar tickets de soporte.
- **Proxy de Asistente IA (`/api/chat`)**: Motor de diagnóstico técnico que sugiere comandos y propone la creación automática de tickets estructurados (Human-in-the-Loop).
- **Persistencia Local**: Guarda datos en `db.json` para sobrevivir a reinicios.

## Cómo ejecutarlo

### Requisitos
- Node.js (versión 18 o superior).

### Comandos

1. Entra a la carpeta del servidor:
   ```bash
   cd server
   ```

2. Inicia el servidor:
   ```bash
   node server.js
   ```

3. El servidor quedará escuchando en `http://localhost:3000`.

### Probar todos los endpoints (E2E)

En otra terminal ejecuta:
```bash
node test-e2e.js
```

## Endpoints de la API

| Método | Ruta | Descripción | Requiere Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/usuarios/` | Registrar nuevo técnico | No |
| `POST` | `/usuarios/token` | Iniciar sesión y obtener JWT | No |
| `GET` | `/usuarios/me` | Obtener datos del perfil actual | Sí (Bearer) |
| `PATCH` | `/usuarios/password` | Cambiar contraseña | Sí (Bearer) |
| `GET` | `/activos/` | Catálogo de 20 activos TI reales | No |
| `GET` | `/tickets/` | Listado de tickets de soporte | Sí (Bearer) |
| `POST` | `/tickets/` | Crear nuevo ticket técnico | Sí (Bearer) |
| `PATCH` | `/tickets/:id` | Modificar estado o prioridad | Sí (Bearer) |
| `DELETE` | `/tickets/:id` | Eliminar ticket de soporte | Sí (Bearer) |
| `POST` | `/api/chat` | Asistente de diagnóstico con IA | No |

## Usuarios de Prueba Precargados

- **Admin TI**: `admin@empresa.com` / `admin-1234`
- **Técnico TI**: `tecnico@empresa.com` / `tecnico-1234`
