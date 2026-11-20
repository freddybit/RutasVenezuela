-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: diego_mirabal.sql  (PostgreSQL)
-- Autor: Diego Mirabal
-- Contenido: secuencias, tablas y ALTER (propiedad de secuencias y claves
--            foraneas) de las tablas a cargo de este integrante.
-- Tablas (17): estado, municipio, parroquia, horario, punto_geoespacial, perfil, ente_publico, competencia, administrador, infraestructura_fisica, infraestructura_modo, se_despliega, parada_transporte, equipamiento_urbano, funciona, usa, cercana
--
-- Nota: las claves foraneas referencian tablas de otros integrantes; ejecutar
--       primero las SECUENCIAS y TABLAS de los tres archivos y luego sus
--       secciones ALTER.
-- Fuente: create.sql y alter.sql
-- =============================================================================

-- =============================================================================
-- SECUENCIAS
-- =============================================================================

CREATE SEQUENCE seq_estado                  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_municipio               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_parroquia               START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_horario                 START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_punto_geoespacial       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_perfil                  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ente_publico            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_competencia             START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_administrador           START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_infraestructura_fisica  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_infraestructura_modo    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_se_despliega            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_parada_transporte       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_equipamiento_urbano     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_funciona                START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_usa                     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cercana                 START WITH 1 INCREMENT BY 1;


-- =============================================================================
-- TABLAS
-- =============================================================================

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
-- ALTER
-- =============================================================================

-- =============================================================================
-- PROPIEDAD DE LAS SECUENCIAS (se eliminan junto con su columna)
-- =============================================================================

ALTER SEQUENCE seq_estado                 OWNED BY estado.id_estado;
ALTER SEQUENCE seq_municipio              OWNED BY municipio.id_municipio;
ALTER SEQUENCE seq_parroquia              OWNED BY parroquia.id_parroquia;
ALTER SEQUENCE seq_horario                OWNED BY horario.id_horario;
ALTER SEQUENCE seq_punto_geoespacial      OWNED BY punto_geoespacial.id_punto_geoespacial;
ALTER SEQUENCE seq_perfil                 OWNED BY perfil.id_perfil;
ALTER SEQUENCE seq_ente_publico           OWNED BY ente_publico.id_ente_publico;
ALTER SEQUENCE seq_competencia            OWNED BY competencia.id_competencia;
ALTER SEQUENCE seq_administrador          OWNED BY administrador.id_administrador;
ALTER SEQUENCE seq_infraestructura_fisica OWNED BY infraestructura_fisica.id_infraestructura_fisica;
ALTER SEQUENCE seq_infraestructura_modo   OWNED BY infraestructura_modo.id_infraestructura_modo;
ALTER SEQUENCE seq_se_despliega           OWNED BY se_despliega.id_se_despliega;
ALTER SEQUENCE seq_parada_transporte      OWNED BY parada_transporte.id_parada_transporte;
ALTER SEQUENCE seq_equipamiento_urbano    OWNED BY equipamiento_urbano.id_equipamiento_urbano;
ALTER SEQUENCE seq_funciona               OWNED BY funciona.id_funciona;
ALTER SEQUENCE seq_usa                    OWNED BY usa.id_usa;
ALTER SEQUENCE seq_cercana                OWNED BY cercana.id_cercana;


-- =============================================================================
-- CLAVES FORANEAS
-- =============================================================================

-- =============================================================================
-- MODULO 1. Territorio, patrimonio e hitos urbanos
-- =============================================================================

ALTER TABLE municipio
    ADD CONSTRAINT fk_municipio_estado
        FOREIGN KEY (id_estado) REFERENCES estado (id_estado);

ALTER TABLE parroquia
    ADD CONSTRAINT fk_parroquia_municipio
        FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio);


-- =============================================================================
-- MODULO 2. Recursos digitales y realidad aumentada
-- =============================================================================

ALTER TABLE punto_geoespacial
    ADD CONSTRAINT fk_punto_geoespacial_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito);


-- =============================================================================
-- MODULO 9 / VA-03. Registro y perfiles de actores
-- =============================================================================

ALTER TABLE ente_publico
    ADD CONSTRAINT fk_ente_publico_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil (id_perfil);

ALTER TABLE competencia
    ADD CONSTRAINT fk_competencia_ente_publico
        FOREIGN KEY (id_ente_publico) REFERENCES ente_publico (id_ente_publico),
    ADD CONSTRAINT fk_competencia_municipio
        FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio);

ALTER TABLE administrador
    ADD CONSTRAINT fk_administrador_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil (id_perfil);


-- =============================================================================
-- MODULO 3. Rutas turisticas e infraestructura vial
-- =============================================================================

ALTER TABLE infraestructura_modo
    ADD CONSTRAINT fk_infraestructura_modo_via
        FOREIGN KEY (id_infraestructura_fisica) REFERENCES infraestructura_fisica (id_infraestructura_fisica)
        ON DELETE CASCADE;

ALTER TABLE se_despliega
    ADD CONSTRAINT fk_se_despliega_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica),
    ADD CONSTRAINT fk_se_despliega_via
        FOREIGN KEY (id_infraestructura_fisica) REFERENCES infraestructura_fisica (id_infraestructura_fisica);


-- =============================================================================
-- MODULO 4. Transporte multimodal y puntos de transbordo
-- =============================================================================

ALTER TABLE parada_transporte
    ADD CONSTRAINT fk_parada_ubicacion
        FOREIGN KEY (id_ubicacion_geografica) REFERENCES ubicacion_geografica (id_ubicacion_geografica),
    ADD CONSTRAINT fk_parada_via
        FOREIGN KEY (id_infraestructura_fisica) REFERENCES infraestructura_fisica (id_infraestructura_fisica);

ALTER TABLE equipamiento_urbano
    ADD CONSTRAINT fk_equipamiento_parada
        FOREIGN KEY (id_parada_transporte) REFERENCES parada_transporte (id_parada_transporte)
        ON DELETE CASCADE;

ALTER TABLE funciona
    ADD CONSTRAINT fk_funciona_parada
        FOREIGN KEY (id_parada_transporte) REFERENCES parada_transporte (id_parada_transporte)
        ON DELETE CASCADE,
    ADD CONSTRAINT fk_funciona_horario
        FOREIGN KEY (id_horario) REFERENCES horario (id_horario);

ALTER TABLE usa
    ADD CONSTRAINT fk_usa_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica),
    ADD CONSTRAINT fk_usa_parada
        FOREIGN KEY (id_parada_transporte) REFERENCES parada_transporte (id_parada_transporte);

ALTER TABLE cercana
    ADD CONSTRAINT fk_cercana_parada
        FOREIGN KEY (id_parada_transporte) REFERENCES parada_transporte (id_parada_transporte),
    ADD CONSTRAINT fk_cercana_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito);
