-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: freddy_fernandez_triggers.sql  (PostgreSQL / PL/pgSQL)
-- Autor: Freddy Fernandez
-- Contenido: reglas de integridad de VA-02 (Cronogramas y actividades
--            culturales) que no se pueden expresar con PK, UNIQUE, FK o CHECK.
--
--   RR-08  Todo Cronograma tiene al menos una actividad.
--   RR-11  La fecha de la actividad esta dentro del periodo del cronograma.
--   RR-12  Ninguna actividad Activa si el hito esta clausurado/cerrado.
--          Transicion automatica: si el hito pasa a clausurado temporalmente
--          o cerrado permanentemente, sus actividades Activa pasan a Cancelada.
--   RR-13  Ninguna actividad Activa si el cronograma esta Finalizado.
--          Transicion automatica: al finalizar un cronograma, sus actividades
--          Activa pasan a Finalizada.
--   Vigencia: fn_finalizar_cronogramas_vencidos() finaliza los cronogramas
--          cuya fecha de fin ya paso (la invoca el backend a diario).
--
-- Orden de ejecucion: create.sql -> alter.sql -> insert.sql -> este script
-- Todas las excepciones usan ERRCODE 'P0001' y un mensaje con el codigo de la
-- regla, para que la aplicacion pueda mostrarlo al usuario.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- RR-11 / RR-12 / RR-13: validaciones de cada actividad
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_actividad_validar()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_cronograma  cronograma%ROWTYPE;
    v_estado_hito hito.estado_operativo%TYPE;
BEGIN
    SELECT * INTO v_cronograma
      FROM cronograma
     WHERE id_cronograma = NEW.id_cronograma;

    -- RR-11: la fecha de la actividad esta dentro del periodo del cronograma.
    IF CAST(NEW.fecha_act AS DATE) NOT BETWEEN CAST(v_cronograma.fecha_inicio AS DATE)
                                           AND CAST(v_cronograma.fecha_fin AS DATE) THEN
        RAISE EXCEPTION 'RR-11: la fecha de la actividad (%) debe estar entre % y % (periodo del cronograma)',
            CAST(NEW.fecha_act AS DATE),
            CAST(v_cronograma.fecha_inicio AS DATE),
            CAST(v_cronograma.fecha_fin AS DATE)
            USING ERRCODE = 'P0001';
    END IF;

    -- Consistencia de horarios: inicio y fin ocurren el mismo dia de la actividad.
    IF CAST(NEW.hora_inicio AS DATE) <> CAST(NEW.fecha_act AS DATE)
       OR CAST(NEW.hora_fin AS DATE) <> CAST(NEW.fecha_act AS DATE) THEN
        RAISE EXCEPTION 'RR-10: la hora de inicio y la hora de fin deben corresponder al dia de la actividad'
            USING ERRCODE = 'P0001';
    END IF;

    IF NEW.estado_actividad = 'Activa' THEN
        -- RR-13: no hay actividades Activa en un cronograma Finalizado.
        IF v_cronograma.estado_cronograma = 'Finalizado' THEN
            RAISE EXCEPTION 'RR-13: el cronograma "%" esta Finalizado; no admite actividades activas',
                v_cronograma.nombre_cronograma
                USING ERRCODE = 'P0001';
        END IF;

        -- RR-12: no hay actividades Activa en un hito clausurado o cerrado.
        SELECT estado_operativo INTO v_estado_hito
          FROM hito
         WHERE id_hito = v_cronograma.id_hito;

        IF v_estado_hito IN ('clausurado temporalmente', 'cerrado permanentemente') THEN
            RAISE EXCEPTION 'RR-12: el hito esta % y no admite actividades activas', v_estado_hito
                USING ERRCODE = 'P0001';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_actividad_validar ON actividad;
CREATE TRIGGER trg_actividad_validar
    BEFORE INSERT OR UPDATE ON actividad
    FOR EACH ROW
    EXECUTE FUNCTION fn_actividad_validar();


-- -----------------------------------------------------------------------------
-- RR-11: al cambiar el periodo del cronograma, sus actividades siguen dentro
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_cronograma_validar_periodo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_fuera INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_fuera
      FROM actividad a
     WHERE a.id_cronograma = NEW.id_cronograma
       AND CAST(a.fecha_act AS DATE) NOT BETWEEN CAST(NEW.fecha_inicio AS DATE)
                                             AND CAST(NEW.fecha_fin AS DATE);

    IF v_fuera > 0 THEN
        RAISE EXCEPTION 'RR-11: % actividad(es) quedarian fuera del nuevo periodo del cronograma', v_fuera
            USING ERRCODE = 'P0001';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_cronograma_validar_periodo ON cronograma;
