-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: gabriel_bracho.sql  (PostgreSQL)
-- Autor: Gabriel Bracho
-- Contenido: secuencias, tablas y ALTER (propiedad de secuencias y claves
--            foraneas) de las tablas a cargo de este integrante.
-- Tablas (16): ubicacion_geografica, hito, hito_categoria, cuenta_con, visitante, ruta_turistica, conforma, credencial_digital, recorrido, paso, evaluacion_experiencia, rango_explorador, pasaporte_turistico, insignia_turistica, logro, ruta_favorita
--
-- Nota: las claves foraneas referencian tablas de otros integrantes; ejecutar
--       primero las SECUENCIAS y TABLAS de los tres archivos y luego sus
--       secciones ALTER.
-- Fuente: create.sql y alter.sql
-- =============================================================================

-- =============================================================================
-- SECUENCIAS
-- =============================================================================

CREATE SEQUENCE seq_ubicacion_geografica    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hito                    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_hito_categoria          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cuenta_con              START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_visitante               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ruta_turistica          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_conforma                START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_credencial_digital      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_recorrido               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_paso                    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_evaluacion_experiencia  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_rango_explorador        START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_pasaporte_turistico     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_insignia_turistica      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_logro                   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ruta_favorita           START WITH 1 INCREMENT BY 1;


-- =============================================================================
-- TABLAS
-- =============================================================================

-- =============================================================================
-- MODULO 1. Territorio, patrimonio e hitos urbanos
-- =============================================================================

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
-- MODULO 9. Registro y perfiles de actores
-- =============================================================================

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
-- ALTER
-- =============================================================================

-- =============================================================================
-- PROPIEDAD DE LAS SECUENCIAS (se eliminan junto con su columna)
-- =============================================================================

ALTER SEQUENCE seq_ubicacion_geografica   OWNED BY ubicacion_geografica.id_ubicacion_geografica;
ALTER SEQUENCE seq_hito                   OWNED BY hito.id_hito;
ALTER SEQUENCE seq_hito_categoria         OWNED BY hito_categoria.id_hito_categoria;
ALTER SEQUENCE seq_cuenta_con             OWNED BY cuenta_con.id_cuenta_con;
ALTER SEQUENCE seq_visitante              OWNED BY visitante.id_visitante;
ALTER SEQUENCE seq_ruta_turistica         OWNED BY ruta_turistica.id_ruta_turistica;
ALTER SEQUENCE seq_conforma               OWNED BY conforma.id_conforma;
ALTER SEQUENCE seq_credencial_digital     OWNED BY credencial_digital.id_credencial_digital;
ALTER SEQUENCE seq_recorrido              OWNED BY recorrido.id_recorrido;
ALTER SEQUENCE seq_paso                   OWNED BY paso.id_paso;
ALTER SEQUENCE seq_evaluacion_experiencia OWNED BY evaluacion_experiencia.id_evaluacion_experiencia;
ALTER SEQUENCE seq_rango_explorador       OWNED BY rango_explorador.id_rango_explorador;
ALTER SEQUENCE seq_pasaporte_turistico    OWNED BY pasaporte_turistico.id_pasaporte_turistico;
ALTER SEQUENCE seq_insignia_turistica     OWNED BY insignia_turistica.id_insignia_turistica;
ALTER SEQUENCE seq_logro                  OWNED BY logro.id_logro;
ALTER SEQUENCE seq_ruta_favorita          OWNED BY ruta_favorita.id_ruta_favorita;


-- =============================================================================
-- CLAVES FORANEAS
-- =============================================================================

-- =============================================================================
-- MODULO 1. Territorio, patrimonio e hitos urbanos
-- =============================================================================

ALTER TABLE hito
    ADD CONSTRAINT fk_hito_parroquia
        FOREIGN KEY (id_parroquia) REFERENCES parroquia (id_parroquia),
    ADD CONSTRAINT fk_hito_ubicacion
        FOREIGN KEY (id_ubicacion_geografica) REFERENCES ubicacion_geografica (id_ubicacion_geografica);

