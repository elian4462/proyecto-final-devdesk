# Lista de Verificación de Requisitos — Proyecto Final DevDesk

Comprobación contra los 9 criterios de evaluación de la rúbrica oficial (100%):

| # | Criterio | Peso | Estado | Evidencia Observable en DevDesk |
| :---: | :--- | :---: | :---: | :--- |
| **1** | **Persistencia remota o colaborativa** | 20% | ✅ Cumplido | CRUD completo de tickets en `GET`, `POST`, `PATCH /tickets/:id` y `DELETE /tickets/:id`, protegido con token JWT en el backend. |
| **2** | **Autenticación** | 15% | ✅ Cumplido | Registro (`/usuarios/`), login (`/usuarios/token`), cierre de sesión y restauración. Token almacenado en `FlutterSecureStorage`. Pantalla `SinSesionView` rechaza accesos sin sesión. |
| **3** | **Datos reales** | 15% | ✅ Cumplido | Catálogo de 20 activos de infraestructura tecnológica reales (servidores web, DB clusters, firewalls, switches Cisco, Kubernetes) servidos en `GET /activos/`. |
| **4** | **Persistencia local** | 10% | ✅ Cumplido | Hive persiste los activos marcados como favoritos (`activos_favoritos_box`) y mantiene caché offline de tickets con banner de advertencia si se pierde la red. |
| **5** | **Estado centralizado con GetX** | 10% | ✅ Cumplido | Estado compartido en `AuthController`, `ActivosController`, `TicketsController` y `AssistantController` mediante `.obs` y `Obx()`, sin `setState` disperso para datos globales. |
| **6** | **IA sin secretos** | 10% | ✅ Cumplido | `POST /api/chat` consumido a través de backend propio (`server/server.js`). Cero claves o secretos en la app móvil. `.env` ignorado con `.env.example`. |
| **7** | **Manejo de errores** | 10% | ✅ Cumplido | Estados explícitos de `LoadingView`, `EmptyView` y `ErrorView` con reintento en todas las pantallas. Traducción de códigos 400, 401, 404, 422 y 5xx. `ReporteErrores.instalar()` elimina la pantalla roja. |
| **8** | **Arquitectura en capas** | 5% | ✅ Cumplido | Desacoplamiento estricto: `screens/` → `controllers/` → `repositories/` → `services/` → backend. Ninguna vista llama a la red directamente. |
| **9** | **Documentación y entrega** | 5% | ✅ Cumplido | `README.md` exhaustivo y autosuficiente, flujos de GitHub Actions (`ci.yml` y `release-apk.yml`), `AGENTS.md` y suite completa de pruebas unitarias (`flutter test`). |
