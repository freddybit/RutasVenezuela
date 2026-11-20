# Registro de decisiones

Decisiones técnicas aprobadas por el equipo. Los agentes deben respetarlas y no volver a consultarlas.
Formato: fecha · decisión · alternativas descartadas · motivo.

| # | Fecha | Decisión | Alternativas descartadas | Motivo |
| --- | --- | --- | --- | --- |
| D-01 | 2026-11-17 | Backend en NestJS 12 + TypeORM + PostgreSQL, patrón MSC, ESM, Vitest | — | Ya implementado y en curso |
| D-02 | 2026-11-17 | Frontend en Angular | — | Decisión del equipo |
| D-03 | 2026-11-17 | Tablas de datos con TanStack Table (`@tanstack/angular-table`) como motor headless, con paginado/orden/búsqueda del lado del servidor | — | Decisión del equipo; cubre el requisito de tablas del enunciado |
| D-04 | 2026-11-17 | Modelos: Opus para código (orquestador, backend, frontend); Sonnet para diseño UI/UX y revisión de documentación | — | Decisión del equipo |
| D-05 | 2026-11-17 | `GET /api/hitos/:idHito/cronogramas` pasa a paginado en servidor: respuesta `{ hito, data, meta }` (como REQ-32) con `q`, `estado`, `desde`/`hasta`, `sortBy`, `order`, `page`, `limit` | Mantener `{ hito, cronogramas }` sin paginar | Requisito de tablas del enunciado y D-03 |
| D-06 | 2026-11-17 | Lo que le falte a VA-02 para alimentar M-08 (localizar hitos, catálogo de tipos de actividad) lo genera el subagente `backend-dev` como parte de los módulos existentes, en lugar de endpoints "auxiliares" ad hoc | Endpoints auxiliares sueltos; no crear nada | Decisión del usuario |
| D-07 | 2026-11-17 | Seguridad lógica de BD de VA-02 (roles por actor, GRANT/REVOKE sobre `cronograma`, `actividad` y sus funciones) en `sql/freddy_fernandez.sql`; el resto del equipo replica el patrón | Script común `sql/seguridad.sql` posterior | Autoría por integrante; requisito del enunciado |
| D-08 | 2026-11-17 | Frontend en la última versión estable de Angular (standalone, signals, nuevo control flow), en `rutas-venezuela-frontend/` como carpeta hermana del backend, sin monorepo | Monorepo Nx; versión LTS anterior | Simplicidad; mismo esquema que el backend |
| D-09 | 2026-11-17 | Estilos con Tailwind CSS y componentes propios (modales, formularios, datepicker, paginador) sobre TanStack Table | Angular Material + CDK; PrimeNG | Decisión del usuario: control total del diseño |
| D-10 | 2026-11-17 | Reportes generados con jsreport (herramienta de reportes dedicada con plantillas) | Reportes nativos en Angular + impresión; nativos + pdfmake | Decisión del usuario; el enunciado acepta herramienta de reportes |
| D-12 | 2026-11-17 | La seguridad lógica de cada integrante va en `sql/<autor>_seguridad.sql` (VA-02: `sql/freddy_fernandez_seguridad.sql`), montado en `docker-compose.yml` después de los triggers (`05_…`). Precisa D-07 | Añadirla a `freddy_fernandez_triggers.sql`; dejarla en `freddy_fernandez.sql` y aplicarla a mano | `freddy_fernandez.sql` repite el DDL de `create.sql` y no se puede montar en docker; se conserva la autoría |
| D-11 | 2026-11-17 | Iconos Material Symbols; paleta y tipografía las propone `uiux-designer` a partir de los mockups y se consultan antes de aplicarse | Lucide | Encaja con el estilo de los mockups |
| D-13 | 2026-11-17 | Angular 22 (CLI 22.2.x, Node 22). JWT en `sessionStorage`; un interceptor añade `Authorization: Bearer` y un 401 cierra la sesión | localStorage; solo en memoria | Sobrevive a recargas y se borra al cerrar la pestaña; la corrección es en un equipo compartido |
| D-14 | 2026-11-17 | Estado del cliente con servicios inyectables basados en signals (`signal`/`computed`, HttpClient/`httpResource`), sin librería de store | NgRx Signal Store | Sin dependencias extra; el estado de las tablas vive en el servidor |
| D-15 | 2026-11-17 | Carpetas del frontend: `core/` (auth, interceptores, guards, layout), `shared/` (data-table TanStack, modales, inputs, paginador), `features/<dominio>/` con rutas lazy (p. ej. `features/cronogramas`) | Carpetas por integrante | Evita duplicar componentes; la autoría se indica por feature |
| D-16 | 2026-11-17 | Paleta A "Azul Orinoco + Oro" (primario `#14365D`, acento `#F2B705` / texto `#8A5A00`) con fuentes Inter + JetBrains Mono, neutros y colores de estado según `docs/design/sistema-de-diseno.md` | Paleta B "Verde Ávila + Barro" (Public Sans + IBM Plex Mono) | Más cercana a los mockups; contraste AA verificado |
| D-17 | 2026-11-17 | Se aprueban las adiciones al mockup M-08: localizador de hitos previo; buscador, filtros y paginador en cronogramas y actividades; acción "Cancelar actividad"; variante de solo lectura para visitante/guía con "Todas las actividades"; columna Cronograma y casilla Entrada libre | Solo filtros y Cancelar; mockup literal | Cubren REQ-32 y la regla de tablas del enunciado |
| D-18 | 2026-11-17 | Ampliaciones del API para M-08 (solo lectura): filtro `idCronograma` y `sortBy=horaInicio` en `GET /api/hitos/:id/actividades`; categorías en `GET /api/hitos/:id`; catálogos de estados/municipios/parroquias; filtro de hitos "de mi competencia" para el ente público | Dejar M-08 sin esos datos | Decisión del usuario; necesarias para la especificación de M-08 |
| D-19 | 2026-11-17 | Linter del frontend: angular-eslint (`ng add angular-eslint`, script `npm run lint`), que también revisa plantillas | oxlint como el backend; sin linter | Las plantillas Angular concentran lógica y accesibilidad |
| D-20 | 2026-11-17 | Filtro `competencia=mia` de `GET /api/hitos`: el ente público ve los hitos de los municipios registrados en `competencia`, sin ampliar por `nivel_territorial` | Ampliar según nivel (nacional = país, estadal = estado) | Coincide con los datos de prueba y con el esquema tal cual |

## Pendientes de decidir

- Integración de jsreport (D-10): dónde corre el servidor (servicio en `docker-compose`, jsreport embebido en el backend o instancia aparte), quién lo invoca (backend vs. frontend) y formato de salida (PDF, HTML).
