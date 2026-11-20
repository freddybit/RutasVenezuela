-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: create.sql  (PostgreSQL)
-- Contenido: secuencias y tablas con columnas, nulidad, valores por defecto,
--            clave primaria, claves alternas (UNIQUE) y restricciones CHECK.
--            Las claves foraneas se agregan en alter.sql.
--
-- Claves sustitutas:
--   * Cada tabla tiene una clave primaria sustituta id_<tabla> (NUMERIC
--     autoincremental por secuencia). Perfil ya la tenia (id_perfil).
--   * La clave primaria de la traduccion se conserva como clave alterna
--     (UNIQUE ..._clave) para mantener la unicidad del negocio.
--   * Toda referencia a otra tabla se hace por su id (columna id_<tabla>), no
--     por las columnas de su clave natural, para simplificar los joins.
--
-- Fuente: docs/RutasVenezuela-Traduccion-y-restricciones-ER.pdf
-- Orden de ejecucion: drop.sql -> create.sql -> alter.sql
-- =============================================================================

-- =============================================================================
-- SECUENCIAS
-- =============================================================================

CREATE SEQUENCE seq_estado                  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_municipio               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_parroquia               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ubicacion_geografica    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_horario                 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hito                    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hito_categoria          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cuenta_con              START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cronograma              START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_actividad               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_punto_geoespacial       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_perfil                  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_visitante               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_guia                    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_guia_especialidad       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_guia_idioma             START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_trabaja                 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_comercio                START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_disponible              START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ente_publico            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_competencia             START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_administrador           START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ruta_turistica          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_conforma                START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_infraestructura_fisica  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_infraestructura_modo    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_se_despliega            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sirve                   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_parada_transporte       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_equipamiento_urbano     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_funciona                START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_usa                     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cercana                 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_experiencia_turistica   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_incluye                 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_credencial_digital      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_reporte_ruta            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_numero_reporte          START WITH 1 INCREMENT BY 1;  -- numero_reporte (correlativo)
CREATE SEQUENCE seq_recorrido               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_paso                    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_evaluacion_experiencia  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_rango_explorador        START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_pasaporte_turistico     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_insignia_turistica      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_logro                   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ruta_favorita           START WITH 1 INCREMENT BY 1;


-- =============================================================================
-- MODULO 1. Territorio, patrimonio e hitos urbanos
-- =============================================================================

-- Autor: Diego Mirabal
CREATE TABLE estado (
    id_estado                   NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_estado'),
    nombre_estado               VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_estado PRIMARY KEY (id_estado),
    CONSTRAINT uq_estado_clave UNIQUE (nombre_estado)
);

-- Autor: Diego Mirabal
-- [REQ-01] Puede repetirse el nombre del municipio en estados distintos.
CREATE TABLE municipio (
    id_municipio                NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_municipio'),
    id_estado                   NUMERIC(10,0)   NOT NULL,
    nombre_municipio            VARCHAR(80)     NOT NULL,
    CONSTRAINT pk_municipio PRIMARY KEY (id_municipio),
    CONSTRAINT uq_municipio_clave UNIQUE (id_estado, nombre_municipio)
);

-- Autor: Diego Mirabal
CREATE TABLE parroquia (
    id_parroquia                NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_parroquia'),
    id_municipio                NUMERIC(10,0)   NOT NULL,
    nombre_parroquia            VARCHAR(80)     NOT NULL,
    CONSTRAINT pk_parroquia PRIMARY KEY (id_parroquia),
    CONSTRAINT uq_parroquia_clave UNIQUE (id_municipio, nombre_parroquia)
);

-- Autor: Gabriel Bracho
-- Coordenadas como decimales primitivos (sin tipos espaciales del gestor).
CREATE TABLE ubicacion_geografica (
    id_ubicacion_geografica     NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_ubicacion_geografica'),
    latitud                     NUMERIC(8,6)    NOT NULL,
    longitud                    NUMERIC(9,6)    NOT NULL,
    elevacion_sobre_nivel_mar   NUMERIC(7,2)    NOT NULL,   -- metros
    altura_dentro_estructura    NUMERIC(6,2)    NOT NULL,   -- metros
    CONSTRAINT pk_ubicacion_geografica PRIMARY KEY (id_ubicacion_geografica),
    CONSTRAINT uq_ubicacion_geografica_clave
        UNIQUE (latitud, longitud, elevacion_sobre_nivel_mar, altura_dentro_estructura),
    -- [RR-02] Latitud en [-90, 90], longitud en [-180, 180], altura no negativa.
    CONSTRAINT chk_ubicacion_latitud  CHECK (latitud  BETWEEN  -90 AND  90),
    CONSTRAINT chk_ubicacion_longitud CHECK (longitud BETWEEN -180 AND 180),
    CONSTRAINT chk_ubicacion_altura   CHECK (altura_dentro_estructura >= 0)
);

-- Autor: Diego Mirabal
CREATE TABLE horario (
    id_horario                  NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_horario'),
    dia_semana                  VARCHAR(10)     NOT NULL,
    hora_apertura               TIMESTAMP       NOT NULL,
    hora_cierre                 TIMESTAMP       NOT NULL,
    CONSTRAINT pk_horario PRIMARY KEY (id_horario),
    CONSTRAINT uq_horario_clave UNIQUE (dia_semana, hora_apertura, hora_cierre),
    -- [RR-03] Dia de la semana valido y apertura anterior al cierre.
    CONSTRAINT chk_horario_dia_semana
        CHECK (dia_semana IN ('lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo')),
    CONSTRAINT chk_horario_apertura_cierre
        CHECK (hora_apertura < hora_cierre)
);

-- Autor: Gabriel Bracho
-- Ningun hito repite su nombre dentro de la misma parroquia (clave alterna).
CREATE TABLE hito (
    id_hito                     NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_hito'),
    id_parroquia                NUMERIC(10,0)   NOT NULL,
    nombre_hito                 VARCHAR(150)    NOT NULL,
    descripcion                 TEXT,
    estado_operativo            VARCHAR(25)     NOT NULL DEFAULT 'disponible',
    libre_acceso                BOOLEAN         NOT NULL,
    id_ubicacion_geografica     NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_hito PRIMARY KEY (id_hito),
    CONSTRAINT uq_hito_clave UNIQUE (id_parroquia, nombre_hito),
    -- [RR-04] Estado operativo del Hito.
    CONSTRAINT chk_hito_estado_operativo
        CHECK (estado_operativo IN ('disponible', 'en restauración',
                                    'clausurado temporalmente', 'cerrado permanentemente'))
);

