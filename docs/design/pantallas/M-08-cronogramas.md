# M-08 · Gestión de Cronogramas y Agenda Cultural en Hito

Fuente: mockup `[M-08]` (RutasVenezuela_Grupo6.pdf, sección 3), VA-02 (sección 2.5), backend `rutas-venezuela-backend/README.md`. Tokens y componentes: `docs/design/sistema-de-diseno.md` (paleta pendiente de aprobación; aquí solo se nombran tokens).

## 1. Objetivo, roles y requisitos

| | |
| --- | --- |
| Objetivo | Programar y mantener la oferta cultural de un hito (cronogramas y sus actividades) y permitir que todos la consulten y filtren. |
| Requisitos | REQ-04 (CRUD, solo escritura admin/ente público), REQ-32 (consulta y filtrado por fecha, tipo y estado), RR-08 a RR-13, transiciones automáticas de vigencia. |
| Escriben | `administrador`, `ente_publico`. Ven botones Nuevo cronograma, Editar cronograma, Nueva actividad, editar, cancelar y eliminar. |
| Solo consultan | `visitante`, `guia` (REQ-32) y, por el contrato de lectura, `comercio`. No ven botones de escritura ni columna "Acciones"; sí buscan, filtran, ordenan y abren el detalle. |
| Entrada | Administrador/ente: barra lateral "Cronogramas de actividades" (mockup) o ficha del hito en M-05. Visitante/guía: "Agenda cultural" en su barra lateral, o la ficha de un hito. |

## 2. Rutas y flujo de navegación

1. `/hitos` (**localizador**, sección 3). Elegir hito lleva a:
2. `/hitos/:idHito/cronogramas` (**pantalla principal**, sección 4). Query params que conservan el estado: `cronograma=<id|todas>`, `vista=calendario|lista`, `mes=AAAA-MM`, y los filtros/orden/página de cada tabla (`q`, `estado`, `desde`, `hasta`, `tipo`, `sortBy`, `order`, `page`, `limit`).
3. Desde la pantalla principal: modales de formulario (crear/editar cronograma, crear/editar actividad), modal de detalle de actividad, y modales de confirmación (cancelar actividad, eliminar actividad, eliminar cronograma).
4. Migas: Patrimonio / Hitos de mi competencia (admin y ente) o Agenda cultural (visitante/guía) / {Hito} / Cronogramas.

Flujo de escritura: elegir hito → (Nuevo cronograma → llenar periodo + al menos 1 actividad → Guardar → toast "Cronograma creado" y queda seleccionado) → (Nueva actividad → Guardar → el calendario y la tabla se refrescan).

## 3. Localizador de hitos (`/hitos`)

Pantalla de entrada necesaria porque el mockup parte de un hito ya elegido (ver sección 12). Usa `GET /api/hitos`.

**Tabla**, tamaño de página por defecto **20**, orden por defecto `nombre asc`:

| Etiqueta | Campo API | Ordenable (`sortBy`) | Formato |
| --- | --- | --- | --- |
| Hito | `nombre` | sí (`nombre`) | Texto, enlace al hito |
| Parroquia | `parroquia.nombre` | sí (`parroquia`) | Texto |
| Municipio | `municipio.nombre` | sí (`municipio`) | Texto |
| Estado | `estado.nombre` | sí (`estado`) | Texto |
| Estado operativo | `estadoOperativo` | sí (`estadoOperativo`) | Badge de hito (tabla 2.4 del sistema) |
| Acceso | `libreAcceso` | no | "Libre acceso" / "Con horario" (ver sección 11, punto 2) |
| Acciones | — | no | Botón "Ver cronogramas" (`chevron_right`) |

**Filtros:** buscador `q` (nombre del hito, máx. 150); select **Estado operativo** (`estadoOperativo`: Todos, Disponible, En restauración, Clausurado temporalmente, Cerrado permanentemente); selects en cascada **Estado → Municipio → Parroquia** (`idEstado`, `idMunicipio`, `idParroquia`), que requieren catálogos territoriales (ver sección 11, punto 3). Hito con `admiteActividades=false`: badge con su estado y texto auxiliar "No admite actividades nuevas"; la fila sigue siendo navegable (la consulta es válida).

Estados: carga (esqueleto), vacío ("Aún no hay hitos registrados." / con filtros: "Ningún hito coincide con tu búsqueda." + Limpiar filtros), error con Reintentar.

## 4. Pantalla principal (`/hitos/:idHito/cronogramas`)

