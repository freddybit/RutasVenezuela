# Sistema de diseño base · RutasVenezuela

Estado: **PROPUESTA, pendiente de aprobación del usuario** (paleta y tipografía, D-11). Hasta entonces `frontend-dev` no debe fijar los valores de color/fuente; sí puede construir la estructura de tokens de este documento.

Decisiones vinculantes: D-08 Angular 22 · D-09 Tailwind CSS (v4) + componentes propios · D-03 TanStack Table · D-11 Material Symbols. Modo oscuro: **no aprobado**, no se especifica (el bloque de tokens permite añadirlo luego con un segundo `@theme`/`[data-theme]`).

Base visual tomada de los mockups M-01…M-11: interfaz sobria, fondo claro, barra lateral gris con secciones en versalitas monoespaciadas, botón primario oscuro, tablas densas con cabecera gris, fechas/horas/cédulas en monoespaciada, insignias "píldora" con punto de estado, iconos de lápiz y papelera por fila.

## 1. Alternativas de paleta

| | **A (recomendada) · "Azul Orinoco + Oro"** | **B · "Verde Ávila + Barro"** |
| --- | --- | --- |
| Primario | `#14365D` (hover `#0E2A4A`) | `#0F5B4D` (hover `#0A453A`) |
| Secundario / acento | `#F2B705` relleno, `#8A5A00` como texto | `#E9B49A` relleno, `#A8431F` como texto |
| Fuentes | Inter + JetBrains Mono | Public Sans + IBM Plex Mono |
| Justificación | Se acerca al botón casi negro de los mockups y evoca el azul y el amarillo de la bandera sin usar el rojo, reservado a errores. | Verde de montaña y tierra cocida aluden al paisaje y a la arquitectura colonial, pero se alejan más del tono neutro de los mockups. |

El resto de tokens (neutros, estados, actividad, hito) es **común** a ambas. Solo cambian los de la sección 2.1 y las fuentes.

## 2. Color

Todos los pares de texto cumplen **WCAG AA (≥ 4,5:1)**; los bordes de controles y el anillo de foco cumplen ≥ 3:1 (no texto). Ratios calculados con la fórmula de luminancia relativa WCAG 2.x.

### 2.1 Marca (varía por alternativa)

| Token | A | B | Uso | Contraste |
| --- | --- | --- | --- | --- |
| `--color-primary` | `#14365D` | `#0F5B4D` | Botón primario, enlaces, ítem activo | texto blanco: A 12,24 · B 8,00 |
| `--color-primary-hover` | `#0E2A4A` | `#0A453A` | Hover/pressed | blanco: A 14,5 |
| `--color-primary-soft` | `#E8EEF6` | `#E4F1EE` | Fondo de ítem seleccionado, hover de filas | `--color-primary` sobre él: A 10,49 · B 6,9 |
| `--color-accent` | `#F2B705` | `#E9B49A` | Rellenos decorativos (nunca como única señal) | texto `#1F2328` sobre A: 8,69 |
| `--color-accent-text` | `#8A5A00` | `#A8431F` | Acento como texto sobre blanco | A 5,93 · B 6,02 |

### 2.2 Neutros (comunes)

| Token | Hex | Uso | Contraste |
| --- | --- | --- | --- |
| `--color-bg` | `#F6F7F9` | Fondo de la app y barra lateral | |
| `--color-surface` | `#FFFFFF` | Tarjetas, tablas, modales | |
| `--color-text` | `#1F2328` | Texto principal | sobre blanco 15,8 |
| `--color-text-muted` | `#5B6470` | Texto secundario, cabeceras de tabla | blanco 6,0 · bg 5,59 |
| `--color-border` | `#DDE1E6` | Divisores decorativos | (no texto) |
| `--color-border-strong` | `#8A939E` | Borde de inputs y controles | blanco 3,11 (≥ 3:1) |
| `--color-focus` | `#1A6FD6` | Anillo de foco 2 px + offset 2 px | blanco 4,9 |
| `--color-overlay` | `#1F2328` al 50 % | Fondo de modales | |

