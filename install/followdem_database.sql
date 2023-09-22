--
-- PostgreSQL database
--


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: followdem; Type: SCHEMA; Schema: -; Owner: followdem
--

CREATE SCHEMA followdem;


------------
-- TABLES --
------------

--
-- Name: cor_animal_attributes; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.cor_animal_attributes (
    id_cor_an_att serial NOT NULL,
    id_attribute integer,
    id_animal integer,
    value character varying(120)
);

COMMENT ON TABLE followdem.cor_animal_attributes IS 'Table de correspondance entre un animal et ses attributs';


--
-- Name: cor_animal_devices; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.cor_animal_devices (
    id_cor_ad serial NOT NULL,
    id_animal integer,
    id_device integer,
    date_start timestamp without time zone,
    date_end timestamp without time zone,
    comment text
);

COMMENT ON TABLE followdem.cor_animal_devices IS 'Table de correspondance entre un animal et ses devices';


--
-- Name: t_animals; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.t_animals (
    id_animal serial NOT NULL,
    name character varying(50) NOT NULL,
    id_espece integer NOT NULL,
    birth_year integer,
    capture_date timestamp without time zone,
    death_date timestamp without time zone,
    comment text,
    active BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE followdem.t_animals IS 'Table contenant les animaux';

--
-- Name: t_especes; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.t_especes (
    id_espece serial NOT NULL,
    cd_nom integer,
    lb_nom character varying(50),
    nom_vern character varying(50),
    lien_img text,
    lien_fiche text
);

COMMENT ON TABLE followdem.t_especes IS 'Table contenant les especes';

--
-- Name: lib_attributes; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.lib_attributes (
    id_attribute serial NOT NULL,
    attribute character varying(50) NOT NULL,
    value_list text,
    attribute_type character varying(50),
    "order" integer
);

COMMENT ON TABLE followdem.lib_attributes IS 'Table listant les attributs et leurs valeurs associées';

--
-- Name: lib_device_type; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.lib_device_type (
    id_device_type serial NOT NULL,
    device_type character varying(50) NOT NULL
);

COMMENT ON TABLE followdem.lib_device_type IS 'Table listant les types de device';

--
-- Name: t_devices; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.t_devices (
    id_device serial NOT NULL,
    ref_device character varying(50) NOT NULL,
    id_device_type integer NOT NULL,
    comment text
);

COMMENT ON TABLE followdem.t_devices IS 'Table listant les devices';

--
-- Name: t_gps_data; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.t_gps_data (
    id_gps_data serial NOT NULL,
    id_device integer NOT NULL,
    gps_date timestamp without time zone,
    ttf integer,
    temperature decimal,
    sat_number integer,
    hdop decimal,
    latitude decimal,
    longitude decimal,
    altitude decimal,
    dimension character varying(50),
    accurate boolean DEFAULT true
);

COMMENT ON TABLE followdem.t_gps_data IS 'Table listant les données GPS d\un device';

--
-- Name: t_logs; Type: TABLE; Schema: followdem; Owner: followdem
--

CREATE TABLE followdem.t_logs (
    id_log serial NOT NULL,
    date timestamp without time zone,
    log timestamp without time zone
);

-----------------
-- PRIMARY KEY --
-----------------


ALTER TABLE ONLY followdem.cor_animal_attributes
    ADD CONSTRAINT cor_animal_attributes_pkey PRIMARY KEY (id_cor_an_att);

ALTER TABLE ONLY followdem.cor_animal_devices
    ADD CONSTRAINT cor_animal_devices_pkey PRIMARY KEY (id_cor_ad);

ALTER TABLE ONLY followdem.t_animals
    ADD CONSTRAINT t_animals_pkey PRIMARY KEY (id_animal);

ALTER TABLE ONLY followdem.t_especes
    ADD CONSTRAINT t_especes_pkey PRIMARY KEY (id_espece);

ALTER TABLE ONLY followdem.lib_attributes
    ADD CONSTRAINT lib_attributes_pkey PRIMARY KEY (id_attribute);

ALTER TABLE ONLY followdem.lib_device_type
    ADD CONSTRAINT lib_device_type_pkey PRIMARY KEY (id_device_type);

ALTER TABLE ONLY followdem.t_devices
    ADD CONSTRAINT t_devices_pkey PRIMARY KEY (id_device);

ALTER TABLE ONLY followdem.t_gps_data
    ADD CONSTRAINT t_gps_data_pkey PRIMARY KEY (id_gps_data);

ALTER TABLE ONLY followdem.t_logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id_log);




------------------
-- UNIQUE INDEX --
------------------
CREATE UNIQUE INDEX device_type_idx ON followdem.lib_device_type (LOWER(device_type));
CREATE UNIQUE INDEX attribute_idx ON followdem.lib_attributes (LOWER(attribute));
CREATE UNIQUE INDEX name_unique_idx ON followdem.t_animals (LOWER(name));
CREATE UNIQUE INDEX ref_device_unique_idx ON followdem.t_devices (LOWER(ref_device));
CREATE UNIQUE INDEX cd_nom_unique_idx ON followdem.t_especes (LOWER(cd_nom));


-----------------
-- FOREIGN KEY --
-----------------

ALTER TABLE ONLY followdem.t_animals
    ADD CONSTRAINT t_animals_id_espece_fkey FOREIGN KEY (id_espece) REFERENCES followdem.t_especes(id_espece);

