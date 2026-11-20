-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: freddy_fernandez.sql  (PostgreSQL)
-- Autor: Freddy Fernandez
-- Contenido: secuencias, tablas y ALTER (propiedad de secuencias y claves
--            foraneas) de las tablas a cargo de este integrante.
-- Tablas (12): cronograma, actividad, guia, guia_especialidad, guia_idioma, trabaja, comercio, disponible, sirve, experiencia_turistica, incluye, reporte_ruta
--
-- Nota: las claves foraneas referencian tablas de otros integrantes; ejecutar
--       primero las SECUENCIAS y TABLAS de los tres archivos y luego sus
--       secciones ALTER.
-- Fuente: create.sql y alter.sql
-- =============================================================================

-- =============================================================================
-- SECUENCIAS
-- =============================================================================

CREATE SEQUENCE seq_cronograma              START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_actividad               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_guia                    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_guia_especialidad       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_guia_idioma             START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_trabaja                 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_comercio                START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_disponible              START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sirve                   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_experiencia_turistica   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_incluye                 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_reporte_ruta            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_numero_reporte          START WITH 1 INCREMENT BY 1;  -- numero_reporte (correlativo)


-- =============================================================================
-- TABLAS
-- =============================================================================

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
-- MODULO 9. Registro y perfiles de actores
-- =============================================================================

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


-- =============================================================================
-- MODULO 3. Rutas turisticas e infraestructura vial
-- =============================================================================

-- Autor: Freddy Fernandez  (Guia - Ruta_Turistica)
CREATE TABLE sirve (
    id_sirve                    NUMERIC(10,0)   NOT NULL DEFAULT nextval('seq_sirve'),
    id_guia                     NUMERIC(10,0)   NOT NULL,
    id_ruta_turistica           NUMERIC(10,0)   NOT NULL,
    CONSTRAINT pk_sirve PRIMARY KEY (id_sirve),
    CONSTRAINT uq_sirve_clave UNIQUE (id_guia, id_ruta_turistica)
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
-- ALTER
-- =============================================================================

-- =============================================================================
-- PROPIEDAD DE LAS SECUENCIAS (se eliminan junto con su columna)
-- =============================================================================

ALTER SEQUENCE seq_cronograma             OWNED BY cronograma.id_cronograma;
ALTER SEQUENCE seq_actividad              OWNED BY actividad.id_actividad;
ALTER SEQUENCE seq_guia                   OWNED BY guia.id_guia;
ALTER SEQUENCE seq_guia_especialidad      OWNED BY guia_especialidad.id_guia_especialidad;
ALTER SEQUENCE seq_guia_idioma            OWNED BY guia_idioma.id_guia_idioma;
ALTER SEQUENCE seq_trabaja                OWNED BY trabaja.id_trabaja;
ALTER SEQUENCE seq_comercio               OWNED BY comercio.id_comercio;
ALTER SEQUENCE seq_disponible             OWNED BY disponible.id_disponible;
ALTER SEQUENCE seq_sirve                  OWNED BY sirve.id_sirve;
ALTER SEQUENCE seq_experiencia_turistica  OWNED BY experiencia_turistica.id_experiencia_turistica;
ALTER SEQUENCE seq_incluye                OWNED BY incluye.id_incluye;
ALTER SEQUENCE seq_reporte_ruta           OWNED BY reporte_ruta.id_reporte_ruta;
ALTER SEQUENCE seq_numero_reporte         OWNED BY reporte_ruta.numero_reporte;


-- =============================================================================
-- CLAVES FORANEAS
-- =============================================================================

-- =============================================================================
-- VA-02. Cronogramas y actividades culturales
-- =============================================================================

ALTER TABLE cronograma
    ADD CONSTRAINT fk_cronograma_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito);

ALTER TABLE actividad
    ADD CONSTRAINT fk_actividad_cronograma
        FOREIGN KEY (id_cronograma) REFERENCES cronograma (id_cronograma)
        ON DELETE CASCADE;


-- =============================================================================
-- MODULO 9 / VA-03. Registro y perfiles de actores
-- =============================================================================

ALTER TABLE guia
    ADD CONSTRAINT fk_guia_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil (id_perfil);

ALTER TABLE guia_especialidad
    ADD CONSTRAINT fk_guia_especialidad_guia
        FOREIGN KEY (id_guia) REFERENCES guia (id_guia)
        ON DELETE CASCADE;

ALTER TABLE guia_idioma
    ADD CONSTRAINT fk_guia_idioma_guia
        FOREIGN KEY (id_guia) REFERENCES guia (id_guia)
        ON DELETE CASCADE;

ALTER TABLE trabaja
    ADD CONSTRAINT fk_trabaja_guia
        FOREIGN KEY (id_guia) REFERENCES guia (id_guia),
    ADD CONSTRAINT fk_trabaja_municipio
        FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio);

ALTER TABLE comercio
    ADD CONSTRAINT fk_comercio_ubicacion
        FOREIGN KEY (id_ubicacion_geografica) REFERENCES ubicacion_geografica (id_ubicacion_geografica),
    ADD CONSTRAINT fk_comercio_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil (id_perfil);

ALTER TABLE disponible
    ADD CONSTRAINT fk_disponible_comercio
        FOREIGN KEY (id_comercio) REFERENCES comercio (id_comercio)
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_disponible_horario
        FOREIGN KEY (id_horario) REFERENCES horario (id_horario);


-- =============================================================================
-- MODULO 3. Rutas turisticas e infraestructura vial
-- =============================================================================

ALTER TABLE sirve
    ADD CONSTRAINT fk_sirve_guia
        FOREIGN KEY (id_guia) REFERENCES guia (id_guia),
    ADD CONSTRAINT fk_sirve_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica);


-- =============================================================================
-- MODULO 5. Comercio aliado y experiencias promocionales
-- =============================================================================

ALTER TABLE experiencia_turistica
    ADD CONSTRAINT fk_experiencia_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica),
    ADD CONSTRAINT fk_experiencia_guia
        FOREIGN KEY (id_guia) REFERENCES guia (id_guia),
    ADD CONSTRAINT fk_experiencia_comercio
        FOREIGN KEY (id_comercio) REFERENCES comercio (id_comercio);

ALTER TABLE incluye
    ADD CONSTRAINT fk_incluye_experiencia
        FOREIGN KEY (id_experiencia_turistica) REFERENCES experiencia_turistica (id_experiencia_turistica),
    ADD CONSTRAINT fk_incluye_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito);


-- =============================================================================
-- MODULO 7. Reportes de incidencias en ruta y gestion institucional
-- =============================================================================

ALTER TABLE reporte_ruta
    ADD CONSTRAINT fk_reporte_perfil_genera
        FOREIGN KEY (id_perfil_genera) REFERENCES perfil (id_perfil),
    ADD CONSTRAINT fk_reporte_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito),
    ADD CONSTRAINT fk_reporte_via
        FOREIGN KEY (id_infraestructura_fisica) REFERENCES infraestructura_fisica (id_infraestructura_fisica),
    ADD CONSTRAINT fk_reporte_ente_verifica
        FOREIGN KEY (id_ente_verifica) REFERENCES ente_publico (id_ente_publico),
    ADD CONSTRAINT fk_reporte_ente_cierra
        FOREIGN KEY (id_ente_cierra) REFERENCES ente_publico (id_ente_publico);


-- Seguridad logica de VA-02 (roles y privilegios, D-07/D-12): ver freddy_fernandez_seguridad.sql