CREATE TRIGGER trg_cronograma_validar_periodo
    BEFORE UPDATE OF fecha_inicio, fecha_fin ON cronograma
    FOR EACH ROW
    EXECUTE FUNCTION fn_cronograma_validar_periodo();


-- -----------------------------------------------------------------------------
-- RR-13 (transicion): cronograma Finalizado -> actividades Activa a Finalizada
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_cronograma_finalizar_actividades()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.estado_cronograma = 'Finalizado' AND OLD.estado_cronograma <> 'Finalizado' THEN
        UPDATE actividad
           SET estado_actividad = 'Finalizada'
         WHERE id_cronograma = NEW.id_cronograma
           AND estado_actividad = 'Activa';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_cronograma_finalizar_actividades ON cronograma;
CREATE TRIGGER trg_cronograma_finalizar_actividades
    AFTER UPDATE OF estado_cronograma ON cronograma
    FOR EACH ROW
    EXECUTE FUNCTION fn_cronograma_finalizar_actividades();


-- -----------------------------------------------------------------------------
-- RR-12 (transicion): hito clausurado/cerrado -> actividades Activa a Cancelada
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_hito_cancelar_actividades()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.estado_operativo IN ('clausurado temporalmente', 'cerrado permanentemente')
       AND OLD.estado_operativo IS DISTINCT FROM NEW.estado_operativo THEN
        UPDATE actividad a
           SET estado_actividad = 'Cancelada'
          FROM cronograma c
         WHERE a.id_cronograma = c.id_cronograma
           AND c.id_hito = NEW.id_hito
           AND a.estado_actividad = 'Activa';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_hito_cancelar_actividades ON hito;
CREATE TRIGGER trg_hito_cancelar_actividades
    AFTER UPDATE OF estado_operativo ON hito
    FOR EACH ROW
    EXECUTE FUNCTION fn_hito_cancelar_actividades();


-- -----------------------------------------------------------------------------
-- RR-08: todo cronograma tiene al menos una actividad.
-- Se verifica al final de la transaccion (DEFERRABLE INITIALLY DEFERRED) para
-- permitir insertar el cronograma y luego sus actividades.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_cronograma_tiene_actividades()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_cronograma cronograma.id_cronograma%TYPE;
BEGIN
    IF TG_TABLE_NAME = 'cronograma' THEN
        v_id_cronograma := NEW.id_cronograma;
    ELSE
        v_id_cronograma := OLD.id_cronograma;
    END IF;

    -- Si el cronograma ya no existe (borrado en cascada) no hay nada que validar.
    IF EXISTS (SELECT 1 FROM cronograma WHERE id_cronograma = v_id_cronograma)
       AND NOT EXISTS (SELECT 1 FROM actividad WHERE id_cronograma = v_id_cronograma) THEN
        RAISE EXCEPTION 'RR-08: el cronograma % debe tener al menos una actividad', v_id_cronograma
            USING ERRCODE = 'P0001';
    END IF;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_cronograma_tiene_actividades ON cronograma;
CREATE CONSTRAINT TRIGGER trg_cronograma_tiene_actividades
    AFTER INSERT ON cronograma
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE FUNCTION fn_cronograma_tiene_actividades();

DROP TRIGGER IF EXISTS trg_actividad_cronograma_no_vacio ON actividad;
CREATE CONSTRAINT TRIGGER trg_actividad_cronograma_no_vacio
    AFTER DELETE OR UPDATE OF id_cronograma ON actividad
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE FUNCTION fn_cronograma_tiene_actividades();


-- -----------------------------------------------------------------------------
-- Vigencia: finaliza los cronogramas Activo cuya fecha de fin ya paso.
-- El trigger trg_cronograma_finalizar_actividades pasa sus actividades Activa
-- a Finalizada. Devuelve la cantidad de cronogramas finalizados.
-- Uso: SELECT fn_finalizar_cronogramas_vencidos();
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_finalizar_cronogramas_vencidos()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_cantidad INTEGER;
BEGIN
    UPDATE cronograma
       SET estado_cronograma = 'Finalizado'
     WHERE estado_cronograma = 'Activo'
       AND fecha_fin < LOCALTIMESTAMP;

    GET DIAGNOSTICS v_cantidad = ROW_COUNT;
    RETURN v_cantidad;
END;
$$;
