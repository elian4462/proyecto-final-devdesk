# Arquitectura del Sistema — DevDesk

Este documento detalla la arquitectura de software, el flujo de datos y las decisiones técnicas de diseño implementadas en **DevDesk**.

## 1. Diagrama de Capas

```text
┌─────────────────────────────────────────────────────────────┐
│                    screens/ (Vistas UI)                     │
│  ActivosScreen, TicketsScreen, AssistantScreen, Login, ...  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Observa y despacha acciones
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 controllers/ (Estado con GetX)              │
│  ActivosController, TicketsController, AuthController, ...  │
└──────────────────────────────┬──────────────────────────────┘
                               │ Invoca operaciones de negocio
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               repositories/ (Patrón Repositorio)            │
│       TicketsRepository, ActivosRepository                  │
│       • Decide origen: Servidor (Network First) o Hive      │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────┐ ┌────────────────────────────┐
│          services/           │ │     Persistencia Local     │
│   ApiClient (Dio) & Auth     │ │     Hive & SecureStorage   │
└──────────────┬───────────────┘ └────────────────────────────┘
               │
               ▼ HTTP REST (JWT)
┌─────────────────────────────────────────────────────────────┐
│                    Backend Propio (Node.js)                 │
│         server.js (Usuarios, Activos, Tickets, IA)          │
└─────────────────────────────────────────────────────────────┘
```

## 2. Flujo de Datos: De la Red a la Pantalla

1. **Petición del Usuario**: El usuario entra a la pestaña de *Tickets*.
2. **Evaluación de Sesión**: `TicketsScreen` verifica reactivamente `auth.estaAutenticado`. Si no hay sesión, despliega `SinSesionView`.
3. **Controlador**: Si está autenticado, `TicketsController.cargarTickets()` cambia su estado observable a `EstadoCarga.cargando`.
4. **Estrategia Repositorio (Network First, Cache Fallback)**:
   - `TicketsRepository` solicita la lista remota a `TicketsApiService` (`GET /tickets/`).
   - El interceptor de `ApiClient` inyecta automáticamente el encabezado `Authorization: Bearer <token>`.
   - **Camino Exitoso**: Al recibir la respuesta HTTP 200, el repositorio serializa los datos en la caja Hive `tickets_cache_box`, actualiza la marca de tiempo de sincronización y retorna la lista al controlador.
   - **Camino de Contingencia (Offline)**: Si el servidor no responde o no hay conexión a internet, el repositorio lee la caja local de Hive y retorna los tickets con el indicador `desdeCache: true`.
5. **Actualización Reactiva**: El controlador asigna la lista a `tickets.assignAll(...)` y cambia el estado a `EstadoCarga.exito`.
6. **Renderizado**: El widget `Obx` de `TicketsScreen` reconstruye únicamente la lista de `TicketCard` y muestra el `MaterialBanner` offline si aplica.

## 3. Decisiones Técnicas Propias

- **Dominio Tecnológico (TIC)**: Se eligió el dominio de *Gestión de Incidentes TI y Monitoreo de Infraestructura* debido a su alta aplicabilidad profesional. Permite demostrar estados complejos (niveles de prioridad, telemetría de CPU/RAM, filtros por categorías de red/servidores/seguridad).
- **Backend Propio Autónomo en Node.js**: En lugar de requerir una base de datos pesada como PostgreSQL o Firebase con credenciales privadas, se desarrolló un servidor Node.js autónomo en `server/server.js` que no requiere instalar paquetes externos (`npm install`) y persiste en `db.json`. Esto permite a cualquier evaluador ejecutarlo inmediatamente con `node server.js`.
- **Human-in-the-Loop en IA**: Para la asistencia con IA, se implementó un mecanismo donde el modelo propone acciones estructuradas (`crear_ticket`), pero la aplicación siempre solicita confirmación explícita al técnico mediante un diálogo modal antes de escribir en la base de datos remota.
- **Seguridad en Repositorio**: El token JWT nunca se expone en consola gracias a `ReporteErrores.limpiar()`, y las variables de entorno están excluidas de Git mediante `.gitignore` con soporte para `.env.example`.