### 2.3 Estados de sistema (texto sobre fondo suave)

| Token (fg / bg) | fg | bg | Contraste |
| --- | --- | --- | --- |
| `--color-success` / `-bg` | `#146C2E` | `#E6F4EA` | 5,75 |
| `--color-warning` / `-bg` | `#8A5300` | `#FFF4DC` | 5,79 |
| `--color-danger` / `-bg` | `#B3261E` | `#FDECEA` | 5,72 (sobre blanco 6,54) |
| `--color-info` / `-bg` | `#0B5CAD` | `#E7F1FB` | 5,84 |

### 2.4 Semánticos de dominio

Cada estado lleva **color + icono/forma + texto** (nunca solo color), siguiendo los mockups (punto lleno, medio, círculo vacío).

**Actividad** (`estado`: Activa / Cancelada / Finalizada):

| Valor API | Token | fg | bg | Indicador | Contraste |
| --- | --- | --- | --- | --- | --- |
| `Activa` | `--color-activa` | `#146C2E` | `#E6F4EA` | punto lleno | 5,75 |
| `Cancelada` | `--color-cancelada` | `#5B6470` | `#EEF0F3` | círculo vacío; nombre tachado en la fila | 5,25 |
| `Finalizada` | `--color-finalizada` | `#3C4A9E` | `#ECEEFB` | icono check | 6,82 |

**Cronograma** (`Activo` / `Finalizado`): reutiliza `--color-activa` y `--color-finalizada`.

**Hito** (`estadoOperativo`):

| Valor API | Etiqueta UI | Token | fg | bg | Indicador | Contraste |
| --- | --- | --- | --- | --- | --- | --- |
| `disponible` | Disponible | `--color-hito-disponible` | `#146C2E` | `#E6F4EA` | punto lleno | 5,75 |
| `en restauración` | En restauración | `--color-hito-restauracion` | `#8A5300` | `#FFF4DC` | medio círculo | 5,79 |
| `clausurado temporalmente` | Clausurado temporalmente | `--color-hito-clausurado` | `#B3261E` | `#FDECEA` | círculo vacío | 5,72 |
| `cerrado permanentemente` | Cerrado permanentemente | `--color-hito-cerrado` | `#3F4650` | `#E3E6EA` | icono candado | 7,61 |

## 3. Tipografía

Google Fonts, `font-display: swap`, preferible autoalojada (`@fontsource`); pesos 400, 500, 600 y 700.

| Token | A | B |
| --- | --- | --- |
| `--font-sans` | `"Inter", system-ui, sans-serif` | `"Public Sans", system-ui, sans-serif` |
| `--font-mono` | `"JetBrains Mono", ui-monospace, monospace` | `"IBM Plex Mono", ui-monospace, monospace` |

`--font-mono` se usa en **fechas, horas, cédulas/RIF, montos y rangos** (como en los mockups), con `font-variant-numeric: tabular-nums`.

| Token | Tamaño / interlineado | Peso | Uso |
| --- | --- | --- | --- |
| `--text-xs` | 12 / 16 px | 500 | Versalitas de sección de la barra lateral, ayudas, contadores |
| `--text-sm` | 14 / 20 px | 400 | Tablas, formularios, botones |
| `--text-base` | 16 / 24 px | 400 | Texto de cuerpo, inputs en móvil (evita zoom en iOS) |
| `--text-lg` | 18 / 28 px | 600 | Títulos de tarjeta/modal |
| `--text-xl` | 22 / 30 px | 700 | Título de página (H1) |
| `--text-2xl` | 28 / 36 px | 700 | Cifras de resumen |

Mínimo 12 px; el cuerpo no baja de 14 px. Debe soportar zoom del navegador al 200 % sin pérdida de funcionalidad.

## 4. Espaciado, radios, sombras, movimiento