### 4.1 Estructura (escritorio ≥ 1024 px, como el mockup)

1. **Cabecera de página:** migas; H1 con el nombre del hito + badge de estado operativo; línea de contexto `parroquia · municipio · estado` (de `GET /api/hitos/:idHito`) y, cuando exista, categorías y acceso (ver sección 11, punto 2). A la derecha, botón primario **+ Nuevo cronograma** (solo escritura).
2. **Aviso de hito no operativo** (si `admiteActividades=false`): banner `--color-hito-*` con icono: "Este hito está {clausurado temporalmente | cerrado permanentemente}. No admite actividades nuevas y sus actividades activas se cancelaron." Con él, "Nuevo cronograma" y "Nueva actividad" quedan deshabilitados con ese motivo accesible (`aria-describedby`). Hito "En restauración" no bloquea (RR-12 solo clausurado/cerrado).
3. **Columna izquierda (≈ 300 px), "Cronogramas {total}":** lista paginada de cronogramas (sección 5). Primer elemento fijo: **"Todas las actividades"** (vista hito-wide para REQ-32; selección por defecto para visitante/guía; el administrador/ente tiene por defecto el primer cronograma).
4. **Panel derecho, cronograma seleccionado:**
   - Encabezado: nombre, rango `15/10/2026 — 30/11/2026` (monoespaciada), badge Activo/Finalizado, botón secundario **Editar cronograma** (lápiz) y botón primario **+ Nueva actividad**; menú "más" con **Eliminar cronograma** (peligro). Solo escritura.
   - Resumen: `9 actividades · 8 activas · 1 cancelada · 0 finalizadas` (de `conteoActividades`, o recalculado del detalle) con singular/plural correcto.
   - Pestañas **Calendario | Lista** (`role="tablist"`, flechas izquierda/derecha cambian de pestaña) y navegación de mes `‹ Noviembre 2026 ›` (botones con `aria-label` "Mes anterior"/"Mes siguiente"; el mes inicial es el del primer día con actividad, o el actual).
   - **Calendario mensual** (sección 6) o **Lista** (agenda del mes agrupada por día).
5. **Sección "Actividades del cronograma"** (sección 7): tabla paginada con filtros bajo el calendario. En modo "Todas las actividades" el título es "Actividades del hito" y se añade la columna Cronograma.

### 4.2 Responsive (≥ 360 px)

| Ancho | Comportamiento |
| --- | --- |
| ≥ 1024 | Dos columnas como el mockup. |
| 768–1023 | Una columna: la lista de cronogramas pasa a una tira horizontal de tarjetas con scroll y botones "anterior/siguiente" (o select "Cronograma" si hay más de 5). |
| < 768 | Una columna. Cronograma seleccionado con un **select** accesible arriba (opción "Todas las actividades"), botones a ancho completo (≥ 44 px), pestaña por defecto **Lista** (la rejilla de 7 columnas no es legible a 360 px; el calendario sigue disponible pero con celdas que muestran solo un contador de actividades por día y abren la lista del día), la tabla de actividades se convierte en **tarjetas** (nombre, fecha y horario, tipo, cupo, costo, badge, acciones) y los filtros se colapsan en "Filtros (n)". Formularios en modal a pantalla completa. |

## 5. Lista de cronogramas (panel izquierdo)

Datos: `GET /api/hitos/:idHito/cronogramas` (D-05). Se presenta como tarjetas sin perder la semántica de tabla (`role="list"`; el motor TanStack gestiona estado y orden en el servidor). Tamaño de página por defecto **10** (el límite del API es 100); paginador compacto debajo.

**Campos de cada fila** (tarjeta; seleccionable, `aria-current="true"` en la elegida):

| Etiqueta | Campo API | Ordenable (`sortBy`) | Formato |
| --- | --- | --- | --- |
| Nombre | `nombre` | sí (`nombre`) | Texto 600 |
| Periodo | `fechaInicio` – `fechaFin` | sí (`fechaInicio`, `fechaFin`) | `15/10/2026 — 30/11/2026`, monoespaciada |
| Estado | `estado` | sí (`estado`) | Badge Activo / Finalizado |
| Actividades | `conteoActividades.total` | sí (`actividades`) | "9 actividades" |
| Acciones | — | no | Solo escritura: editar y eliminar (iconos con `aria-label`) al enfocar/pasar el cursor; en móvil siempre visibles en el panel derecho |

