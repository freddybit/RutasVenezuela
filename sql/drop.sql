-- =============================================================================
-- RutasVenezuela - Plataforma de Rutas Turisticas y Culturales de Venezuela
-- Script: drop.sql  (PostgreSQL)
-- Contenido: elimina todas las tablas y secuencias del esquema, en orden inverso
--            de dependencias (primero las que referencian, luego las referidas).
--            CASCADE elimina tambien las claves foraneas creadas en alter.sql.
-- Orden de ejecucion: drop.sql -> create.sql -> alter.sql
-- =============================================================================

-- VA-01. Pasaporte turistico digital y reconocimiento de logros
DROP TABLE IF EXISTS ruta_favorita          CASCADE;
DROP TABLE IF EXISTS logro                  CASCADE;
DROP TABLE IF EXISTS insignia_turistica     CASCADE;
DROP TABLE IF EXISTS pasaporte_turistico    CASCADE;
DROP TABLE IF EXISTS rango_explorador       CASCADE;

-- Modulo 8. Evaluaciones de experiencia y recorridos efectivos
DROP TABLE IF EXISTS evaluacion_experiencia CASCADE;
DROP TABLE IF EXISTS paso                   CASCADE;
DROP TABLE IF EXISTS recorrido              CASCADE;

-- Modulo 7. Reportes de incidencias en ruta
DROP TABLE IF EXISTS reporte_ruta           CASCADE;

-- Modulo 6. Credenciales digitales
DROP TABLE IF EXISTS credencial_digital     CASCADE;

-- Modulo 5. Comercio aliado y experiencias promocionales
DROP TABLE IF EXISTS incluye                CASCADE;
DROP TABLE IF EXISTS experiencia_turistica  CASCADE;

-- Modulo 4. Transporte multimodal
DROP TABLE IF EXISTS cercana                CASCADE;
DROP TABLE IF EXISTS usa                    CASCADE;
DROP TABLE IF EXISTS funciona               CASCADE;
DROP TABLE IF EXISTS equipamiento_urbano    CASCADE;
DROP TABLE IF EXISTS parada_transporte      CASCADE;

-- Modulo 3. Rutas turisticas e infraestructura vial
DROP TABLE IF EXISTS sirve                  CASCADE;
DROP TABLE IF EXISTS se_despliega           CASCADE;
DROP TABLE IF EXISTS infraestructura_modo   CASCADE;
DROP TABLE IF EXISTS infraestructura_fisica CASCADE;
DROP TABLE IF EXISTS conforma               CASCADE;
DROP TABLE IF EXISTS ruta_turistica         CASCADE;

-- VA-03. Administrador de datos maestros
DROP TABLE IF EXISTS administrador          CASCADE;

-- Modulo 9. Registro y perfiles de actores
DROP TABLE IF EXISTS competencia            CASCADE;
DROP TABLE IF EXISTS ente_publico           CASCADE;
DROP TABLE IF EXISTS disponible             CASCADE;
DROP TABLE IF EXISTS comercio               CASCADE;
DROP TABLE IF EXISTS trabaja                CASCADE;
DROP TABLE IF EXISTS guia_idioma            CASCADE;
DROP TABLE IF EXISTS guia_especialidad      CASCADE;
DROP TABLE IF EXISTS guia                   CASCADE;
DROP TABLE IF EXISTS visitante              CASCADE;
DROP TABLE IF EXISTS perfil                 CASCADE;

-- Modulo 2. Recursos digitales y realidad aumentada
DROP TABLE IF EXISTS punto_geoespacial      CASCADE;

-- VA-02. Cronogramas y actividades culturales
DROP TABLE IF EXISTS actividad              CASCADE;
DROP TABLE IF EXISTS cronograma             CASCADE;

-- Modulo 1. Territorio, patrimonio e hitos urbanos
DROP TABLE IF EXISTS cuenta_con             CASCADE;
DROP TABLE IF EXISTS hito_categoria         CASCADE;
DROP TABLE IF EXISTS hito                   CASCADE;
DROP TABLE IF EXISTS horario                CASCADE;
DROP TABLE IF EXISTS ubicacion_geografica   CASCADE;
DROP TABLE IF EXISTS parroquia              CASCADE;
DROP TABLE IF EXISTS municipio              CASCADE;
DROP TABLE IF EXISTS estado                 CASCADE;

-- Secuencias (las OWNED BY ya caen con su tabla; se repiten por seguridad)
DROP SEQUENCE IF EXISTS seq_ruta_favorita;
DROP SEQUENCE IF EXISTS seq_logro;
DROP SEQUENCE IF EXISTS seq_insignia_turistica;
DROP SEQUENCE IF EXISTS seq_pasaporte_turistico;
DROP SEQUENCE IF EXISTS seq_rango_explorador;
DROP SEQUENCE IF EXISTS seq_evaluacion_experiencia;
DROP SEQUENCE IF EXISTS seq_paso;
DROP SEQUENCE IF EXISTS seq_recorrido;
DROP SEQUENCE IF EXISTS seq_reporte_ruta;
DROP SEQUENCE IF EXISTS seq_credencial_digital;
DROP SEQUENCE IF EXISTS seq_incluye;
DROP SEQUENCE IF EXISTS seq_experiencia_turistica;
DROP SEQUENCE IF EXISTS seq_cercana;
DROP SEQUENCE IF EXISTS seq_usa;
DROP SEQUENCE IF EXISTS seq_funciona;
DROP SEQUENCE IF EXISTS seq_equipamiento_urbano;
DROP SEQUENCE IF EXISTS seq_parada_transporte;
DROP SEQUENCE IF EXISTS seq_sirve;
DROP SEQUENCE IF EXISTS seq_se_despliega;
DROP SEQUENCE IF EXISTS seq_infraestructura_modo;
DROP SEQUENCE IF EXISTS seq_infraestructura_fisica;
DROP SEQUENCE IF EXISTS seq_conforma;
DROP SEQUENCE IF EXISTS seq_ruta_turistica;
DROP SEQUENCE IF EXISTS seq_administrador;
DROP SEQUENCE IF EXISTS seq_competencia;
DROP SEQUENCE IF EXISTS seq_ente_publico;
DROP SEQUENCE IF EXISTS seq_disponible;
DROP SEQUENCE IF EXISTS seq_comercio;
DROP SEQUENCE IF EXISTS seq_trabaja;
DROP SEQUENCE IF EXISTS seq_guia_idioma;
DROP SEQUENCE IF EXISTS seq_guia_especialidad;
DROP SEQUENCE IF EXISTS seq_guia;
DROP SEQUENCE IF EXISTS seq_visitante;
DROP SEQUENCE IF EXISTS seq_punto_geoespacial;
DROP SEQUENCE IF EXISTS seq_actividad;
DROP SEQUENCE IF EXISTS seq_cronograma;
DROP SEQUENCE IF EXISTS seq_cuenta_con;
DROP SEQUENCE IF EXISTS seq_hito_categoria;
DROP SEQUENCE IF EXISTS seq_hito;
DROP SEQUENCE IF EXISTS seq_horario;
DROP SEQUENCE IF EXISTS seq_ubicacion_geografica;
DROP SEQUENCE IF EXISTS seq_parroquia;
DROP SEQUENCE IF EXISTS seq_municipio;
DROP SEQUENCE IF EXISTS seq_estado;
DROP SEQUENCE IF EXISTS seq_numero_reporte;
DROP SEQUENCE IF EXISTS seq_perfil;