-- Autor: Gabriel Bracho  (atributo multivaluado categoria de Hito)
CREATE TABLE hito_categoria (
    id_hito_categoria           NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_hito_categoria'),
    id_hito                     NUMERIC(10,0)   NOT NULL,
    categoria                   VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_hito_categoria PRIMARY KEY (id_hito_categoria),
    CONSTRAINT uq_hito_categoria_clave UNIQUE (id_hito, categoria)
);

-- Autor: Gabriel Bracho  (Hito - Horario)
CREATE TABLE cuenta_con (
    id_cuenta_con               NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_cuenta_con'),
    id_hito                     NUMERIC(10,0)   NOT NULL,
    id_horario                  NUMERIC(10,0)   NOT NULL,
    dia_especial                BOOLEAN         NOT NULL DEFAULT FALSE,
    fecha                       TIMESTAMP,
    CONSTRAINT pk_cuenta_con PRIMARY KEY (id_cuenta_con),
    CONSTRAINT uq_cuenta_con_clave UNIQUE (id_hito, id_horario),
    -- [RR-07] Un horario es de dia especial si y solo si indica la fecha.
    CONSTRAINT chk_cuenta_con_dia_especial
        CHECK (dia_especial = (fecha IS NOT NULL))
);


-- =============================================================================
-- VA-02. Cronogramas y actividades culturales
-- =============================================================================

-- Autor: Freddy Fernandez
CREATE TABLE cronograma (
    id_cronograma               NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_cronograma'),
    id_hito                     NUMERIC(10,0)   NOT NULL,
    nombre_cronograma           VARCHAR(100)    NOT NULL,
    fecha_inicio                TIMESTAMP       NOT NULL,
    fecha_fin                   TIMESTAMP       NOT NULL,
    estado_cronograma           VARCHAR(10)     NOT NULL DEFAULT 'Activo',
    CONSTRAINT pk_cronograma PRIMARY KEY (id_cronograma),
    CONSTRAINT uq_cronograma_clave UNIQUE (id_hito, nombre_cronograma, fecha_inicio),
    -- [RR-09] No termina antes de empezar; Activo o Finalizado.
    CONSTRAINT chk_cronograma_fechas CHECK (fecha_inicio <= fecha_fin),
    CONSTRAINT chk_cronograma_estado CHECK (estado_cronograma IN ('Activo', 'Finalizado'))
);

-- Autor: Freddy Fernandez
CREATE TABLE actividad (
    id_actividad                NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_actividad'),
    id_cronograma               NUMERIC(10,0)   NOT NULL,
    nombre_actividad            VARCHAR(100)    NOT NULL,
    fecha_act                   TIMESTAMP       NOT NULL,
    tipo_act                    VARCHAR(50)     NOT NULL,
    hora_inicio                 TIMESTAMP       NOT NULL,
    hora_fin                    TIMESTAMP       NOT NULL,
    cupo_maximo                 NUMERIC(6,0),
    costo_entrada               NUMERIC(10,2),
    estado_actividad            VARCHAR(10)     NOT NULL DEFAULT 'Activa',
    CONSTRAINT pk_actividad PRIMARY KEY (id_actividad),
    CONSTRAINT uq_actividad_clave UNIQUE (id_cronograma, nombre_actividad, fecha_act),
    -- [RR-10] Termina despues de empezar, cupo >= 1, costo >= 0, estado valido.
    CONSTRAINT chk_actividad_horas  CHECK (hora_inicio < hora_fin),
    CONSTRAINT chk_actividad_cupo   CHECK (cupo_maximo IS NULL OR cupo_maximo >= 1),
    CONSTRAINT chk_actividad_costo  CHECK (costo_entrada IS NULL OR costo_entrada >= 0),
    CONSTRAINT chk_actividad_estado CHECK (estado_actividad IN ('Activa', 'Cancelada', 'Finalizada'))
);


-- =============================================================================
-- MODULO 2. Recursos digitales y realidad aumentada
-- =============================================================================

-- Autor: Diego Mirabal
CREATE TABLE punto_geoespacial (
    id_punto_geoespacial        NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_punto_geoespacial'),
    id_hito                     NUMERIC(10,0)   NOT NULL,
    latitud                     NUMERIC(8,6)    NOT NULL,
    longitud                    NUMERIC(9,6)    NOT NULL,
    altitud_respecto_suelo      NUMERIC(7,2)    NOT NULL,   -- metros
    azimut                      NUMERIC(6,3)    NOT NULL,   -- grados
    inclinacion                 NUMERIC(5,3)    NOT NULL,   -- grados
    rotacion                    NUMERIC(6,3)    NOT NULL,   -- grados
    radio_efectivo              NUMERIC(8,2)    NOT NULL,   -- metros
    escala_visualizacion        NUMERIC(6,3)    NOT NULL,
    recurso_tridimensional      VARCHAR(255)    NOT NULL,   -- codigo/referencia del archivo
    CONSTRAINT pk_punto_geoespacial PRIMARY KEY (id_punto_geoespacial),
    CONSTRAINT uq_punto_geoespacial_clave
        UNIQUE (id_hito, latitud, longitud, altitud_respecto_suelo),
    -- [RR-14] Radio y escala positivos, azimut y rotacion en [0, 360), inclinacion en [-90, 90].
    CONSTRAINT chk_punto_radio       CHECK (radio_efectivo > 0),
    CONSTRAINT chk_punto_escala      CHECK (escala_visualizacion > 0),
    CONSTRAINT chk_punto_azimut      CHECK (azimut >= 0 AND azimut < 360),
    CONSTRAINT chk_punto_rotacion    CHECK (rotacion >= 0 AND rotacion < 360),
    CONSTRAINT chk_punto_inclinacion CHECK (inclinacion BETWEEN -90 AND 90)
);


-- =============================================================================
-- MODULO 9. Registro y perfiles de actores
-- =============================================================================

-- Autor: Diego Mirabal
CREATE TABLE perfil (
    id_perfil                   NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_perfil'),
    contrasena                  VARCHAR(50)     NOT NULL,   -- contrasena en texto plano (literal)
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil)
);