Orden por defecto: `fechaInicio asc` (valor del API). Como las tarjetas no tienen cabecera, el orden se elige con un **select "Ordenar por"** (Nombre, Fecha de inicio, Fecha de fin, Estado, Cantidad de actividades) + botón de dirección (asc/desc, `aria-label` "Invertir orden").

**Búsqueda y filtros** (encima de la lista): buscador `q` ("Buscar cronograma", máx. 100); select **Estado** (`estado`: Todos, Activo, Finalizado); rango **Vigente entre** `desde`/`hasta` (datepickers; filtra por solape de periodo). Chips de filtros activos + Limpiar.

**Estados:**
- Carga: 3 tarjetas esqueleto, `aria-busy`.
- Vacío sin filtros: ilustración sencilla + "Este hito aún no tiene cronogramas." Escritores: botón "Registrar el primero". Lectura: "Este hito todavía no tiene programación cultural. Vuelve pronto."
- Vacío con filtros: "Ningún cronograma coincide con tu búsqueda." + Limpiar filtros.
- Error: "No pudimos cargar los cronogramas." + Reintentar.
- Hito inexistente (404 en `GET /api/hitos/:idHito`): página "No encontramos este hito" con enlace al localizador.

## 6. Calendario mensual

- Rejilla `role="grid"` de 7 columnas (Lun a Dom, semana inicia en lunes) con `aria-label="Calendario de {Mes Año}"`; cabeceras `columnheader` con día completo oculto visualmente ("lunes").
- Datos: `GET /api/hitos/:idHito/actividades` con `desde`/`hasta` = primer y último día visibles de la rejilla, `limit=100`, `sortBy=fecha` (+ filtro `idCronograma`, ver sección 11, punto 1). Se vuelve a pedir al cambiar de mes. Si `meta.total > 100`: aviso "Mostrando las primeras 100; usa la lista".
- Celda de día: número (días fuera del mes en trama diagonal y sin interacción; días fuera del periodo del cronograma atenuados con `aria-label` "fuera del periodo"; **hoy** con círculo `--color-primary` y texto blanco más `aria-label` "hoy"). Hasta 2 chips por celda: `HH:mm` + nombre truncado. Si hay más: "+N más" que abre un popover con la lista del día.
- **Chip de actividad:** borde izquierdo 3 px del color del estado; Activa (fondo `--color-activa-bg`), Cancelada (gris, **texto tachado**, prefijo "Cancelada"), Finalizada (fondo `--color-finalizada-bg`, icono check). Nunca solo color. Clic/Enter abre el detalle de la actividad.
- **Teclado:** la rejilla es un único tab stop; flechas mueven entre días, Inicio/Fin al extremo de la semana, AvPág/RePág cambian de mes, Enter abre el día (si tiene una actividad abre su detalle, si tiene varias abre la lista del día), Esc cierra el popover y devuelve el foco a la celda.
- **Lectores de pantalla:** cada celda con actividades tiene `aria-label` "7 de noviembre, 1 actividad: Concierto de música llanera, 19:30, Activa". Un resumen `aria-live="polite"` anuncia "Noviembre 2026: 9 actividades" al cambiar de mes.
- Estados: carga (rejilla con esqueleto, controles deshabilitados), mes sin actividades (rejilla normal + línea "Sin actividades este mes"), error ("No pudimos cargar el calendario." + Reintentar).
- **Pestaña Lista:** agenda del mismo mes agrupada por fecha (encabezado "Sábado 7 de noviembre" + filas con hora, nombre, tipo, badge). Es la vista por defecto en móvil y la alternativa recomendada para quien no use la rejilla.

## 7. Tabla de actividades

Datos: `GET /api/hitos/:idHito/actividades` (REQ-32; respuesta `{ hito, filtros, data, meta }`). Tamaño de página por defecto **20**; orden por defecto **`fecha asc`** ("Ordenadas por fecha" en el mockup). En modo cronograma se añade el filtro `idCronograma` (ver sección 11).

