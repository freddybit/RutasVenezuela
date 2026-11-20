-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: alter.sql  (PostgreSQL)
-- Contenido: unicamente las claves foraneas. Todas referencian la clave
--            primaria sustituta (id_<tabla>) de la tabla referida.
--            ON DELETE CASCADE solo en atributos multivaluados, en Actividad
--            (borrado fisico junto con su Cronograma, [REQ-04]) y en
--            Ruta_Favorita. El resto usa NO ACTION porque el negocio aplica
--            borrado logico (regla 15).
-- Requiere: create.sql ejecutado previamente.
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
-- MODULO 2. Recursos digitales y realidad aumentada
-- =============================================================================

ALTER TABLE punto_geoespacial
    ADD CONSTRAINT fk_punto_geoespacial_hito
        FOREIGN KEY (id_hito) REFERENCES hito (id_hito);


-- =============================================================================
-- MODULO 9 / VA-03. Registro y perfiles de actores
-- =============================================================================

ALTER TABLE visitante
    ADD CONSTRAINT fk_visitante_perfil
        FOREIGN KEY (id_perfil) REFERENCES perfil (id_perfil);

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

ALTER TABLE infraestructura_modo
    ADD CONSTRAINT fk_infraestructura_modo_via
        FOREIGN KEY (id_infraestructura_fisica) REFERENCES infraestructura_fisica (id_infraestructura_fisica)
        ON DELETE CASCADE;

ALTER TABLE se_despliega
    ADD CONSTRAINT fk_se_despliega_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica),
    ADD CONSTRAINT fk_se_despliega_via
        FOREIGN KEY (id_infraestructura_fisica) REFERENCES infraestructura_fisica (id_infraestructura_fisica);

ALTER TABLE sirve
    ADD CONSTRAINT fk_sirve_guia
        FOREIGN KEY (id_guia) REFERENCES guia (id_guia),
    ADD CONSTRAINT fk_sirve_ruta
        FOREIGN KEY (id_ruta_turistica) REFERENCES ruta_turistica (id_ruta_turistica);


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