-- Autor: Gabriel Bracho
CREATE TABLE visitante (
    id_visitante                    NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_visitante'),
    cedula_pasaporte                VARCHAR(20)     NOT NULL,
    nombres                         VARCHAR(100)    NOT NULL,
    apellidos                       VARCHAR(100)    NOT NULL,
    pais_origen                     VARCHAR(60)     NOT NULL,
    idioma_nativo                   VARCHAR(40)     NOT NULL,
    telefono_emergencia             VARCHAR(20)     NOT NULL,
    grupo_sanguineo                 VARCHAR(3)      NOT NULL,
    especificaciones_accesibilidad  TEXT,
    estado_cuenta                   VARCHAR(8)      NOT NULL DEFAULT 'activo',
    id_perfil                       NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_visitante PRIMARY KEY (id_visitante),
    CONSTRAINT uq_visitante_clave UNIQUE (cedula_pasaporte),
    -- [RR-53] idPerfil es clave alterna de Visitante.
    CONSTRAINT uq_visitante_id_perfil UNIQUE (id_perfil),
    -- [RR-54] Activo o inactivo; grupo sanguineo ABO/Rh.
    CONSTRAINT chk_visitante_estado_cuenta
        CHECK (estado_cuenta IN ('activo', 'inactivo')),
    CONSTRAINT chk_visitante_grupo_sanguineo
        CHECK (grupo_sanguineo IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
);

-- Autor: Freddy Fernandez
CREATE TABLE guia (
    id_guia                     NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_guia'),
    rtn                         VARCHAR(20)     NOT NULL,
    codigo_licencia             VARCHAR(20)     NOT NULL,
    acreditacion                VARCHAR(100)    NOT NULL,
    anios_trayectoria           NUMERIC(3,0)    NOT NULL,
    tarifa_horaria              NUMERIC(10,2)   NOT NULL,
    id_perfil                   NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_guia PRIMARY KEY (id_guia),
    CONSTRAINT uq_guia_clave UNIQUE (rtn, codigo_licencia),
    -- [RR-55] idPerfil es clave alterna de Guia.
    CONSTRAINT uq_guia_id_perfil UNIQUE (id_perfil),
    -- [RR-56] Anios de trayectoria y tarifa horaria no negativos.
    CONSTRAINT chk_guia_anios_trayectoria CHECK (anios_trayectoria >= 0),
    CONSTRAINT chk_guia_tarifa_horaria    CHECK (tarifa_horaria >= 0)
);

-- Autor: Freddy Fernandez  (atributo multivaluado especialidad de Guia)
CREATE TABLE guia_especialidad (
    id_guia_especialidad        NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_guia_especialidad'),
    id_guia                     NUMERIC(10,0)   NOT NULL,
    especialidad                VARCHAR(60)     NOT NULL,
    CONSTRAINT pk_guia_especialidad PRIMARY KEY (id_guia_especialidad),
    CONSTRAINT uq_guia_especialidad_clave UNIQUE (id_guia, especialidad)
);

-- Autor: Freddy Fernandez  (atributo multivaluado idioma de Guia)
CREATE TABLE guia_idioma (
    id_guia_idioma              NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_guia_idioma'),
    id_guia                     NUMERIC(10,0)   NOT NULL,
    idioma                      VARCHAR(40)     NOT NULL,
    CONSTRAINT pk_guia_idioma PRIMARY KEY (id_guia_idioma),
    CONSTRAINT uq_guia_idioma_clave UNIQUE (id_guia, idioma)
);

-- Autor: Freddy Fernandez  (Guia - Municipio: zona geografica asignada)
CREATE TABLE trabaja (
    id_trabaja                  NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_trabaja'),
    id_guia                     NUMERIC(10,0)   NOT NULL,
    id_municipio                NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_trabaja PRIMARY KEY (id_trabaja),
    CONSTRAINT uq_trabaja_clave UNIQUE (id_guia, id_municipio)
);

-- Autor: Freddy Fernandez
CREATE TABLE comercio (
    id_comercio                 NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_comercio'),
    rif                         VARCHAR(15)     NOT NULL,
    razon_social                VARCHAR(150)    NOT NULL,
    categoria_comercial         VARCHAR(50)     NOT NULL,
    aforo                       NUMERIC(6,0)    NOT NULL,
    permiso_sanitario           VARCHAR(30)     NOT NULL,
    cuenta_bancaria             VARCHAR(20)     NOT NULL,
    id_ubicacion_geografica     NUMERIC(10,0)   NOT NULL,
    id_perfil                   NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_comercio PRIMARY KEY (id_comercio),
    CONSTRAINT uq_comercio_clave UNIQUE (rif),
    -- [RR-57] idPerfil y razonSocial son claves alternas de Comercio.
    CONSTRAINT uq_comercio_id_perfil    UNIQUE (id_perfil),
    CONSTRAINT uq_comercio_razon_social UNIQUE (razon_social),
    -- [RR-58] Aforo de al menos una persona.
    CONSTRAINT chk_comercio_aforo CHECK (aforo >= 1)
);

-- Autor: Freddy Fernandez  (Comercio - Horario: horario comercial)
CREATE TABLE disponible (
    id_disponible               NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_disponible'),
    id_comercio                 NUMERIC(10,0)   NOT NULL,
    id_horario                  NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_disponible PRIMARY KEY (id_disponible),
    CONSTRAINT uq_disponible_clave UNIQUE (id_comercio, id_horario)
);

-- Autor: Diego Mirabal
CREATE TABLE ente_publico (
    id_ente_publico             NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_ente_publico'),
    rif                         VARCHAR(15)     NOT NULL,
    denominacion                VARCHAR(150)    NOT NULL,
    nivel_territorial           VARCHAR(9)      NOT NULL,
    funcionario_enlace          VARCHAR(100)    NOT NULL,
    decreto_adscripcion         VARCHAR(150)    NOT NULL,
    id_perfil                   NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_ente_publico PRIMARY KEY (id_ente_publico),
    CONSTRAINT uq_ente_publico_clave UNIQUE (rif),
    -- [RR-59] idPerfil y denominacion son claves alternas de Ente_Publico.
    CONSTRAINT uq_ente_publico_id_perfil    UNIQUE (id_perfil),
    CONSTRAINT uq_ente_publico_denominacion UNIQUE (denominacion),
    -- [RR-60] Nivel territorial de competencia.
    CONSTRAINT chk_ente_nivel_territorial
        CHECK (nivel_territorial IN ('nacional', 'estadal', 'municipal'))
);

-- Autor: Diego Mirabal  (Ente_Publico - Municipio)
CREATE TABLE competencia (
    id_competencia              NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_competencia'),
    id_ente_publico             NUMERIC(10,0)   NOT NULL,
    id_municipio                NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_competencia PRIMARY KEY (id_competencia),
    CONSTRAINT uq_competencia_clave UNIQUE (id_ente_publico, id_municipio)
);


-- =============================================================================
-- VA-03. Administrador de datos maestros
-- =============================================================================

-- Autor: Diego Mirabal
CREATE TABLE administrador (
    id_administrador            NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_administrador'),
    cedula_pasaporte            VARCHAR(20)     NOT NULL,
    nombre                      VARCHAR(50)     NOT NULL,
    apellido                    VARCHAR(50)     NOT NULL,
    correo                      VARCHAR(150)    NOT NULL,
    id_perfil                   NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_administrador PRIMARY KEY (id_administrador),
    CONSTRAINT uq_administrador_clave UNIQUE (cedula_pasaporte),
    -- [RR-68] idPerfil es clave alterna de Administrador.
    CONSTRAINT uq_administrador_id_perfil UNIQUE (id_perfil)
);


-- =============================================================================
-- MODULO 3. Rutas turisticas e infraestructura vial
-- =============================================================================

-- Autor: Gabriel Bracho
-- id_visitante_creador NULL => ruta fija (expertos); NOT NULL => ruta dinamica.
CREATE TABLE ruta_turistica (
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_ruta_turistica'),
    id_municipio                NUMERIC(10,0)   NOT NULL,
    nombre_recorrido            VARCHAR(150)    NOT NULL,
    duracion                    NUMERIC(6,2)    NOT NULL,   -- horas estimadas
    nivel_dificultad            VARCHAR(20)     NOT NULL,
    recorridos_realizados       NUMERIC(10,0)   NOT NULL DEFAULT 0,
    preferencia_transporte      VARCHAR(30),
    hora_inicio                 TIMESTAMP,
    estado_ruta                 VARCHAR(8)      NOT NULL DEFAULT 'activa',
    id_visitante_creador        NUMERIC(10,0),
    CONSTRAINT pk_ruta_turistica PRIMARY KEY (id_ruta_turistica),
    CONSTRAINT uq_ruta_turistica_clave UNIQUE (id_municipio, nombre_recorrido),
    -- [RR-16] Activa o inactiva y duracion positiva.
    CONSTRAINT chk_ruta_estado   CHECK (estado_ruta IN ('activa', 'inactiva')),
    CONSTRAINT chk_ruta_duracion CHECK (duracion > 0),
    -- [RR-18] (parcial) No negativo; el valor exacto lo mantiene un trigger.
    CONSTRAINT chk_ruta_recorridos_realizados CHECK (recorridos_realizados >= 0)
);

-- Autor: Gabriel Bracho  (Ruta_Turistica - Hito)
CREATE TABLE conforma (
    id_conforma                 NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_conforma'),
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    id_hito                     NUMERIC(10,0)   NOT NULL,
    orden                       NUMERIC(4,0)    NOT NULL,
    CONSTRAINT pk_conforma PRIMARY KEY (id_conforma),
    CONSTRAINT uq_conforma_clave UNIQUE (id_ruta_turistica, id_hito),
    -- [RR-19] Posicion desde 1 y dos hitos de la ruta no comparten posicion.
    CONSTRAINT uq_conforma_orden UNIQUE (id_ruta_turistica, orden),
    CONSTRAINT chk_conforma_orden CHECK (orden >= 1)
);

-- Autor: Diego Mirabal
CREATE TABLE infraestructura_fisica (
    id_infraestructura_fisica   NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_infraestructura_fisica'),
    codigo_via                  VARCHAR(20)     NOT NULL,
    tipo_via                    VARCHAR(12)     NOT NULL,
    estado_via                  VARCHAR(15)     NOT NULL DEFAULT 'abierta',
    condicion_terreno           VARCHAR(100),
    desnivel                    NUMERIC(7,2),               -- metros
    CONSTRAINT pk_infraestructura_fisica PRIMARY KEY (id_infraestructura_fisica),
    CONSTRAINT uq_infraestructura_fisica_clave UNIQUE (codigo_via),
    -- [RR-20] Tipo y estado de la via.
    CONSTRAINT chk_via_tipo
        CHECK (tipo_via IN ('calle', 'avenida', 'bulevar', 'sendero', 'escalinata', 'puente')),
    CONSTRAINT chk_via_estado
        CHECK (estado_via IN ('abierta', 'cierre parcial', 'cierre total'))
);

-- Autor: Diego Mirabal  (atributo multivaluado modoPermitido de la via)
CREATE TABLE infraestructura_modo (
    id_infraestructura_modo     NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_infraestructura_modo'),
    id_infraestructura_fisica   NUMERIC(10,0)   NOT NULL,
    modo_permitido              VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_infraestructura_modo PRIMARY KEY (id_infraestructura_modo),
    CONSTRAINT uq_infraestructura_modo_clave UNIQUE (id_infraestructura_fisica, modo_permitido),
    -- [RR-22] Modos de recorrido permitidos.
    CONSTRAINT chk_infraestructura_modo
        CHECK (modo_permitido IN ('a pie', 'bicicleta', 'transporte público', 'vehículo adaptado'))
);

-- Autor: Diego Mirabal  (Ruta_Turistica - Infraestructura_Fisica)
CREATE TABLE se_despliega (
    id_se_despliega             NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_se_despliega'),
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    id_infraestructura_fisica   NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_se_despliega PRIMARY KEY (id_se_despliega),
    CONSTRAINT uq_se_despliega_clave UNIQUE (id_ruta_turistica, id_infraestructura_fisica)
);

-- Autor: Freddy Fernandez  (Guia - Ruta_Turistica)
CREATE TABLE sirve (
    id_sirve                    NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_sirve'),
    id_guia                     NUMERIC(10,0)   NOT NULL,
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_sirve PRIMARY KEY (id_sirve),
    CONSTRAINT uq_sirve_clave UNIQUE (id_guia, id_ruta_turistica)
);


-- =============================================================================
-- MODULO 4. Transporte multimodal y puntos de transbordo
-- =============================================================================

-- Autor: Diego Mirabal
CREATE TABLE parada_transporte (
    id_parada_transporte            NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_parada_transporte'),
    codigo_del_terminal             VARCHAR(20)     NOT NULL,
    nombre_parada                   VARCHAR(100)    NOT NULL,
    modalidad_transporte            VARCHAR(12)     NOT NULL,
    tarifa_basica                   NUMERIC(12,2),              -- moneda nacional
    nivel_adecuacion_discapacitados VARCHAR(30),
    estado_disponibilidad           VARCHAR(20)     NOT NULL DEFAULT 'activa',
    frecuencia_promedio_paso        NUMERIC(5,0),               -- minutos
    capacidad_max_zona_espera       NUMERIC(6,0),               -- personas
    id_ubicacion_geografica         NUMERIC(10,0)   NOT NULL,
    id_infraestructura_fisica       NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_parada_transporte PRIMARY KEY (id_parada_transporte),
    CONSTRAINT uq_parada_transporte_clave UNIQUE (codigo_del_terminal),
    -- [RR-24] Modalidad, estado, frecuencia > 0, capacidad >= 1 y tarifa >= 0.
    CONSTRAINT chk_parada_modalidad
        CHECK (modalidad_transporte IN ('metro', 'autobús', 'embarcadero', 'teleférico')),
    CONSTRAINT chk_parada_estado
        CHECK (estado_disponibilidad IN ('activa', 'en mantenimiento', 'fuera de servicio')),
    CONSTRAINT chk_parada_frecuencia CHECK (frecuencia_promedio_paso > 0),
    CONSTRAINT chk_parada_capacidad  CHECK (capacidad_max_zona_espera >= 1),
    CONSTRAINT chk_parada_tarifa     CHECK (tarifa_basica >= 0)
);

-- Autor: Diego Mirabal  (atributo multivaluado tipoEquipamiento de la parada)
CREATE TABLE equipamiento_urbano (
    id_equipamiento_urbano      NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_equipamiento_urbano'),
    id_parada_transporte        NUMERIC(10,0)   NOT NULL,
    tipo_equipamiento           VARCHAR(35)     NOT NULL,
    CONSTRAINT pk_equipamiento_urbano PRIMARY KEY (id_equipamiento_urbano),
    CONSTRAINT uq_equipamiento_urbano_clave UNIQUE (id_parada_transporte, tipo_equipamiento),
    -- [RR-26] Tipos de equipamiento urbano.
    CONSTRAINT chk_equipamiento_tipo
        CHECK (tipo_equipamiento IN ('techo o marquesina', 'iluminación nocturna', 'taquilla',
                                     'vigilancia permanente', 'estacionamiento de transferencia',
                                     'resguardo de bicicletas'))
);

-- Autor: Diego Mirabal  (Parada_Transporte - Horario)
CREATE TABLE funciona (
    id_funciona                 NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_funciona'),
    id_parada_transporte        NUMERIC(10,0)   NOT NULL,
    id_horario                  NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_funciona PRIMARY KEY (id_funciona),
    CONSTRAINT uq_funciona_clave UNIQUE (id_parada_transporte, id_horario)
);

-- Autor: Diego Mirabal  (Ruta_Turistica - Parada_Transporte)
CREATE TABLE usa (
    id_usa                      NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_usa'),
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    id_parada_transporte        NUMERIC(10,0)   NOT NULL,
    orden_parada                NUMERIC(4,0)    NOT NULL,
    CONSTRAINT pk_usa PRIMARY KEY (id_usa),
    CONSTRAINT uq_usa_clave UNIQUE (id_ruta_turistica, id_parada_transporte),
    -- [RR-27] Posicion desde 1 y dos paradas de la ruta no comparten posicion.
    CONSTRAINT uq_usa_orden_parada UNIQUE (id_ruta_turistica, orden_parada),
    CONSTRAINT chk_usa_orden_parada CHECK (orden_parada >= 1)
);

-- Autor: Diego Mirabal  (Parada_Transporte - Hito)
CREATE TABLE cercana (
    id_cercana                  NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_cercana'),
    id_parada_transporte        NUMERIC(10,0)   NOT NULL,
    id_hito                     NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_cercana PRIMARY KEY (id_cercana),
    CONSTRAINT uq_cercana_clave UNIQUE (id_parada_transporte, id_hito)
);


-- =============================================================================
-- MODULO 5. Comercio aliado y experiencias promocionales
-- =============================================================================

-- Autor: Freddy Fernandez
CREATE TABLE experiencia_turistica (
    id_experiencia_turistica    NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_experiencia_turistica'),
    titulo                      VARCHAR(150)    NOT NULL,
    fecha_activacion            TIMESTAMP       NOT NULL,
    descripcion                 TEXT,
    precio_total                NUMERIC(12,2)   NOT NULL,
    cupo_maximo_por_grupo       NUMERIC(4,0)    NOT NULL,
    porcentaje_descuento        NUMERIC(5,2)    NOT NULL,
    fecha_vencimiento           TIMESTAMP       NOT NULL,
    codigo_promocional          VARCHAR(30),
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    id_guia                     NUMERIC(10,0)   NOT NULL,
    id_comercio                 NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_experiencia_turistica PRIMARY KEY (id_experiencia_turistica),
    CONSTRAINT uq_experiencia_turistica_clave UNIQUE (titulo, fecha_activacion),
    -- [RR-29] Vencimiento posterior a la activacion, cupo >= 1, descuento en [0, 100].
    CONSTRAINT chk_experiencia_vigencia  CHECK (fecha_vencimiento > fecha_activacion),
    CONSTRAINT chk_experiencia_cupo      CHECK (cupo_maximo_por_grupo >= 1),
    CONSTRAINT chk_experiencia_descuento CHECK (porcentaje_descuento BETWEEN 0 AND 100)
);

-- Autor: Freddy Fernandez  (Experiencia_Turistica - Hito)
CREATE TABLE incluye (
    id_incluye                  NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_incluye'),
    id_experiencia_turistica    NUMERIC(10,0)   NOT NULL,
    id_hito                     NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_incluye PRIMARY KEY (id_incluye),
    CONSTRAINT uq_incluye_clave UNIQUE (id_experiencia_turistica, id_hito)
);


-- =============================================================================
-- MODULO 6. Credenciales digitales y control de acceso
-- =============================================================================

-- Autor: Gabriel Bracho
-- [RR-30] (todo o nada) queda garantizado al referenciar con una sola columna id.
CREATE TABLE credencial_digital (
    id_credencial_digital       NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_credencial_digital'),
    codigo_credencial           VARCHAR(20)     NOT NULL,
    fecha_credencial            TIMESTAMP       NOT NULL,
    hora_credencial             TIMESTAMP       NOT NULL,
    monto_abonado               NUMERIC(12,2)   NOT NULL,
    cantidad_beneficiarios      NUMERIC(4,0)    NOT NULL,
    estado_pase                 VARCHAR(9)      NOT NULL DEFAULT 'emitido',
    id_visitante                NUMERIC(10,0)   NOT NULL,
    id_hito                     NUMERIC(10,0),
    id_experiencia_turistica    NUMERIC(10,0),
    id_perfil_valida            NUMERIC(10,0),
    fecha_hora_canje            TIMESTAMP,
    CONSTRAINT pk_credencial_digital PRIMARY KEY (id_credencial_digital),
    CONSTRAINT uq_credencial_digital_clave UNIQUE (codigo_credencial),
    -- [RR-31] Corresponde a un hito o a una experiencia, exactamente a uno.
    CONSTRAINT chk_credencial_hito_xor_experiencia
        CHECK (num_nonnulls(id_hito, id_experiencia_turistica) = 1),
    -- [RR-33] Estado del pase, beneficiarios >= 1, monto >= 0.
    CONSTRAINT chk_credencial_estado
        CHECK (estado_pase IN ('emitido', 'canjeado', 'cancelado', 'vencido')),
    CONSTRAINT chk_credencial_beneficiarios CHECK (cantidad_beneficiarios >= 1),
    CONSTRAINT chk_credencial_monto         CHECK (monto_abonado >= 0),
    -- [RR-34] Validador nulo <-> sin fecha de canje; canjeado <-> tiene fecha de canje.
    CONSTRAINT chk_credencial_validador_canje
        CHECK ((id_perfil_valida IS NULL) = (fecha_hora_canje IS NULL)),
    CONSTRAINT chk_credencial_canjeado
        CHECK ((estado_pase = 'canjeado') = (fecha_hora_canje IS NOT NULL)),
    -- [RR-36] (parcial) El canje ocurre en la fecha programada; el horario del
    --         hito se valida con trigger.
    CONSTRAINT chk_credencial_fecha_canje
        CHECK (fecha_hora_canje IS NULL
               OR CAST(fecha_hora_canje AS DATE) = CAST(fecha_credencial AS DATE))
);


-- =============================================================================
-- MODULO 7. Reportes de incidencias en ruta y gestion institucional
-- =============================================================================

-- Autor: Freddy Fernandez
-- [RR-38] (todo o nada) queda garantizado al referenciar con una sola columna id.
CREATE TABLE reporte_ruta (
    id_reporte_ruta             NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_reporte_ruta'),
    numero_reporte              NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_numero_reporte'),
    fecha_deteccion             TIMESTAMP       NOT NULL,
    hora_deteccion              TIMESTAMP       NOT NULL,
    fecha_resolucion            TIMESTAMP,
    fecha_prorroga              TIMESTAMP,
    justificacion_prorroga      TEXT,
    narrativa_evento            TEXT            NOT NULL,
    estado_operativo            VARCHAR(10)     NOT NULL DEFAULT 'preliminar',
    nivel_severidad             VARCHAR(7)      NOT NULL,
    id_perfil_genera            NUMERIC(10,0)   NOT NULL,
    id_hito                     NUMERIC(10,0),
    id_infraestructura_fisica   NUMERIC(10,0),
    id_ente_verifica            NUMERIC(10,0),
    id_ente_cierra              NUMERIC(10,0),
    CONSTRAINT pk_reporte_ruta PRIMARY KEY (id_reporte_ruta),
    CONSTRAINT uq_reporte_ruta_clave UNIQUE (numero_reporte),
    -- [RR-39] Afecta a un hito o a un tramo de via, exactamente a uno.
    CONSTRAINT chk_reporte_hito_xor_via
        CHECK (num_nonnulls(id_hito, id_infraestructura_fisica) = 1),
    -- [RR-40] Severidad, estado y resolucion no anterior a la deteccion.
    CONSTRAINT chk_reporte_severidad
        CHECK (nivel_severidad IN ('bajo', 'medio', 'crítico')),
    CONSTRAINT chk_reporte_estado
        CHECK (estado_operativo IN ('preliminar', 'activo', 'resuelto')),
    CONSTRAINT chk_reporte_fecha_resolucion
        CHECK (fecha_resolucion IS NULL OR fecha_resolucion >= fecha_deteccion),
    -- [RR-41] La prorroga lleva justificacion y es posterior a la resolucion estimada.
    CONSTRAINT chk_reporte_prorroga_justificada
        CHECK ((fecha_prorroga IS NULL) = (justificacion_prorroga IS NULL)),
    CONSTRAINT chk_reporte_prorroga_fecha
        CHECK (fecha_prorroga IS NULL
               OR (fecha_resolucion IS NOT NULL AND fecha_prorroga > fecha_resolucion)),
    -- [RR-42] (parcial) Un reporte activo tiene fecha estimada de resolucion; que
    --         no haya vencido depende de la fecha actual (trigger/tarea programada).
    CONSTRAINT chk_reporte_activo_resolucion
        CHECK (estado_operativo <> 'activo' OR fecha_resolucion IS NOT NULL),
    -- [RR-45] Resuelto si y solo si un ente publico ejecuto su cierre.
    CONSTRAINT chk_reporte_resuelto_cierre
        CHECK ((estado_operativo = 'resuelto') = (id_ente_cierra IS NOT NULL))
);


-- =============================================================================
-- MODULO 8. Evaluaciones de experiencia y recorridos efectivos
-- =============================================================================

-- Autor: Gabriel Bracho  (Visitante - Ruta_Turistica)
CREATE TABLE recorrido (
    id_recorrido                NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_recorrido'),
    id_visitante                NUMERIC(10,0)   NOT NULL,
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    fecha_completado            TIMESTAMP,
    completado                  BOOLEAN         NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_recorrido PRIMARY KEY (id_recorrido),
    CONSTRAINT uq_recorrido_clave UNIQUE (id_visitante, id_ruta_turistica),
    -- [RR-46] Completado si y solo si tiene fecha de completado.
    CONSTRAINT chk_recorrido_completado
        CHECK (completado = (fecha_completado IS NOT NULL))
);

-- Autor: Gabriel Bracho  (Visitante - Hito: sello virtual)
CREATE TABLE paso (
    id_paso                     NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_paso'),
    id_visitante                NUMERIC(10,0)   NOT NULL,
    id_hito                     NUMERIC(10,0)   NOT NULL,
    fecha_paso                  TIMESTAMP       NOT NULL,
    hora_paso                   TIMESTAMP       NOT NULL,
    CONSTRAINT pk_paso PRIMARY KEY (id_paso),
    CONSTRAINT uq_paso_clave UNIQUE (id_visitante, id_hito)
);

-- Autor: Gabriel Bracho
-- [RR-48] (todo o nada) queda garantizado al referenciar con una sola columna id.
CREATE TABLE evaluacion_experiencia (
    id_evaluacion_experiencia   NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_evaluacion_experiencia'),
    codigo_resenia              VARCHAR(20)     NOT NULL,
    calificacion                NUMERIC(1,0)    NOT NULL,
    indice_seguridad            NUMERIC(1,0)    NOT NULL,
    fecha_emision               TIMESTAMP       NOT NULL,
    opinion                     TEXT,
    verificacion                BOOLEAN,
    estado_resenia              VARCHAR(22)     NOT NULL DEFAULT 'visible',
    id_visitante                NUMERIC(10,0)   NOT NULL,
    id_hito                     NUMERIC(10,0),
    id_ruta_turistica           NUMERIC(10,0),
    CONSTRAINT pk_evaluacion_experiencia PRIMARY KEY (id_evaluacion_experiencia),
    CONSTRAINT uq_evaluacion_experiencia_clave UNIQUE (codigo_resenia),
    -- [RR-49] Es sobre un hito o sobre una ruta, exactamente uno.
    CONSTRAINT chk_evaluacion_hito_xor_ruta
        CHECK (num_nonnulls(id_hito, id_ruta_turistica) = 1),
    -- [RR-50] Calificacion e indice de seguridad de 1 a 5; resena visible u oculta.
    CONSTRAINT chk_evaluacion_calificacion     CHECK (calificacion BETWEEN 1 AND 5),
    CONSTRAINT chk_evaluacion_indice_seguridad CHECK (indice_seguridad BETWEEN 1 AND 5),
    CONSTRAINT chk_evaluacion_estado_resenia
        CHECK (estado_resenia IN ('visible', 'oculta por moderación'))
);


-- =============================================================================
-- VA-01. Pasaporte turistico digital y reconocimiento de logros
-- =============================================================================

-- Autor: Gabriel Bracho
CREATE TABLE rango_explorador (
    id_rango_explorador         NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_rango_explorador'),
    nombre_rango                VARCHAR(50)     NOT NULL,
    sellos_minimos              NUMERIC(6,0)    NOT NULL,
    CONSTRAINT pk_rango_explorador PRIMARY KEY (id_rango_explorador),
    CONSTRAINT uq_rango_explorador_clave UNIQUE (nombre_rango),
    -- [RR-61] Sellos no negativos y dos rangos no exigen la misma cantidad.
    CONSTRAINT uq_rango_explorador_sellos UNIQUE (sellos_minimos),
    CONSTRAINT chk_rango_sellos_minimos CHECK (sellos_minimos >= 0)
);

-- Autor: Gabriel Bracho
CREATE TABLE pasaporte_turistico (
    id_pasaporte_turistico      NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_pasaporte_turistico'),
    codigo_pasaporte            VARCHAR(20)     NOT NULL,
    fecha_apertura              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_pasaporte            VARCHAR(8)      NOT NULL DEFAULT 'activo',
    id_visitante                NUMERIC(10,0)   NOT NULL,
    id_rango_explorador         NUMERIC(10,0),
    CONSTRAINT pk_pasaporte_turistico PRIMARY KEY (id_pasaporte_turistico),
    CONSTRAINT uq_pasaporte_turistico_clave UNIQUE (codigo_pasaporte),
    -- [RR-62] Un solo pasaporte por visitante.
    CONSTRAINT uq_pasaporte_visitante UNIQUE (id_visitante),
    -- [RR-63] (parcial) Activo o inactivo; la equivalencia con la cuenta del
    --         visitante se mantiene con trigger.
    CONSTRAINT chk_pasaporte_estado CHECK (estado_pasaporte IN ('activo', 'inactivo'))
);

-- Autor: Gabriel Bracho
-- [RR-65] (todo o nada) queda garantizado al referenciar con una sola columna id.
CREATE TABLE insignia_turistica (
    id_insignia_turistica       NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_insignia_turistica'),
    titulo_insignia             VARCHAR(100)    NOT NULL,
    descripcion                 TEXT            NOT NULL,
    icono                       VARCHAR(255)    NOT NULL,   -- referencia del recurso grafico
    tipo_regla                  VARCHAR(9)      NOT NULL,
    categoria_requerida         VARCHAR(50),
    cantidad_sellos             NUMERIC(6,0),
    id_ruta_turistica           NUMERIC(10,0),
    CONSTRAINT pk_insignia_turistica PRIMARY KEY (id_insignia_turistica),
    CONSTRAINT uq_insignia_turistica_clave UNIQUE (titulo_insignia),
    -- [RR-66] Por categoria: categoria y sellos >= 1, sin ruta.
    --         Por ruta: con ruta, sin categoria ni cantidad.
    CONSTRAINT chk_insignia_regla
        CHECK (
            (tipo_regla = 'categoría'
                AND categoria_requerida IS NOT NULL
                AND cantidad_sellos IS NOT NULL AND cantidad_sellos >= 1
                AND id_ruta_turistica IS NULL)
            OR
            (tipo_regla = 'ruta'
                AND id_ruta_turistica IS NOT NULL
                AND categoria_requerida IS NULL
                AND cantidad_sellos IS NULL)
        )
);

-- Autor: Gabriel Bracho  (Pasaporte_Turistico - Insignia_Turistica)
CREATE TABLE logro (
    id_logro                    NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_logro'),
    id_pasaporte_turistico      NUMERIC(10,0)   NOT NULL,
    id_insignia_turistica       NUMERIC(10,0)   NOT NULL,
    fecha_obtencion             TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_logro PRIMARY KEY (id_logro),
    CONSTRAINT uq_logro_clave UNIQUE (id_pasaporte_turistico, id_insignia_turistica)
);

-- Autor: Gabriel Bracho  (Visitante - Ruta_Turistica)
CREATE TABLE ruta_favorita (
    id_ruta_favorita            NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_ruta_favorita'),
    id_visitante                NUMERIC(10,0)   NOT NULL,
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    fecha_guardado              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ruta_favorita PRIMARY KEY (id_ruta_favorita),
    CONSTRAINT uq_ruta_favorita_clave UNIQUE (id_visitante, id_ruta_turistica)
);


-- =============================================================================
-- PROPIEDAD DE LAS SECUENCIAS (se eliminan junto con su columna)
-- =============================================================================

ALTER SEQUENCE seq_estado                 OWNED BY estado.id_estado;
ALTER SEQUENCE seq_municipio              OWNED BY municipio.id_municipio;
ALTER SEQUENCE seq_parroquia              OWNED BY parroquia.id_parroquia;
ALTER SEQUENCE seq_ubicacion_geografica   OWNED BY ubicacion_geografica.id_ubicacion_geografica;
ALTER SEQUENCE seq_horario                OWNED BY horario.id_horario;
ALTER SEQUENCE seq_hito                   OWNED BY hito.id_hito;
ALTER SEQUENCE seq_hito_categoria         OWNED BY hito_categoria.id_hito_categoria;
ALTER SEQUENCE seq_cuenta_con             OWNED BY cuenta_con.id_cuenta_con;
ALTER SEQUENCE seq_cronograma             OWNED BY cronograma.id_cronograma;
ALTER SEQUENCE seq_actividad              OWNED BY actividad.id_actividad;
ALTER SEQUENCE seq_punto_geoespacial      OWNED BY punto_geoespacial.id_punto_geoespacial;
ALTER SEQUENCE seq_perfil                 OWNED BY perfil.id_perfil;
ALTER SEQUENCE seq_visitante              OWNED BY visitante.id_visitante;
ALTER SEQUENCE seq_guia                   OWNED BY guia.id_guia;
ALTER SEQUENCE seq_guia_especialidad      OWNED BY guia_especialidad.id_guia_especialidad;
ALTER SEQUENCE seq_guia_idioma            OWNED BY guia_idioma.id_guia_idioma;
ALTER SEQUENCE seq_trabaja                OWNED BY trabaja.id_trabaja;
ALTER SEQUENCE seq_comercio               OWNED BY comercio.id_comercio;
ALTER SEQUENCE seq_disponible             OWNED BY disponible.id_disponible;
ALTER SEQUENCE seq_ente_publico           OWNED BY ente_publico.id_ente_publico;
ALTER SEQUENCE seq_competencia            OWNED BY competencia.id_competencia;
ALTER SEQUENCE seq_administrador          OWNED BY administrador.id_administrador;
ALTER SEQUENCE seq_ruta_turistica         OWNED BY ruta_turistica.id_ruta_turistica;
ALTER SEQUENCE seq_conforma               OWNED BY conforma.id_conforma;
ALTER SEQUENCE seq_infraestructura_fisica OWNED BY infraestructura_fisica.id_infraestructura_fisica;
ALTER SEQUENCE seq_infraestructura_modo   OWNED BY infraestructura_modo.id_infraestructura_modo;
ALTER SEQUENCE seq_se_despliega           OWNED BY se_despliega.id_se_despliega;
ALTER SEQUENCE seq_sirve                  OWNED BY sirve.id_sirve;
ALTER SEQUENCE seq_parada_transporte      OWNED BY parada_transporte.id_parada_transporte;
ALTER SEQUENCE seq_equipamiento_urbano    OWNED BY equipamiento_urbano.id_equipamiento_urbano;
ALTER SEQUENCE seq_funciona               OWNED BY funciona.id_funciona;
ALTER SEQUENCE seq_usa                    OWNED BY usa.id_usa;
ALTER SEQUENCE seq_cercana                OWNED BY cercana.id_cercana;
ALTER SEQUENCE seq_experiencia_turistica  OWNED BY experiencia_turistica.id_experiencia_turistica;
ALTER SEQUENCE seq_incluye                OWNED BY incluye.id_incluye;
ALTER SEQUENCE seq_credencial_digital     OWNED BY credencial_digital.id_credencial_digital;
ALTER SEQUENCE seq_reporte_ruta           OWNED BY reporte_ruta.id_reporte_ruta;
ALTER SEQUENCE seq_numero_reporte         OWNED BY reporte_ruta.numero_reporte;
ALTER SEQUENCE seq_recorrido              OWNED BY recorrido.id_recorrido;
ALTER SEQUENCE seq_paso                   OWNED BY paso.id_paso;
ALTER SEQUENCE seq_evaluacion_experiencia OWNED BY evaluacion_experiencia.id_evaluacion_experiencia;
ALTER SEQUENCE seq_rango_explorador       OWNED BY rango_explorador.id_rango_explorador;
ALTER SEQUENCE seq_pasaporte_turistico    OWNED BY pasaporte_turistico.id_pasaporte_turistico;
ALTER SEQUENCE seq_insignia_turistica     OWNED BY insignia_turistica.id_insignia_turistica;
ALTER SEQUENCE seq_logro                  OWNED BY logro.id_logro;
ALTER SEQUENCE seq_ruta_favorita          OWNED BY ruta_favorita.id_ruta_favorita;


-- =============================================================================
-- REGLAS PENDIENTES DE TRIGGERS / PROCEDIMIENTOS
-- Involucran varias tablas, agregados o la fecha actual, por lo que no se
-- pueden expresar con PRIMARY KEY, UNIQUE, FOREIGN KEY o CHECK:
--
--   RR-01  Todo Estado tiene al menos un municipio.
--   RR-05  Hito sin libre acceso tiene al menos un horario (Cuenta_Con).
--   RR-06  Todo Hito tiene al menos una categoria.
--   RR-08  Todo Cronograma tiene al menos una actividad.
--   RR-11  La fecha de la actividad esta dentro del periodo del cronograma.
--   RR-12  Ninguna actividad Activa si el hito esta clausurado/cerrado.
--   RR-13  Ninguna actividad Activa si el cronograma esta Finalizado.
--   RR-15  Toda ruta tiene al menos dos hitos y se despliega en al menos una via.
--   RR-17  Hitos y paradas de una ruta forman una sola secuencia 1..n.
--   RR-18  recorridos_realizados = recorridos completados de la ruta.
--   RR-21  Toda via tiene al menos un modo permitido.
--   RR-23  Toda parada tiene al menos un horario de funcionamiento.
--   RR-25  Parada sobre via con cierre total no puede estar 'activa'.
--   RR-28  Toda experiencia incluye al menos un hito.
--   RR-32  Credencial de hito solo si el hito no es de libre acceso.
--   RR-35  Solo comercio o guia valida; si es de experiencia, su guia o comercio.
--   RR-36  Canje dentro del horario del hito para ese dia.
--   RR-37  Credencial de experiencia: beneficiarios <= cupo y dentro de vigencia.
--   RR-42  Reporte activo con fecha de resolucion (o prorroga) no vencida.
--   RR-43  Solo visitante, guia o ente publico genera reportes.
--   RR-44  Reporte de visitante/guia preliminar <-> no verificado.
--   RR-47  Recorrido completado exige paso por cada hito de la ruta.
--   RR-51  Solo se evalua una ruta completada o un hito con paso registrado.
--   RR-52  Cada Perfil pertenece a exactamente un actor.
--   RR-62  Todo visitante tiene pasaporte (apertura automatica).
--   RR-63  Pasaporte inactivo <-> cuenta del visitante inactiva.
--   RR-64  Rango del pasaporte segun la cantidad de sellos.
--   RR-67  Logro <-> el visitante cumple la regla de la insignia.
--   RR-69  La cedula de un administrador no puede ser la de un visitante.
-- =============================================================================