| Etiqueta | Campo API | Ordenable (`sortBy`) | Formato / alineación |
| --- | --- | --- | --- |
| Actividad | `nombre` | sí (`nombre`) | Texto; si `estado=Cancelada`, tachado y atenuado (más badge) |
| Fecha | `fecha` | sí (`fecha`) | `DD/MM/AAAA`, monoespaciada |
| Horario | `horaInicio`–`horaFin` | no (se ordena con fecha) | `19:00–20:30`, monoespaciada |
| Tipo | `tipo` | sí (`tipo`) | Texto capitalizado |
| Cupo máximo | `cupoMaximo` | sí (`cupo`) | Entero, derecha; `null` muestra "—" |
| Costo de entrada | `costoEntrada` | sí (`costo`) | `0` = "Libre"; si no, `Bs. 120,00` (formato es-VE, 2 decimales, derecha); `null` = "—" |
| Estado | `estado` | sí (`estado`) | Badge Activa / Cancelada / Finalizada |
| Cronograma (solo modo "Todas") | `cronograma.nombre` | sí (`cronograma`) | Texto + badge pequeño de su estado |
| Acciones (solo escritura) | — | no | Ver abajo |

**Acciones por fila** (escritura): **Editar** (`edit`), **Cancelar actividad** (`block`; solo si `estado=Activa`) y **Eliminar** (`delete`). Eliminar queda deshabilitado con motivo cuando es la única actividad del cronograma ("Es la única actividad del cronograma; elimina el cronograma o agrega otra antes", RR-08). Todos con `aria-label` que incluye el nombre ("Editar actividad Concierto de clausura"). Clic en el nombre abre el **detalle** (lectura para todos).

**Buscador y filtros** (REQ-32): buscador `q` ("Buscar por nombre de actividad o cronograma"); datepickers **Desde** y **Hasta** (`desde`, `hasta`; Hasta ≥ Desde, mensaje "La fecha final no puede ser anterior a la inicial."); select **Tipo** (`tipo`, opciones de `GET /api/actividades/tipos?idHito=:id`, con cantidad "Taller (5)"; opción "Todos"); select **Estado** (`estado`: Todos, Activa, Cancelada, Finalizada). Al filtrar se vuelve a la página 1. Los filtros del calendario y de la tabla son los mismos para el rango de fechas: cuando el usuario navega de mes, `desde`/`hasta` de la tabla no cambian (son filtros de la tabla; el calendario usa su propio rango).

**Estados:** carga (esqueleto de 5 filas, cabecera visible); vacío sin filtros ("Este cronograma aún no tiene actividades." para modo cronograma, que por RR-08 casi no ocurre; "Este hito aún no tiene actividades programadas." en modo "Todas"); vacío con filtros ("Ninguna actividad coincide con los filtros." + Limpiar filtros); error ("No pudimos cargar las actividades." + Reintentar). Pie con "Mostrando 1–9 de 9 actividades" y paginador (10/20/50 por página).

**Detalle de actividad (modal de lectura):** nombre, cronograma (con su periodo), fecha, horario, tipo, cupo máximo ("Sin límite" si `null`), costo, estado, nombre del hito. Escritores ven además **Editar**, **Cancelar actividad** y **Eliminar** en el pie.

## 8. Formularios, validaciones y confirmaciones

Validación en el cliente al perder el foco y al enviar (mensajes en español bajo cada campo, resumen de errores arriba del modal, foco al primer error). Los mismos errores que devuelve el servidor se muestran en ese resumen (el API prefija "RR-xx:"; se muestra el texto sin perder el código, p. ej. "Regla RR-11: …"). Fechas se envían `YYYY-MM-DD` y horas `HH:mm`.

### 8.1 Cronograma (crear / editar), modal de 720 px (pantalla completa en móvil)

| Campo | Control | Obligatorio | Validación y mensaje | Origen |
| --- | --- | --- | --- | --- |
| Nombre del cronograma | Input texto (contador) | sí | No vacío (tras recortar), máx. 100. "Escribe el nombre del cronograma." / "Máximo 100 caracteres." Duplicado en el mismo hito (409): "Este hito ya tiene un cronograma con ese nombre." | `nombre` (`CrearCronogramaDto`); clave parcial por hito |
| Fecha de inicio | Datepicker | sí | Fecha válida. "Indica la fecha de inicio." | `fechaInicio` |
| Fecha de fin | Datepicker (`min` = inicio) | sí | **RR-09:** inicio ≤ fin. "La fecha de inicio no puede ser posterior a la fecha de fin." | `fechaFin` |
| Actividades | Repetidor de bloques (8.2) | sí, **mínimo 1** (**RR-08**) | "Agrega al menos una actividad." El botón "Quitar" del único bloque está deshabilitado. | `actividades[]` (solo al crear) |