- **Espaciado** (base 4 px, escala por defecto de Tailwind). Pasos habituales 4/8/12/16/24/32. Gutter de página 16 px (móvil) / 24 px (≥ md) / 32 px (≥ xl).
- **Radios:** `--radius-sm` 4 px, `--radius-md` 6 px (inputs, botones), `--radius-lg` 10 px (tarjetas, modales), `--radius-pill` 999 px (insignias, chips).
- **Sombras:** `--shadow-card` `0 1px 2px rgb(31 35 40 / .06)`; `--shadow-popover` `0 8px 24px rgb(31 35 40 / .16)` (menús, datepicker); `--shadow-modal` `0 16px 48px rgb(31 35 40 / .24)`.
- **Movimiento:** 150 ms `ease-out` en hover/foco, 200 ms en modales y toasts. Con `prefers-reduced-motion: reduce` se eliminan transiciones y desplazamientos animados.
- **Breakpoints:** `sm` 640, `md` 768, `lg` 1024, `xl` 1280. Mobile-first desde 360 px.
- **Objetivo táctil:** mínimo 44 × 44 px en móvil (botones de icono, acciones de fila); 36 px de alto en escritorio.

## 5. Bloque de tokens para Tailwind v4

Valores con la alternativa A; B solo cambia las variables de 2.1 y las fuentes.

```css
@import "tailwindcss";

@theme {
  --font-sans: "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;

  --color-primary: #14365D;
  --color-primary-hover: #0E2A4A;
  --color-primary-soft: #E8EEF6;
  --color-accent: #F2B705;
  --color-accent-text: #8A5A00;

  --color-bg: #F6F7F9;
  --color-surface: #FFFFFF;
  --color-text: #1F2328;
  --color-text-muted: #5B6470;
  --color-border: #DDE1E6;
  --color-border-strong: #8A939E;
  --color-focus: #1A6FD6;

  --color-success: #146C2E;   --color-success-bg: #E6F4EA;
  --color-warning: #8A5300;   --color-warning-bg: #FFF4DC;
  --color-danger:  #B3261E;   --color-danger-bg:  #FDECEA;
  --color-info:    #0B5CAD;   --color-info-bg:    #E7F1FB;

  --color-activa: #146C2E;      --color-activa-bg: #E6F4EA;
  --color-cancelada: #5B6470;   --color-cancelada-bg: #EEF0F3;
  --color-finalizada: #3C4A9E;  --color-finalizada-bg: #ECEEFB;
  --color-hito-disponible: #146C2E;    --color-hito-disponible-bg: #E6F4EA;
  --color-hito-restauracion: #8A5300;  --color-hito-restauracion-bg: #FFF4DC;
  --color-hito-clausurado: #B3261E;    --color-hito-clausurado-bg: #FDECEA;
  --color-hito-cerrado: #3F4650;       --color-hito-cerrado-bg: #E3E6EA;

  --radius-sm: 4px; --radius-md: 6px; --radius-lg: 10px;
  --shadow-card: 0 1px 2px rgb(31 35 40 / .06);
  --shadow-popover: 0 8px 24px rgb(31 35 40 / .16);
  --shadow-modal: 0 16px 48px rgb(31 35 40 / .24);
}
```

Clases resultantes: `bg-primary`, `text-text-muted`, `bg-activa-bg text-activa`, `rounded-lg`, `shadow-card`, `font-mono`.

## 6. Iconos

Material Symbols **Outlined**, peso 400, tamaño óptico 20 (16 en tablas, 24 en navegación). Cargar solo el subconjunto usado (fuente variable con `icon_names=`). Icono decorativo con `aria-hidden="true"`; botón solo con icono lleva `aria-label` y `title`.

Base: `add`, `edit`, `delete`, `close`, `search`, `filter_list`, `calendar_month`, `arrow_upward`/`arrow_downward`/`unfold_more` (orden), `chevron_left`/`chevron_right`, `check_circle`, `error`, `warning`, `info`, `block` (cancelar), `lock` (cerrado), `accessible`, `logout`, `menu`.

## 7. Componentes base y estados

Estados comunes: **reposo, hover, foco (anillo `--color-focus` 2 px), activo, deshabilitado** (texto `--color-text-muted`, fondo `--color-bg`, `aria-disabled`, con motivo visible), **error** (borde y texto `--color-danger` + icono + mensaje), **carga**.

