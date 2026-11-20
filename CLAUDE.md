# RutasVenezuela

Plataforma web + base de datos OLTP (PostgreSQL) de rutas turísticas y culturales de Venezuela. Proyecto universitario del Grupo 6.

- `rutas-venezuela-backend/` — API NestJS 12 + TypeORM (patrón MSC). Ver su `README.md` y `AGENTS.md`.
- `sql/` — esquema (`create`, `alter`, `insert`, `drop`) y scripts por autor (triggers, funciones). La autoría por integrante es requisito de evaluación.
- `docs/` — enunciado, requisitos del Grupo 6 (REQ/VA/REP, mockups M-01…M-11), ER y traducción relacional. Leer PDFs con `pdftotext -layout <pdf> -`.
- Frontend: Angular con tablas sobre TanStack Table (aún por crear).

## Modo de trabajo: orquestador + subagentes

La sesión principal actúa como **orquestador** y sigue el protocolo de `.claude/agents/orchestrator.md` (léelo al iniciar cualquier tarea de desarrollo). Delega en:

- `backend-dev` (Opus) — API y SQL.
- `frontend-dev` (Opus) — Angular + TanStack Table.
- `uiux-designer` (Sonnet) — especificaciones en `docs/design/`.
- `docs-reviewer` (Sonnet) — cumplimiento y `docs/trazabilidad.md`.

## Regla principal

**Toda decisión importante (tecnologías, dependencias, arquitectura, estructura de carpetas, patrones, contratos de API, cambios de esquema, sistema de diseño) se consulta al usuario antes de ejecutarla** y se registra en `docs/decisiones.md`. Las decisiones registradas allí no se vuelven a preguntar.

No hacer commits ni push sin que el usuario lo pida.