- **Crear:** estado inicial Activo (no editable, no se muestra como campo; el pie dice "Se creará como Activo"). Aviso de ayuda al cambiar el periodo después de agregar actividades: si alguna queda fuera, su campo fecha muestra el error RR-11.
- **Editar** (`PATCH /api/cronogramas/:id`): solo nombre y fechas; las actividades se editan aparte. Antes de enviar, el cliente comprueba **RR-11** con las actividades ya cargadas (`GET /api/cronogramas/:id`): "Estas actividades quedarían fuera del periodo: {nombre (fecha), …}." Si el cronograma está **Finalizado**, las fechas quedan deshabilitadas con la nota "Un cronograma finalizado no se puede reprogramar; registra uno nuevo." y solo el nombre es editable.
- Botones: **Guardar cronograma** (primario, carga "Guardando…") / **Cancelar**. Éxito: toast "Cronograma guardado".

### 8.2 Actividad (crear / editar), modal de 640 px; también bloque del repetidor del cronograma

| Campo | Control | Obligatorio | Validación y mensaje | Origen |
| --- | --- | --- | --- | --- |
| Nombre de la actividad | Input texto | sí | No vacío, máx. 100. "Escribe el nombre de la actividad." | `nombre` |
| Tipo | Combobox editable con sugerencias de `GET /api/actividades/tipos?idHito=` (texto libre permitido, p. ej. concierto, taller, visita guiada) | sí | No vacío, máx. 50. "Indica el tipo de actividad." | `tipo` (`tipo_act` VARCHAR(50)) |
| Fecha | Datepicker (`min`=inicio y `max`=fin del cronograma) | sí | **RR-11:** dentro del periodo, inclusive. "La fecha debe estar entre {inicio} y {fin}." | `fecha` |
| Hora de inicio | Input hora 24 h | sí | "Indica la hora de inicio." | `horaInicio` |
| Hora de fin | Input hora 24 h | sí | **RR-10:** inicio < fin el mismo día. "La hora de inicio debe ser menor que la hora de fin." | `horaFin` |
| Cupo máximo | Input numérico entero | no | Si se llena: entero 1–999.999. "Indica un número entero entre 1 y 999.999." Vacío = sin límite (en edición enviar `null` para quitarlo). | `cupoMaximo` |
| Entrada libre | Casilla | no | Si está marcada, costo = 0 y el campo se deshabilita. Se marca sola al editar una actividad con costo 0. | UI |
| Costo de entrada (Bs.) | Input numérico, 2 decimales | no | ≥ 0, máx. 2 decimales. "Indica un monto de 0 o más, con hasta 2 decimales." Vacío en hito de libre acceso se guarda como 0; vacío en otro hito queda sin definir (en edición enviar `null`). Ayuda: "Déjalo vacío si aún no se define." | `costoEntrada` |

- **RR-12:** si `admiteActividades=false`, el botón de abrir el formulario de creación está deshabilitado y, si el API aún responde 422, el resumen muestra "El hito está {estado} y no admite actividades activas (RR-12)." Editar una actividad **Cancelada** o **Finalizada** de un hito clausurado sí se permite (el servidor solo exige hito abierto para actividades Activa).
- **RR-13:** en un cronograma Finalizado, "Nueva actividad" está deshabilitado ("Este cronograma finalizó y no admite actividades nuevas (RR-13)").
- El **estado** de la actividad no se edita en el formulario; se cambia solo con **Cancelar actividad** o por las transiciones automáticas.
- Pie de edición: **Guardar cambios** / **Cancelar**. Éxito: toast "Actividad guardada".

### 8.3 Confirmaciones (modal de 480 px, foco inicial en el botón seguro)

| Acción | Título y texto | Botones |
| --- | --- | --- |
| Cancelar actividad (`PATCH …/cancelar`, solo Activa) | "¿Cancelar la actividad «{nombre}»?" Se conserva el registro con estado Cancelada y no se puede revertir. | **Mantener actividad** / **Cancelar actividad** (peligro). Toast "Actividad cancelada". |
| Eliminar actividad (`DELETE`) | "¿Eliminar la actividad «{nombre}»?" Se borrará de forma definitiva y no se puede deshacer. Si solo no se realizará, usa Cancelar para conservar el registro (enlace dentro del modal). Si es la única actividad: error 409 "RR-08…" → botón deshabilitado de antemano. | **Conservar** / **Eliminar** (peligro). |
| Eliminar cronograma (`DELETE`) | "¿Eliminar el cronograma «{nombre}»?" Se eliminarán también sus {N} actividades de forma definitiva. | **Conservar** / **Eliminar cronograma** (peligro). Tras el éxito se selecciona el siguiente cronograma. |