### 7.1 Botón
Variantes: **primario** (fondo `--color-primary`, texto blanco), **secundario** (borde `--color-border-strong`, fondo surface), **peligro** (fondo `--color-danger`, texto blanco; confirma borrados), **fantasma/icono** (sin borde, 44 px táctil). Tamaños: `md` 36 px, `lg` 44 px (móvil). Carga: spinner + "Guardando…", `aria-busy`, sin reenvío. Un botón deshabilitado por regla de negocio explica por qué.

### 7.2 Input de texto / número
Etiqueta visible encima (el placeholder nunca sustituye la etiqueta); obligatorio con "(obligatorio)" + `aria-required`; ayuda opcional; error bajo el campo con `aria-describedby` y `aria-invalid`. Contador en campos con máximo. Alto 36 px (44 en móvil), borde `--color-border-strong`, radio `--radius-md`.

### 7.3 Select
`<select>` nativo estilizado. Opción vacía "Todos" / "Selecciona…". Catálogos largos (hitos) usan el combobox (7.5).

### 7.4 Datepicker
Campo de texto visible `DD/MM/AAAA` + botón `calendar_month`; valor de intercambio con la API `YYYY-MM-DD`. Escribible y con popover de rejilla mensual (`role="grid"`): flechas mueven el día, AvPág/RePág el mes, Inicio/Fin la semana, Esc cierra, Enter selecciona. Admite `min`/`max` (días fuera de rango con `aria-disabled`). Semana inicia en lunes (como M-08). Hora: `<input type="time">` nativo 24 h, paso de 5 min.

### 7.5 Combobox / localizador
Patrón ARIA combobox: texto con debounce 300 ms, lista navegable con flechas, `aria-live="polite"` anuncia "N resultados". Estados: cargando, sin resultados, error con "Reintentar".

### 7.6 Modal
`role="dialog"` `aria-modal="true"` `aria-labelledby`; atrapa el foco, Esc cierra (salvo guardando), el foco vuelve al disparador, bloquea el scroll de fondo. Ancho 480 (confirmación) / 640 (formulario) px; en móvil pantalla completa con cabecera fija y botones al pie. Clic fuera cierra solo en confirmaciones sin datos.

### 7.7 Toast
Esquina inferior derecha (móvil: inferior, ancho completo), 5 s, pausa en hover/foco, botón cerrar. `role="status"` (éxito/info) y `role="alert"` (error); los errores no se autocierran. Máximo 3 apilados.

### 7.8 Badge de estado
Píldora, borde 1 px del color del estado, fondo `*-bg`, texto 12–13 px peso 500, **indicador + etiqueta** (tabla 2.4). El indicador es `aria-hidden`; el texto es la señal accesible.

### 7.9 Data-table (TanStack Table, D-03)
Regla de proyecto: **paginado, orden por columna y búsqueda, todo en servidor** (`manualPagination`, `manualSorting`, `manualFiltering`).
- Cabecera `--color-bg`, `--text-xs`, `--color-text-muted`. Columna ordenable: `<button>` dentro de `<th aria-sort="ascending|descending|none">` con `arrow_upward/downward/unfold_more`. Ciclo: asc, desc, orden por defecto de la pantalla.
- Filas 48 px, borde inferior `--color-border`, hover `--color-primary-soft`. Números alineados a la derecha; fechas y horas en monoespaciada.
- Acciones por fila: icono con `aria-label` ("Editar actividad X"); eliminar siempre con modal de confirmación.
- Estados: **cargando** (esqueleto de N filas, `aria-busy="true"`, cabecera visible), **vacío** (icono + frase + acción si procede; distingue "no hay datos" de "ningún resultado con estos filtros" con botón "Limpiar filtros"), **error** (mensaje + "Reintentar", `role="alert"`).
- Móvil (< 768 px): cada fila se transforma en **tarjeta** con pares etiqueta/valor y acciones; sin scroll horizontal.
- `<caption>` visualmente oculto con el nombre de la tabla.

