-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: freddy_fernandez_seguridad.sql  (PostgreSQL)
-- Autor: Freddy Fernandez
-- Contenido: SEGURIDAD LOGICA de VA-02 Cronogramas y actividades culturales
--            (D-07, D-12): roles de grupo por actor y privilegios de minimo
--            privilegio sobre cronograma, actividad, sus secuencias y las
--            funciones de freddy_fernandez_triggers.sql.
--
-- Orden de ejecucion: create.sql -> alter.sql -> insert.sql ->
--                     freddy_fernandez_triggers.sql -> este script
-- (docker-compose.yml lo monta como 05_freddy_fernandez_seguridad.sql)
--
-- Roles de grupo (NOLOGIN) por actor de la plataforma y privilegios de minimo
-- privilegio sobre las tablas, secuencias y funciones de VA-02:
--
--   Rol               cronograma / actividad     seq_*     fn_finalizar_cronogramas_vencidos
--   ----------------  -------------------------  --------  ---------------------------------
--   rv_administrador  SELECT INSERT UPDATE DELETE  USAGE    EXECUTE
--   rv_ente_publico   SELECT INSERT UPDATE DELETE  USAGE    -
--   rv_visitante      SELECT                       -        -
--   rv_guia           SELECT                       -        -
--   rv_comercio       SELECT                       -        -
--   rv_app            SELECT INSERT UPDATE DELETE  USAGE    EXECUTE   (rol de la API)
--
-- [REQ-04] Lectura para todos los actores; registro, modificacion,
-- cancelacion y borrado solo para el administrador y el ente publico
-- patrimonial. La vigencia (fn_finalizar_cronogramas_vencidos) la ejecutan el
-- administrador y la aplicacion (tarea diaria). Las funciones de trigger no
-- se invocan directamente: se revoca EXECUTE a PUBLIC (PostgreSQL solo exige
-- ese privilegio al crear el trigger, no al dispararlo).
--
-- Los usuarios con LOGIN se crean aparte y se agregan al rol que corresponda,
-- sin escribir contrasenas en este script. Por ejemplo:
--   CREATE ROLE rutas_api LOGIN PASSWORD '...' IN ROLE rv_app;
--
-- Idempotente: se puede ejecutar varias veces. Las funciones viven en
-- freddy_fernandez_triggers.sql; si aun no existen, sus privilegios se omiten
-- con un NOTICE y basta con volver a ejecutar este script despues de cargarlas.
--
-- Dependencias de otros modulos (las otorga el autor de cada tabla siguiendo
-- este mismo patron): los triggers de VA-02 se ejecutan con los privilegios
-- de quien modifica la fila, por lo que rv_administrador, rv_ente_publico y
-- rv_app necesitan SELECT sobre hito (fn_actividad_validar), y quien actualice
-- hito.estado_operativo necesita UPDATE sobre actividad
-- (fn_hito_cancelar_actividades).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Roles de grupo por actor
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    v_rol TEXT;
BEGIN
    FOREACH v_rol IN ARRAY ARRAY['rv_administrador', 'rv_ente_publico', 'rv_visitante',
                                 'rv_guia', 'rv_comercio', 'rv_app']
    LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_rol) THEN
            EXECUTE format('CREATE ROLE %I NOLOGIN', v_rol);
        END IF;
    END LOOP;
END;
$$;

-- -----------------------------------------------------------------------------
-- Tablas: lectura para todos los actores, escritura solo administrador,
-- ente publico y la aplicacion. Sin TRUNCATE, REFERENCES ni TRIGGER.
-- -----------------------------------------------------------------------------
REVOKE ALL ON TABLE cronograma, actividad FROM PUBLIC;

GRANT SELECT ON TABLE cronograma, actividad
    TO rv_administrador, rv_ente_publico, rv_visitante, rv_guia, rv_comercio, rv_app;

GRANT INSERT, UPDATE, DELETE ON TABLE cronograma, actividad
    TO rv_administrador, rv_ente_publico, rv_app;

-- -----------------------------------------------------------------------------
-- Secuencias: USAGE (nextval) solo para quien inserta.
-- -----------------------------------------------------------------------------
REVOKE ALL ON SEQUENCE seq_cronograma, seq_actividad FROM PUBLIC;

GRANT USAGE ON SEQUENCE seq_cronograma, seq_actividad
    TO rv_administrador, rv_ente_publico, rv_app;

-- -----------------------------------------------------------------------------
-- Funciones de freddy_fernandez_triggers.sql
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    v_fn TEXT;
BEGIN
    -- Funciones de trigger: nadie las invoca directamente.
    FOREACH v_fn IN ARRAY ARRAY['fn_actividad_validar()',
                                'fn_cronograma_validar_periodo()',
                                'fn_cronograma_finalizar_actividades()',
                                'fn_hito_cancelar_actividades()',
                                'fn_cronograma_tiene_actividades()']
    LOOP
        IF to_regprocedure(v_fn) IS NOT NULL THEN
            EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC', v_fn);
        ELSE
            RAISE NOTICE 'Seguridad VA-02: % no existe; ejecute freddy_fernandez_triggers.sql y repita este script', v_fn;
        END IF;
    END LOOP;

    -- Vigencia: solo el administrador y la aplicacion.
    IF to_regprocedure('fn_finalizar_cronogramas_vencidos()') IS NOT NULL THEN
        REVOKE ALL ON FUNCTION fn_finalizar_cronogramas_vencidos() FROM PUBLIC;
        GRANT EXECUTE ON FUNCTION fn_finalizar_cronogramas_vencidos() TO rv_administrador, rv_app;
    ELSE
        RAISE NOTICE 'Seguridad VA-02: fn_finalizar_cronogramas_vencidos() no existe; ejecute freddy_fernandez_triggers.sql y repita este script';
    END IF;
END;
$$;