### 8.4 Mapeo de errores del API

| Código | Tratamiento |
| --- | --- |
| 400 | Mensajes bajo el campo correspondiente (resumen arriba). |
| 401 | Cierra sesión (interceptor, D-13). |
| 403 | Toast "No tienes permiso para realizar esta acción."; se ocultan los controles de escritura. |
| 404 | "Este elemento ya no existe." y se refresca la lista. |
| 409 | Duplicado o conflicto de estado: mensaje del servidor en el resumen. |
| 422 | Regla de negocio (RR-08…RR-13): mensaje del servidor en el resumen y bajo el campo implicado. |
| Red / 5xx | "No pudimos conectar con el servidor. Revisa tu conexión e inténtalo de nuevo." Sin perder los datos del formulario. |

## 9. Vigencia y transiciones automáticas (visibles en la interfaz)

- Cronograma pasa a **Finalizado** y sus actividades Activa a **Finalizada** al superar `fechaFin`: tras cargar, el panel muestra, si procede, la nota informativa "Este cronograma finalizó el {fecha}. Sus actividades pendientes pasaron a Finalizada."
- Hito clausurado o cerrado: sus actividades Activa pasan a Cancelada; se refleja en los badges y en el aviso del punto 4.1.2.
- La pantalla no ejecuta esas transiciones; vuelve a pedir los datos al abrir y con el botón "Actualizar" (`refresh`) del panel.

## 10. Accesibilidad específica

Un solo H1 (nombre del hito). Foco: al abrir un modal va al primer campo (o al botón seguro en confirmaciones) y vuelve al disparador al cerrar. Los badges y chips comunican el estado con texto; la rejilla del calendario se maneja por teclado; la tabla usa `aria-sort`; los anuncios de carga y de mes usan `aria-live="polite"`. Objetivos táctiles de 44 px en móvil y sin acciones solo por hover. Toda la funcionalidad del calendario existe también en la Lista y en la tabla (alternativa sin rejilla).

## 11. Datos que el API aún no expone (para `backend-dev`, D-06)

1. **Filtro `idCronograma` en `GET /api/hitos/:idHito/actividades`.** La tabla de "Actividades del cronograma" y el calendario por cronograma necesitan paginado, orden y búsqueda en servidor limitados a un cronograma. `GET /api/cronogramas/:id` devuelve todas las actividades sin paginar ni filtrar, y no cumple la regla de tablas.
2. **Categorías y tipo de acceso del hito** (mockup: "Histórico, Arquitectura · Con horario") en `GET /api/hitos/:idHito`. Hoy solo hay `libreAcceso` (booleano); faltan `categorias[]`. "Con horario" puede derivarse de `libreAcceso=false`.
3. **Catálogos territoriales** (estados, municipios por estado, parroquias por municipio) para los selects en cascada del localizador; lo previsible es que ya existan para M-05.
4. **Alcance "de mi competencia"** (ente público): el mockup lista "Hitos de mi competencia". `GET /api/hitos` no filtra por ente; hace falta un parámetro (p. ej. `miCompetencia=true`) o que el API lo aplique según el actor autenticado.
5. (Opcional) `sortBy=horaInicio` en actividades para ordenar por horario dentro del día.
6. (Opcional) En `conteoActividades` del cronograma, ya basta para el resumen; en el detalle de actividad conviene `hito.nombre` (hoy en `hito`).

## 12. Desviaciones respecto al mockup

DECISIÓN PENDIENTE
- Pregunta: ¿Se aprueban estas adiciones al mockup M-08, todas exigidas por requisitos o reglas del proyecto? (a) Pantalla localizador de hitos previa. (b) Buscador, filtros y paginador en la tabla de actividades y en la lista de cronogramas (regla de tablas del enunciado y D-05). (c) Acción "Cancelar actividad" por fila (REQ-04 U) además de lápiz y papelera. (d) Variante de solo lectura para visitante/guía (REQ-32) y elemento "Todas las actividades". (e) Columna "Cronograma" y casillas "Entrada libre".
- Opciones: A) Aprobar todas. B) Aprobar solo (b) y (c) y resolver las demás con otra pantalla. C) Mantener el mockup literal (no cumpliría REQ-32 ni la regla de tablas).
- Recomendación: A, porque cada adición cubre un requisito documentado sin cambiar el aspecto del mockup.
- Qué queda bloqueado: la implementación del localizador, de los filtros de la tabla y de la variante de lectura por `frontend-dev`.