ALTER TABLE hito_categoria
    ADD CONSTRAINT fk_hito_categoria_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito)
        ON DELETE CASCADE;

ALTER TABLE cuenta_con
    ADD CONSTRAINT fk_cuenta_con_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito)
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_cuenta_con_horario
        FOREIGN KEY (id_horario) REFERENCES horario (id_horario);


-- =============================================================================
-- MODULO 9 / VA-03. Registro y perfiles de actores
-- =============================================================================

ALTER TABLE visitante
    ADD CONSTRAINT fk_visitante_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil (id_perfil);


-- =============================================================================
-- MODULO 3. Rutas turisticas e infraestructura vial
-- =============================================================================

ALTER TABLE ruta_turistica
    ADD CONSTRAINT fk_ruta_turistica_municipio
        FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio),
    ADD CONSTRAINT fk_ruta_turistica_creador
        FOREIGN KEY (id_visitante_creador) REFERENCES visitante (id_visitante);

ALTER TABLE conforma
    ADD CONSTRAINT fk_conforma_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica),
    ADD CONSTRAINT fk_conforma_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito);


-- =============================================================================
-- MODULO 6. Credenciales digitales y control de acceso
-- =============================================================================

ALTER TABLE credencial_digital
    ADD CONSTRAINT fk_credencial_visitante
        FOREIGN KEY (id_visitante) REFERENCES visitante (id_visitante),
    ADD CONSTRAINT fk_credencial_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito),
    ADD CONSTRAINT fk_credencial_experiencia
        FOREIGN KEY (id_experiencia_turistica) REFERENCES experiencia_turistica (id_experiencia_turistica),
    ADD CONSTRAINT fk_credencial_perfil_valida
        FOREIGN KEY (id_perfil_valida) REFERENCES perfil (id_perfil);


-- =============================================================================
-- MODULO 8. Evaluaciones de experiencia y recorridos efectivos
-- =============================================================================

ALTER TABLE recorrido
    ADD CONSTRAINT fk_recorrido_visitante
        FOREIGN KEY (id_visitante) REFERENCES visitante (id_visitante),
    ADD CONSTRAINT fk_recorrido_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica);

ALTER TABLE paso
    ADD CONSTRAINT fk_paso_visitante
        FOREIGN KEY (id_visitante) REFERENCES visitante (id_visitante),
    ADD CONSTRAINT fk_paso_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito);

ALTER TABLE evaluacion_experiencia
    ADD CONSTRAINT fk_evaluacion_visitante
        FOREIGN KEY (id_visitante) REFERENCES visitante (id_visitante),
    ADD CONSTRAINT fk_evaluacion_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito),
    ADD CONSTRAINT fk_evaluacion_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica);


-- =============================================================================
-- VA-01. Pasaporte turistico digital y reconocimiento de logros
-- =============================================================================

ALTER TABLE pasaporte_turistico
    ADD CONSTRAINT fk_pasaporte_visitante
        FOREIGN KEY (id_visitante) REFERENCES visitante (id_visitante),
    ADD CONSTRAINT fk_pasaporte_rango
        FOREIGN KEY (id_rango_explorador) REFERENCES rango_explorador (id_rango_explorador);

ALTER TABLE insignia_turistica
    ADD CONSTRAINT fk_insignia_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica);

ALTER TABLE logro
    ADD CONSTRAINT fk_logro_pasaporte
        FOREIGN KEY (id_pasaporte_turistico) REFERENCES pasaporte_turistico (id_pasaporte_turistico),
    ADD CONSTRAINT fk_logro_insignia
        FOREIGN KEY (id_insignia_turistica) REFERENCES insignia_turistica (id_insignia_turistica);

ALTER TABLE ruta_favorita
    ADD CONSTRAINT fk_ruta_favorita_visitante
        FOREIGN KEY (id_visitante) REFERENCES visitante (id_visitante),
    ADD CONSTRAINT fk_ruta_favorita_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica)
        ON DELETE CASCADE;