### 7.10 Buscador
Input con icono `search`, `role="search"`, debounce 300 ms, botón limpiar. Al buscar vuelve a la página 1. `Ctrl K` enfoca el buscador global (como en los mockups).

### 7.11 Filtros (búsqueda avanzada)
Fila de controles bajo el título; en móvil se colapsa en botón "Filtros (n)" que abre un panel. Chips con filtros activos y "Limpiar filtros". Selects/fechas se aplican al cambiar; texto con debounce. El estado vive en la URL (query params).

### 7.12 Paginador
Selector "10 / 20 / 50 por página" (**20 por defecto**), texto "Mostrando 1–8 de 8", anterior/siguiente con `aria-label`, números de página (máx. 5 con "…"), actual con `aria-current="page"`. Deshabilitado mientras carga; cambios anunciados con `aria-live`.

### 7.13 Layout con barra lateral por rol
- Barra superior: logo, buscador global, campana, avatar con nombre y rol/entidad, menú (cerrar sesión).
- Barra lateral 240 px con secciones en versalitas mono (`SUPERVISIÓN`, `PATRIMONIO`, `REPORTES`, `INSTITUCIÓN`…). Ítem activo con fondo `--color-primary-soft`, borde izquierdo 3 px `--color-primary` y `aria-current="page"`. Los ítems dependen del rol.
- Responsive: ≥ lg barra fija; < lg oculta tras botón `menu`, como panel deslizante con foco atrapado. Enlace "Saltar al contenido" como primer elemento tabulable.
- Migas de pan (`<nav aria-label="Ruta de navegación">`) sobre el H1; el último ítem sin enlace.
- Pie de la barra: "v0.1 · prototipo" (como en los mockups).

## 8. Accesibilidad (prioridad: movilidad reducida)

- **Contraste AA** en todo texto; ningún estado depende solo del color.
- **Foco visible** siempre (anillo 2 px + offset 2 px); nunca `outline: none` sin sustituto.
- **Teclado completo:** todo operable sin ratón; orden de tabulación = orden visual; calendario y datepicker por teclado; sin trampas de foco salvo modales.
- **Objetivos táctiles ≥ 44 × 44 px** en móvil, separados ≥ 8 px; sin gestos complejos (siempre hay alternativa por botón).
- **Formularios:** etiqueta asociada, "(obligatorio)", errores en texto con `aria-describedby`, resumen de errores arriba del modal con enlaces a los campos, foco al primer error al enviar, no se borra lo escrito al fallar.
- **Tiempo:** sin límites; toasts de error persistentes.
- **Semántica:** `<th scope>` y `aria-sort`, regiones (`header`, `nav`, `main`), un H1 por pantalla, `lang="es"`, `aria-live` en cargas y resultados.
- **Movimiento reducido** respetado; sin parpadeos.
- **Dominio de movilidad reducida:** los datos de accesibilidad de hitos y rutas se muestran con texto e icono `accessible`, nunca solo con color.
- Verificación sugerida: axe/Lighthouse ≥ 95 y recorrido manual solo con teclado en cada pantalla.

## 9. Microcopys generales (español)

Tuteo, botones con verbo: "Guardar cambios", "Cancelar", "Eliminar". Borrado: "Esta acción no se puede deshacer." Red: "No pudimos conectar con el servidor. Revisa tu conexión e inténtalo de nuevo." Sesión: "Tu sesión expiró. Inicia sesión de nuevo." Permisos: "No tienes permiso para realizar esta acción."

---

DECISIÓN PENDIENTE
- Pregunta: ¿Qué paleta y tipografía se adoptan?
- Opciones: A) Azul Orinoco + Oro, Inter + JetBrains Mono. B) Verde Ávila + Barro, Public Sans + IBM Plex Mono.
- Recomendación: A, porque es la más fiel al tono sobrio y oscuro de los mockups y su primario tiene el mayor contraste.
- Qué queda bloqueado: valores finales de `@theme` y carga de fuentes en el frontend.