ALTER TABLE ONLY followdem.cor_animal_attributes
    ADD CONSTRAINT cor_animal_attributes_id_animal_fkey FOREIGN KEY (id_animal) REFERENCES followdem.t_animals(id_animal);
ALTER TABLE ONLY followdem.cor_animal_attributes
    ADD CONSTRAINT animal_attributes_id_attribute_fkey FOREIGN KEY (id_attribute) REFERENCES followdem.lib_attributes(id_attribute);


ALTER TABLE ONLY followdem.cor_animal_devices
    ADD CONSTRAINT cor_animal_devices_id_animal_fkey FOREIGN KEY (id_animal) REFERENCES followdem.t_animals(id_animal);
ALTER TABLE ONLY followdem.cor_animal_devices
    ADD CONSTRAINT cor_animal_devices_id_device_fkey FOREIGN KEY (id_device) REFERENCES followdem.t_devices(id_device);


ALTER TABLE ONLY followdem.t_devices
    ADD CONSTRAINT t_devices_id_device_type_fkey FOREIGN KEY (id_device_type) REFERENCES followdem.lib_device_type(id_device_type);


ALTER TABLE ONLY followdem.t_gps_data
    ADD CONSTRAINT t_gps_data_id_device_fkey FOREIGN KEY (id_device) REFERENCES followdem.t_devices(id_device);


----------
-- VIEW --
----------

CREATE MATERIALIZED VIEW followdem.vm_animals_loc
TABLESPACE pg_default
AS WITH ranked_gps_data AS (
         SELECT tgd.id_gps_data,
            tgd.gps_date,
            st_setsrid(st_makepoint(tgd.longitude::double precision, tgd.latitude::double precision), 4326) AS geom,
            tgd.altitude,
            va.id_animal,
            va.name,
            va.nom_vern,
            va.attributs,
            row_number() OVER (PARTITION BY (va.name::text) ORDER BY tgd.gps_date) AS row_num
           FROM followdem.t_gps_data tgd
             JOIN followdem.cor_animal_devices cad ON cad.id_device = tgd.id_device AND tgd.gps_date >= cad.date_start AND tgd.gps_date <= COALESCE(cad.date_end::timestamp with time zone, now())
             JOIN followdem.v_animals va ON va.id_animal = cad.id_animal
          WHERE tgd.accurate IS TRUE AND (va.nom_vern::text <> 'Aigle royal'::text OR tgd.gps_date <= (now() - '30 days'::interval))
        )
 SELECT ranked_gps_data.id_gps_data,
    ranked_gps_data.gps_date,
    ranked_gps_data.geom,
    ranked_gps_data.altitude,
    ranked_gps_data.id_animal,
    ranked_gps_data.name,
    ranked_gps_data.nom_vern,
    ranked_gps_data.attributs
   FROM ranked_gps_data
  WHERE
        CASE
            WHEN ranked_gps_data.nom_vern::text = 'Aigle royal'::text THEN (ranked_gps_data.row_num % 4::bigint) = 1
            ELSE true
        END
  ORDER BY ranked_gps_data.name, ranked_gps_data.gps_date
WITH DATA;

-- View indexes:
CREATE INDEX idx_val_date ON followdem.vm_animals_loc USING btree (gps_date);
CREATE INDEX idx_val_geom ON followdem.vm_animals_loc USING gist (geom);
CREATE UNIQUE INDEX idx_val_id ON followdem.vm_animals_loc USING btree (id_gps_data);
CREATE INDEX idx_val_id_animal ON followdem.vm_animals_loc USING btree (id_animal);
CREATE INDEX idx_val_name ON followdem.vm_animals_loc USING btree (name);

CREATE OR REPLACE VIEW followdem.v_animals
AS SELECT ta.id_animal,
    ta.name,
    ta.id_espece,
    te.nom_vern,
    ta.birth_year,
    ta.capture_date,
    date_part('YEAR'::text, ta.capture_date)::integer AS capture_year,
    to_char(min(cad.date_start), 'DD/MM/YYYY'::text) AS date_debut_suivi,
    COALESCE(to_char(max(cad.date_end), 'DD/MM/YYYY'::text), to_char(ta.death_date, 'DD/MM/YYYY'::text)) AS date_fin_suivi,
    ta.comment,
    array_append(array_agg((la.attribute::text || ':'::text) || caa.value::text), 'fill: '::text || ('#'::text || lpad(to_hex(floor(random() * (256 * 256 * 256 - 1)::double precision)::integer), 6, '0'::text))) AS attributs
   FROM followdem.t_animals ta
     JOIN followdem.cor_animal_attributes caa ON ta.id_animal = caa.id_animal
     JOIN followdem.cor_animal_devices cad ON cad.id_animal = ta.id_animal
     JOIN followdem.lib_attributes la ON la.id_attribute = caa.id_attribute
     JOIN followdem.t_especes te ON te.id_espece = ta.id_espece
  GROUP BY ta.id_animal, ta.name, ta.id_espece, ta.birth_year, ta.capture_date, (date_part('YEAR'::text, ta.capture_date)), ta.death_date, ta.comment, te.nom_vern
  ORDER BY te.nom_vern, (COALESCE(to_char(max(cad.date_end), 'DD/MM/YYYY'::text), to_char(ta.death_date, 'DD/MM/YYYY'::text))) DESC, ta.name;