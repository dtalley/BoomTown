--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bases; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE bases (
    base_id integer NOT NULL,
    base_title character varying(60) NOT NULL,
    base_name character varying(60) NOT NULL,
    base_description text
);


ALTER TABLE public.bases OWNER TO dlboom;

--
-- Name: TABLE bases; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE bases IS 'Table for the different types of bases that a commander can control.';


--
-- Name: COLUMN bases.base_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN bases.base_id IS 'The base''s unique identifier.';


--
-- Name: COLUMN bases.base_title; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN bases.base_title IS 'The base''s title';


--
-- Name: COLUMN bases.base_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN bases.base_name IS 'A URL friendly version of the base''s title.';


--
-- Name: COLUMN bases.base_description; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN bases.base_description IS 'A description of the specific kind of base.';


--
-- Name: bases_base_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE bases_base_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bases_base_id_seq OWNER TO dlboom;

--
-- Name: bases_base_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE bases_base_id_seq OWNED BY bases.base_id;


--
-- Name: bases_base_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('bases_base_id_seq', 2, true);


--
-- Name: battle_commanders; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE battle_commanders (
    battle_id integer,
    commander_id integer,
    battle_commander_joined timestamp without time zone
);


ALTER TABLE public.battle_commanders OWNER TO dlboom;

--
-- Name: TABLE battle_commanders; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE battle_commanders IS 'Table holding associations between battles and commanders, indicating who is participating in which battle';


--
-- Name: COLUMN battle_commanders.battle_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN battle_commanders.battle_id IS 'The unique identifier for the battle';


--
-- Name: COLUMN battle_commanders.commander_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN battle_commanders.commander_id IS 'The unique identifier for the commander';


--
-- Name: COLUMN battle_commanders.battle_commander_joined; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN battle_commanders.battle_commander_joined IS 'The date and time the commander joined the battle';


--
-- Name: battles; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE battles (
    battle_id integer NOT NULL,
    zone_scenario_id integer NOT NULL,
    battle_start timestamp without time zone NOT NULL
);


ALTER TABLE public.battles OWNER TO dlboom;

--
-- Name: TABLE battles; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE battles IS 'Table holding all of the current and past battles.';


--
-- Name: COLUMN battles.battle_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN battles.battle_id IS 'Unique identifier for each battle';


--
-- Name: COLUMN battles.zone_scenario_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN battles.zone_scenario_id IS 'Unique identifier for the zone scenario this battle takes place within';


--
-- Name: COLUMN battles.battle_start; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN battles.battle_start IS 'The date and time this battle started';


--
-- Name: battles_battle_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE battles_battle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.battles_battle_id_seq OWNER TO dlboom;

--
-- Name: battles_battle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE battles_battle_id_seq OWNED BY battles.battle_id;


--
-- Name: battles_battle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('battles_battle_id_seq', 1, false);


--
-- Name: command_bases; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE command_bases (
    command_base_id integer NOT NULL,
    base_id smallint NOT NULL,
    commander_id bigint NOT NULL,
    command_base_acquired timestamp without time zone,
    command_base_active boolean,
    command_base_bandwidth smallint
);


ALTER TABLE public.command_bases OWNER TO dlboom;

--
-- Name: TABLE command_bases; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE command_bases IS 'Individual command bases operated by commanders.';


--
-- Name: COLUMN command_bases.command_base_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_bases.command_base_id IS 'The command base''s unique identifier.';


--
-- Name: COLUMN command_bases.base_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_bases.base_id IS 'Base id, links with the field from the bases table.';


--
-- Name: COLUMN command_bases.commander_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_bases.commander_id IS 'Commander id, links with the field from the commanders table.';


--
-- Name: COLUMN command_bases.command_base_acquired; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_bases.command_base_acquired IS 'Date and time the commander acquired the base';


--
-- Name: COLUMN command_bases.command_base_active; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_bases.command_base_active IS 'Shows if this base is the currently active base for the commander it belongs to';


--
-- Name: COLUMN command_bases.command_base_bandwidth; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_bases.command_base_bandwidth IS 'The number of battles this command center can support.';


--
-- Name: command_bases_command_base_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE command_bases_command_base_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.command_bases_command_base_id_seq OWNER TO dlboom;

--
-- Name: command_bases_command_base_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE command_bases_command_base_id_seq OWNED BY command_bases.command_base_id;


--
-- Name: command_bases_command_base_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('command_bases_command_base_id_seq', 9, true);


--
-- Name: command_factions; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE command_factions (
    command_faction_id integer NOT NULL,
    faction_id integer NOT NULL,
    commander_id integer NOT NULL,
    command_faction_joined timestamp without time zone NOT NULL,
    command_faction_active boolean,
    command_faction_dropship_max smallint,
    command_faction_dropships smallint
);


ALTER TABLE public.command_factions OWNER TO dlboom;

--
-- Name: TABLE command_factions; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE command_factions IS 'Table to keep track of a commander''s faction history.';


--
-- Name: COLUMN command_factions.command_faction_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_factions.command_faction_id IS 'Command faction id unique identifier';


--
-- Name: COLUMN command_factions.faction_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_factions.faction_id IS 'Faction id, links with the field in the factions table';


--
-- Name: COLUMN command_factions.commander_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_factions.commander_id IS 'Commander id, links with the field from the commanders table';


--
-- Name: COLUMN command_factions.command_faction_joined; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_factions.command_faction_joined IS 'Date and time the commander joined the faction';


--
-- Name: COLUMN command_factions.command_faction_active; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_factions.command_faction_active IS 'Shows if this faction is the currently active faction for the commander';


--
-- Name: COLUMN command_factions.command_faction_dropship_max; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_factions.command_faction_dropship_max IS 'The maximum number of dropship credits this faction can give to this commander';


--
-- Name: COLUMN command_factions.command_faction_dropships; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_factions.command_faction_dropships IS 'The number of faction dropship credits the faction currently has for the commander';


--
-- Name: command_factions_command_faction_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE command_factions_command_faction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.command_factions_command_faction_id_seq OWNER TO dlboom;

--
-- Name: command_factions_command_faction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE command_factions_command_faction_id_seq OWNED BY command_factions.command_faction_id;


--
-- Name: command_factions_command_faction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('command_factions_command_faction_id_seq', 7, true);


--
-- Name: command_ranks; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE command_ranks (
    command_rank_id integer NOT NULL,
    rank_id smallint NOT NULL,
    commander_id integer,
    command_rank_achieved timestamp without time zone,
    command_rank_active boolean
);


ALTER TABLE public.command_ranks OWNER TO dlboom;

--
-- Name: TABLE command_ranks; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE command_ranks IS 'Table for individual ranks achieved by commanders';


--
-- Name: COLUMN command_ranks.command_rank_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_ranks.command_rank_id IS 'Command rank unique identifier';


--
-- Name: COLUMN command_ranks.rank_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_ranks.rank_id IS 'Rank id, links with the field from the ranks table';


--
-- Name: COLUMN command_ranks.commander_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_ranks.commander_id IS 'Commander id, links with the field from the commanders table';


--
-- Name: COLUMN command_ranks.command_rank_achieved; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_ranks.command_rank_achieved IS 'The date and time this rank was achieved';


--
-- Name: COLUMN command_ranks.command_rank_active; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN command_ranks.command_rank_active IS 'Shows if this rank is the currently active rank for the commander';


--
-- Name: command_ranks_command_rank_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE command_ranks_command_rank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.command_ranks_command_rank_id_seq OWNER TO dlboom;

--
-- Name: command_ranks_command_rank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE command_ranks_command_rank_id_seq OWNED BY command_ranks.command_rank_id;


--
-- Name: command_ranks_command_rank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('command_ranks_command_rank_id_seq', 3, true);


--
-- Name: commanders; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE commanders (
    commander_id integer NOT NULL,
    user_id character(20) NOT NULL,
    commander_name character varying(70),
    commander_experience integer,
    commander_balance integer
);


ALTER TABLE public.commanders OWNER TO dlboom;

--
-- Name: TABLE commanders; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE commanders IS 'Table of Player''s Commanders, keeps track of their commander name, faction, and bank information.';


--
-- Name: COLUMN commanders.commander_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN commanders.commander_id IS 'Commander''s unique id';


--
-- Name: COLUMN commanders.user_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN commanders.user_id IS 'User id, matches with field from the users table';


--
-- Name: COLUMN commanders.commander_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN commanders.commander_name IS 'The commander''s name, which is displayed in battles and on the map';


--
-- Name: COLUMN commanders.commander_experience; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN commanders.commander_experience IS 'The commander''s experience level';


--
-- Name: COLUMN commanders.commander_balance; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN commanders.commander_balance IS 'Representation of the amount of money this commander currently has';


--
-- Name: commanders_commander_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE commanders_commander_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commanders_commander_id_seq OWNER TO dlboom;

--
-- Name: commanders_commander_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE commanders_commander_id_seq OWNED BY commanders.commander_id;


--
-- Name: commanders_commander_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('commanders_commander_id_seq', 10, true);


--
-- Name: extensions; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE extensions (
    extension_id integer NOT NULL,
    extension_name character varying(60) NOT NULL,
    extension_active boolean NOT NULL,
    extension_utility boolean NOT NULL,
    extension_installed timestamp without time zone NOT NULL
);


ALTER TABLE public.extensions OWNER TO dlboom;

--
-- Name: TABLE extensions; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE extensions IS 'Extensions installed on this instance of Magasi PHP.';


--
-- Name: extensions_extension_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE extensions_extension_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.extensions_extension_id_seq OWNER TO dlboom;

--
-- Name: extensions_extension_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE extensions_extension_id_seq OWNED BY extensions.extension_id;


--
-- Name: extensions_extension_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('extensions_extension_id_seq', 3, true);


--
-- Name: factions; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE factions (
    faction_id integer NOT NULL,
    faction_title character varying(80) NOT NULL,
    faction_description text NOT NULL,
    faction_population integer NOT NULL,
    faction_acronym character varying(8),
    faction_name character varying(80)
);


ALTER TABLE public.factions OWNER TO dlboom;

--
-- Name: TABLE factions; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE factions IS 'Information on all of the available factions.';


--
-- Name: COLUMN factions.faction_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN factions.faction_id IS 'Faction''s unique id';


--
-- Name: COLUMN factions.faction_title; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN factions.faction_title IS 'The faction''s name';


--
-- Name: COLUMN factions.faction_description; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN factions.faction_description IS 'The faction''s history, goals, mission, etc.';


--
-- Name: COLUMN factions.faction_population; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN factions.faction_population IS 'The number of players that chose this faction';


--
-- Name: COLUMN factions.faction_acronym; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN factions.faction_acronym IS 'A short representation of the faction''s name.';


--
-- Name: COLUMN factions.faction_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN factions.faction_name IS 'A URL friendly version of the faction''s name.';


--
-- Name: factions_faction_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE factions_faction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.factions_faction_id_seq OWNER TO dlboom;

--
-- Name: factions_faction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE factions_faction_id_seq OWNED BY factions.faction_id;


--
-- Name: factions_faction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('factions_faction_id_seq', 3, true);


--
-- Name: natural_resources; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE natural_resources (
    natural_resource_id integer NOT NULL,
    natural_resource_title character varying(30),
    natural_resource_name character varying(30),
    resource_id integer
);


ALTER TABLE public.natural_resources OWNER TO dlboom;

--
-- Name: TABLE natural_resources; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE natural_resources IS 'All of the different natural resources in the game';


--
-- Name: natural_resources_natural_resource_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE natural_resources_natural_resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.natural_resources_natural_resource_id_seq OWNER TO dlboom;

--
-- Name: natural_resources_natural_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE natural_resources_natural_resource_id_seq OWNED BY natural_resources.natural_resource_id;


--
-- Name: natural_resources_natural_resource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('natural_resources_natural_resource_id_seq', 1, false);


--
-- Name: ranks; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE ranks (
    rank_id integer NOT NULL,
    rank_title character varying(80) NOT NULL,
    rank_name character varying(80) NOT NULL,
    rank_order smallint NOT NULL,
    rank_level integer NOT NULL
);


ALTER TABLE public.ranks OWNER TO dlboom;

--
-- Name: TABLE ranks; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE ranks IS 'The ranks that a commander can hold.';


--
-- Name: COLUMN ranks.rank_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN ranks.rank_id IS 'The rank''s unique identifier';


--
-- Name: COLUMN ranks.rank_title; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN ranks.rank_title IS 'The rank''s title';


--
-- Name: COLUMN ranks.rank_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN ranks.rank_name IS 'A URL friendly version of the rank''s title.';


--
-- Name: COLUMN ranks.rank_order; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN ranks.rank_order IS 'This rank''s place in the hierarchy of ranks.';


--
-- Name: COLUMN ranks.rank_level; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN ranks.rank_level IS 'The number of experience points needed to reach this rank';


--
-- Name: ranks_rank_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE ranks_rank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ranks_rank_id_seq OWNER TO dlboom;

--
-- Name: ranks_rank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE ranks_rank_id_seq OWNED BY ranks.rank_id;


--
-- Name: ranks_rank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('ranks_rank_id_seq', 1, true);


--
-- Name: resource_grades; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE resource_grades (
    resource_grade_id integer NOT NULL,
    resource_grade_name character varying(30),
    resource_grade_level smallint,
    resource_grade_title character varying(30)
);


ALTER TABLE public.resource_grades OWNER TO dlboom;

--
-- Name: TABLE resource_grades; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE resource_grades IS 'The different grades or quality levels a resource can be';


--
-- Name: resource_grades_resource_grade_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE resource_grades_resource_grade_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resource_grades_resource_grade_id_seq OWNER TO dlboom;

--
-- Name: resource_grades_resource_grade_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE resource_grades_resource_grade_id_seq OWNED BY resource_grades.resource_grade_id;


--
-- Name: resource_grades_resource_grade_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('resource_grades_resource_grade_id_seq', 4, true);


--
-- Name: resources; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE resources (
    resource_id integer NOT NULL
);


ALTER TABLE public.resources OWNER TO dlboom;

--
-- Name: TABLE resources; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE resources IS 'All of the different resources in the game';


--
-- Name: resources_resource_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE resources_resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resources_resource_id_seq OWNER TO dlboom;

--
-- Name: resources_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE resources_resource_id_seq OWNED BY resources.resource_id;


--
-- Name: resources_resource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('resources_resource_id_seq', 1, false);


--
-- Name: scenarios; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE scenarios (
    scenario_id integer NOT NULL,
    scenario_name character varying(140)
);


ALTER TABLE public.scenarios OWNER TO dlboom;

--
-- Name: TABLE scenarios; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE scenarios IS 'Table holding all of the possible scenario types in a zone';


--
-- Name: COLUMN scenarios.scenario_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN scenarios.scenario_id IS 'A unqiue identifier for the scenario type';


--
-- Name: COLUMN scenarios.scenario_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN scenarios.scenario_name IS 'A simple name for the scenario';


--
-- Name: scenarios_scenario_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE scenarios_scenario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scenarios_scenario_id_seq OWNER TO dlboom;

--
-- Name: scenarios_scenario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE scenarios_scenario_id_seq OWNED BY scenarios.scenario_id;


--
-- Name: scenarios_scenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('scenarios_scenario_id_seq', 1, true);


--
-- Name: synthetic_resources; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE synthetic_resources (
    synthetic_resource_id integer NOT NULL,
    resource_id integer,
    synthetic_resource_title character varying(120),
    synthetic_resource_name character varying(120),
    synthetic_resource_simple boolean
);


ALTER TABLE public.synthetic_resources OWNER TO dlboom;

--
-- Name: TABLE synthetic_resources; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE synthetic_resources IS 'All of the different synthetic resources in the game';


--
-- Name: COLUMN synthetic_resources.synthetic_resource_simple; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN synthetic_resources.synthetic_resource_simple IS 'True if this resource only requires natural resources to construct';


--
-- Name: synthetic_resources_synthetic_resource_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE synthetic_resources_synthetic_resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.synthetic_resources_synthetic_resource_id_seq OWNER TO dlboom;

--
-- Name: synthetic_resources_synthetic_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE synthetic_resources_synthetic_resource_id_seq OWNED BY synthetic_resources.synthetic_resource_id;


--
-- Name: synthetic_resources_synthetic_resource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('synthetic_resources_synthetic_resource_id_seq', 1, false);


--
-- Name: territories; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE territories (
    territory_x integer NOT NULL,
    territory_y integer NOT NULL,
    faction_id integer,
    territory_status_id integer,
    territory_id integer NOT NULL
);


ALTER TABLE public.territories OWNER TO dlboom;

--
-- Name: TABLE territories; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE territories IS 'Table holding information on all of the territories in the game';


--
-- Name: COLUMN territories.territory_x; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN territories.territory_x IS 'The x coordinate of this territory on the map';


--
-- Name: COLUMN territories.territory_y; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN territories.territory_y IS 'The y coordinate of this territory on the map';


--
-- Name: COLUMN territories.faction_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN territories.faction_id IS 'The unique identifier of the faction that currently controls this territory';


--
-- Name: COLUMN territories.territory_status_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN territories.territory_status_id IS 'The unique identifier of this territory''s current status';


--
-- Name: COLUMN territories.territory_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN territories.territory_id IS 'Unqiue identifier for each territory';


--
-- Name: territories_territory_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE territories_territory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.territories_territory_id_seq OWNER TO dlboom;

--
-- Name: territories_territory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE territories_territory_id_seq OWNED BY territories.territory_id;


--
-- Name: territories_territory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('territories_territory_id_seq', 1, false);


--
-- Name: territory_statuses; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE territory_statuses (
    territory_status_id integer NOT NULL,
    territory_status_name character varying(40)
);


ALTER TABLE public.territory_statuses OWNER TO dlboom;

--
-- Name: TABLE territory_statuses; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE territory_statuses IS 'Table holding the possible states a territory can be in';


--
-- Name: COLUMN territory_statuses.territory_status_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN territory_statuses.territory_status_id IS 'Unqiue identifier for each status';


--
-- Name: COLUMN territory_statuses.territory_status_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN territory_statuses.territory_status_name IS 'Simple text name for this status';


--
-- Name: territory_statuses_territory_status_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE territory_statuses_territory_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.territory_statuses_territory_status_id_seq OWNER TO dlboom;

--
-- Name: territory_statuses_territory_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE territory_statuses_territory_status_id_seq OWNED BY territory_statuses.territory_status_id;


--
-- Name: territory_statuses_territory_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('territory_statuses_territory_status_id_seq', 4, true);


--
-- Name: users; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE users (
    user_activity timestamp without time zone NOT NULL,
    user_created timestamp without time zone NOT NULL,
    user_timezone smallint,
    user_name character varying,
    user_first_name character varying,
    user_last_name character varying,
    user_birthday character varying,
    user_email character varying,
    user_updated timestamp without time zone,
    user_id character varying(20) NOT NULL,
    user_action_key character(32)
);


ALTER TABLE public.users OWNER TO dlboom;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE users IS 'All of the users in the system.';


--
-- Name: COLUMN users.user_activity; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_activity IS 'Date and time the user last took an action';


--
-- Name: COLUMN users.user_created; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_created IS 'Date the user was created';


--
-- Name: COLUMN users.user_timezone; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_timezone IS 'Integer from -12 to 12, representing timezone offset from UTC.';


--
-- Name: COLUMN users.user_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_name IS 'User''s full name provided by Facebook';


--
-- Name: COLUMN users.user_first_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_first_name IS 'User''s first name provided by Facebook';


--
-- Name: COLUMN users.user_last_name; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_last_name IS 'User''s last name provided by Facebook';


--
-- Name: COLUMN users.user_birthday; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_birthday IS 'User''s birthday in MM/DD/YYYY format provided by Facebook';


--
-- Name: COLUMN users.user_email; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_email IS 'User''s e-mail provided by Facebook.';


--
-- Name: COLUMN users.user_updated; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_updated IS 'Timestamp of when the user''s information was last pulled from Facebook';


--
-- Name: COLUMN users.user_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_id IS 'User id provided by Facebook';


--
-- Name: COLUMN users.user_action_key; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN users.user_action_key IS 'The available action key this user must send to perform actions';


--
-- Name: zone_scenarios; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE zone_scenarios (
    zone_scenario_id integer NOT NULL,
    zone_id integer,
    scenario_id integer
);


ALTER TABLE public.zone_scenarios OWNER TO dlboom;

--
-- Name: TABLE zone_scenarios; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE zone_scenarios IS 'Table holding the individual generated battle scenarios within each zone.';


--
-- Name: COLUMN zone_scenarios.zone_scenario_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zone_scenarios.zone_scenario_id IS 'A unique identifier for each zone scenario';


--
-- Name: COLUMN zone_scenarios.zone_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zone_scenarios.zone_id IS 'Unique identifier for the zone this scenario belongs to';


--
-- Name: COLUMN zone_scenarios.scenario_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zone_scenarios.scenario_id IS 'Unique identifier for the scenario type';


--
-- Name: zone_scenarios_zone_scenario_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE zone_scenarios_zone_scenario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zone_scenarios_zone_scenario_id_seq OWNER TO dlboom;

--
-- Name: zone_scenarios_zone_scenario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE zone_scenarios_zone_scenario_id_seq OWNED BY zone_scenarios.zone_scenario_id;


--
-- Name: zone_scenarios_zone_scenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('zone_scenarios_zone_scenario_id_seq', 1, false);


--
-- Name: zone_statuses; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE zone_statuses (
    zone_status_name character varying(40),
    zone_status_id integer NOT NULL
);


ALTER TABLE public.zone_statuses OWNER TO dlboom;

--
-- Name: TABLE zone_statuses; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE zone_statuses IS 'Table holding the possible states a zone can be in';


--
-- Name: COLUMN zone_statuses.zone_status_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zone_statuses.zone_status_id IS 'Unique identifier for each particular zone state';


--
-- Name: zone_statuses_zone_status_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE zone_statuses_zone_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zone_statuses_zone_status_id_seq OWNER TO dlboom;

--
-- Name: zone_statuses_zone_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE zone_statuses_zone_status_id_seq OWNED BY zone_statuses.zone_status_id;


--
-- Name: zone_statuses_zone_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('zone_statuses_zone_status_id_seq', 3, true);


--
-- Name: zones; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE zones (
    zone_index integer NOT NULL,
    territory_id integer NOT NULL,
    zone_status_id smallint,
    faction_id integer,
    zone_id integer NOT NULL
);


ALTER TABLE public.zones OWNER TO dlboom;

--
-- Name: TABLE zones; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON TABLE zones IS 'Table that holds information about all of the zones on the map';


--
-- Name: COLUMN zones.zone_index; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zones.zone_index IS 'The index of this zone within its territory';


--
-- Name: COLUMN zones.territory_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zones.territory_id IS 'The unique identifier of the territory this zone falls within';


--
-- Name: COLUMN zones.zone_status_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zones.zone_status_id IS 'The unique identifier of this zone''s current state';


--
-- Name: COLUMN zones.faction_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zones.faction_id IS 'The unique identifier of the faction that controls this zone';


--
-- Name: COLUMN zones.zone_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zones.zone_id IS 'Unqiue identifier for each zone';


--
-- Name: zones_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: dlboom
--

CREATE SEQUENCE zones_zone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zones_zone_id_seq OWNER TO dlboom;

--
-- Name: zones_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dlboom
--

ALTER SEQUENCE zones_zone_id_seq OWNED BY zones.zone_id;


--
-- Name: zones_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dlboom
--

SELECT pg_catalog.setval('zones_zone_id_seq', 1, false);


--
-- Name: base_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE bases ALTER COLUMN base_id SET DEFAULT nextval('bases_base_id_seq'::regclass);


--
-- Name: battle_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE battles ALTER COLUMN battle_id SET DEFAULT nextval('battles_battle_id_seq'::regclass);


--
-- Name: command_base_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE command_bases ALTER COLUMN command_base_id SET DEFAULT nextval('command_bases_command_base_id_seq'::regclass);


--
-- Name: command_faction_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE command_factions ALTER COLUMN command_faction_id SET DEFAULT nextval('command_factions_command_faction_id_seq'::regclass);


--
-- Name: command_rank_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE command_ranks ALTER COLUMN command_rank_id SET DEFAULT nextval('command_ranks_command_rank_id_seq'::regclass);


--
-- Name: commander_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE commanders ALTER COLUMN commander_id SET DEFAULT nextval('commanders_commander_id_seq'::regclass);


--
-- Name: extension_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE extensions ALTER COLUMN extension_id SET DEFAULT nextval('extensions_extension_id_seq'::regclass);


--
-- Name: faction_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE factions ALTER COLUMN faction_id SET DEFAULT nextval('factions_faction_id_seq'::regclass);


--
-- Name: natural_resource_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE natural_resources ALTER COLUMN natural_resource_id SET DEFAULT nextval('natural_resources_natural_resource_id_seq'::regclass);


--
-- Name: rank_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE ranks ALTER COLUMN rank_id SET DEFAULT nextval('ranks_rank_id_seq'::regclass);


--
-- Name: resource_grade_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE resource_grades ALTER COLUMN resource_grade_id SET DEFAULT nextval('resource_grades_resource_grade_id_seq'::regclass);


--
-- Name: resource_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE resources ALTER COLUMN resource_id SET DEFAULT nextval('resources_resource_id_seq'::regclass);


--
-- Name: scenario_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE scenarios ALTER COLUMN scenario_id SET DEFAULT nextval('scenarios_scenario_id_seq'::regclass);


--
-- Name: synthetic_resource_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE synthetic_resources ALTER COLUMN synthetic_resource_id SET DEFAULT nextval('synthetic_resources_synthetic_resource_id_seq'::regclass);


--
-- Name: territory_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE territories ALTER COLUMN territory_id SET DEFAULT nextval('territories_territory_id_seq'::regclass);


--
-- Name: territory_status_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE territory_statuses ALTER COLUMN territory_status_id SET DEFAULT nextval('territory_statuses_territory_status_id_seq'::regclass);


--
-- Name: zone_scenario_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE zone_scenarios ALTER COLUMN zone_scenario_id SET DEFAULT nextval('zone_scenarios_zone_scenario_id_seq'::regclass);


--
-- Name: zone_status_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE zone_statuses ALTER COLUMN zone_status_id SET DEFAULT nextval('zone_statuses_zone_status_id_seq'::regclass);


--
-- Name: zone_id; Type: DEFAULT; Schema: public; Owner: dlboom
--

ALTER TABLE zones ALTER COLUMN zone_id SET DEFAULT nextval('zones_zone_id_seq'::regclass);


--
-- Data for Name: bases; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY bases (base_id, base_title, base_name, base_description) FROM stdin;
1	Rolling Thunder	rolling_thunder	An outpost on wheels, able to traverse even the tallest of mountains and deepest of seas, with plenty of space to carry a standing army and the equipment to support them.
2	Flying Phoenix	flying_phoenix	A city in the sky.  Flying high above the landscape, with a view unmatched by even the tallest mountain, and the ability to drill far beneath the planet's crust to acquire the most sought-after resources.
\.


--
-- Data for Name: battle_commanders; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY battle_commanders (battle_id, commander_id, battle_commander_joined) FROM stdin;
\.


--
-- Data for Name: battles; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY battles (battle_id, zone_scenario_id, battle_start) FROM stdin;
\.


--
-- Data for Name: command_bases; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY command_bases (command_base_id, base_id, commander_id, command_base_acquired, command_base_active, command_base_bandwidth) FROM stdin;
8	1	9	2011-04-05 22:05:22.437729	t	0
9	1	10	2011-04-05 22:05:22.437729	t	0
\.


--
-- Data for Name: command_factions; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY command_factions (command_faction_id, faction_id, commander_id, command_faction_joined, command_faction_active, command_faction_dropship_max, command_faction_dropships) FROM stdin;
6	1	9	2011-04-05 22:05:22.439009	t	0	0
7	1	10	2011-04-05 22:05:22.439009	t	0	0
\.


--
-- Data for Name: command_ranks; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY command_ranks (command_rank_id, rank_id, commander_id, command_rank_achieved, command_rank_active) FROM stdin;
2	1	9	2011-04-05 22:05:22.440759	t
3	1	10	2011-04-05 22:05:22.440759	t
\.


--
-- Data for Name: commanders; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY commanders (commander_id, user_id, commander_name, commander_experience, commander_balance) FROM stdin;
9	100002260212840     	Stalefish	0	0
10	678450388           	loganlong	0	0
\.


--
-- Data for Name: extensions; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY extensions (extension_id, extension_name, extension_active, extension_utility, extension_installed) FROM stdin;
1	commanders	t	f	2011-03-20 17:33:43.879851
2	factions	t	f	2011-04-03 17:48:47.879258
3	bases	t	f	2011-04-03 20:37:26.464137
\.


--
-- Data for Name: factions; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY factions (faction_id, faction_title, faction_description, faction_population, faction_acronym, faction_name) FROM stdin;
2	Ekova, Inc.	A family-owned industrialist corporation responsible for many of Earth's environmentally friendly advances. Ekova handles many of Earth's major metropolitan infrastructure contracts, building roads, apartments, parks, and many other civil installations.	0	EKV	ekova
3	Kovanant	A rogue, technology-obsessed umbrella corporation fighting to take absolute control over Kova and turn it into a space-faring utopia. Many of its subsidiaries on Earth are simply buffer companies used to filter money around the planet and especially offworld to support its military engagements on Kova itself.	0	KVN	kovanant
1	The Interplanetary Kova Company	A defense powerhouse, responsible for a substantial part of Earth's arms trade. War is an eventuality on Earth, and the need for weapons never waivered. The IKC is fighting to secure a steady supply of Kovanite to its factories on Earth to support the armies of the future.	0	IKC	the_interplanetary_kova_company
\.


--
-- Data for Name: natural_resources; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY natural_resources (natural_resource_id, natural_resource_title, natural_resource_name, resource_id) FROM stdin;
\.


--
-- Data for Name: ranks; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY ranks (rank_id, rank_title, rank_name, rank_order, rank_level) FROM stdin;
1	Private	private	1	1
\.


--
-- Data for Name: resource_grades; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY resource_grades (resource_grade_id, resource_grade_name, resource_grade_level, resource_grade_title) FROM stdin;
1	excellent	1	Excellent
2	good	2	Good
3	decent	3	Decent
4	poor	4	Poor
\.


--
-- Data for Name: resources; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY resources (resource_id) FROM stdin;
\.


--
-- Data for Name: scenarios; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY scenarios (scenario_id, scenario_name) FROM stdin;
1	showdown
\.


--
-- Data for Name: synthetic_resources; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY synthetic_resources (synthetic_resource_id, resource_id, synthetic_resource_title, synthetic_resource_name, synthetic_resource_simple) FROM stdin;
\.


--
-- Data for Name: territories; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY territories (territory_x, territory_y, faction_id, territory_status_id, territory_id) FROM stdin;
\.


--
-- Data for Name: territory_statuses; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY territory_statuses (territory_status_id, territory_status_name) FROM stdin;
1	open
2	locked
3	disputed
4	headquarters
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY users (user_activity, user_created, user_timezone, user_name, user_first_name, user_last_name, user_birthday, user_email, user_updated, user_id, user_action_key) FROM stdin;
2011-03-23 17:59:03	2011-03-23 17:59:03	-6	Logan Long	Logan	Long	11/04/1985	loganlong@gmail.com	2011-03-23 17:59:03	678450388	JvjzObdzalc7lwIyP5jlpwLaxo4KbZrv
2011-03-22 06:23:22	2011-03-22 06:23:22	-7	David Talley	David	Talley	03/27/1986	dtalley@gmail.com	2011-03-29 06:08:58	804640510	JvjzObdzalc7lwIyP5jlpwLaxo4KbZrv
2011-03-29 19:41:07	2011-03-29 19:41:07	-7	Patricia Ambbfjbabhdj Smithberg	Patricia	Smithberg	04/12/1980	pnvqzds_smithberg@tfbnw.net	2011-04-02 20:22:03	100002260212840	JvjzObdzalc7lwIyP5jlpwLaxo4KbZrv
\.


--
-- Data for Name: zone_scenarios; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY zone_scenarios (zone_scenario_id, zone_id, scenario_id) FROM stdin;
\.


--
-- Data for Name: zone_statuses; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY zone_statuses (zone_status_name, zone_status_id) FROM stdin;
open	1
locked	2
disputed	3
\.


--
-- Data for Name: zones; Type: TABLE DATA; Schema: public; Owner: dlboom
--

COPY zones (zone_index, territory_id, zone_status_id, faction_id, zone_id) FROM stdin;
\.


--
-- Name: bases_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY bases
    ADD CONSTRAINT bases_pkey PRIMARY KEY (base_id);


--
-- Name: battles_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY battles
    ADD CONSTRAINT battles_pkey PRIMARY KEY (battle_id);


--
-- Name: command_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY command_bases
    ADD CONSTRAINT command_bases_pkey PRIMARY KEY (command_base_id);


--
-- Name: command_factions_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY command_factions
    ADD CONSTRAINT command_factions_pkey PRIMARY KEY (command_faction_id);


--
-- Name: command_ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY command_ranks
    ADD CONSTRAINT command_ranks_pkey PRIMARY KEY (command_rank_id);


--
-- Name: commanders_commander_name_key; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY commanders
    ADD CONSTRAINT commanders_commander_name_key UNIQUE (commander_name);


--
-- Name: commanders_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY commanders
    ADD CONSTRAINT commanders_pkey PRIMARY KEY (commander_id);


--
-- Name: extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (extension_id);


--
-- Name: factions_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY factions
    ADD CONSTRAINT factions_pkey PRIMARY KEY (faction_id);


--
-- Name: natural_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY natural_resources
    ADD CONSTRAINT natural_resources_pkey PRIMARY KEY (natural_resource_id);


--
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (rank_id);


--
-- Name: resource_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY resource_grades
    ADD CONSTRAINT resource_grades_pkey PRIMARY KEY (resource_grade_id);


--
-- Name: resources_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (resource_id);


--
-- Name: scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (scenario_id);


--
-- Name: synthetic_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY synthetic_resources
    ADD CONSTRAINT synthetic_resources_pkey PRIMARY KEY (synthetic_resource_id);


--
-- Name: territories_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY territories
    ADD CONSTRAINT territories_pkey PRIMARY KEY (territory_id);


--
-- Name: territories_territory_x_key; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY territories
    ADD CONSTRAINT territories_territory_x_key UNIQUE (territory_x, territory_y);


--
-- Name: territory_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY territory_statuses
    ADD CONSTRAINT territory_statuses_pkey PRIMARY KEY (territory_status_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: zone_scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY zone_scenarios
    ADD CONSTRAINT zone_scenarios_pkey PRIMARY KEY (zone_scenario_id);


--
-- Name: zone_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY zone_statuses
    ADD CONSTRAINT zone_statuses_pkey PRIMARY KEY (zone_status_id);


--
-- Name: zones_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (zone_id);


--
-- Name: zones_zone_index_key; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY zones
    ADD CONSTRAINT zones_zone_index_key UNIQUE (zone_index, territory_id);


--
-- Name: user_id_index; Type: INDEX; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE UNIQUE INDEX user_id_index ON commanders USING btree (user_id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY command_bases
    ADD CONSTRAINT "$1" FOREIGN KEY (base_id) REFERENCES bases(base_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY command_ranks
    ADD CONSTRAINT "$1" FOREIGN KEY (rank_id) REFERENCES ranks(rank_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY command_bases
    ADD CONSTRAINT "$2" FOREIGN KEY (commander_id) REFERENCES commanders(commander_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY command_ranks
    ADD CONSTRAINT "$2" FOREIGN KEY (commander_id) REFERENCES commanders(commander_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: battles_zone_scenario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY battles
    ADD CONSTRAINT battles_zone_scenario_id_fkey FOREIGN KEY (zone_scenario_id) REFERENCES zone_scenarios(zone_scenario_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: command_factions_commander_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY command_factions
    ADD CONSTRAINT command_factions_commander_id_fkey FOREIGN KEY (commander_id) REFERENCES commanders(commander_id) ON UPDATE RESTRICT;


--
-- Name: command_factions_faction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY command_factions
    ADD CONSTRAINT command_factions_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES factions(faction_id) ON UPDATE RESTRICT;


--
-- Name: commanders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY commanders
    ADD CONSTRAINT commanders_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE RESTRICT;


--
-- Name: natural_resources_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY natural_resources
    ADD CONSTRAINT natural_resources_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: synthetic_resources_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY synthetic_resources
    ADD CONSTRAINT synthetic_resources_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES resources(resource_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: territories_faction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY territories
    ADD CONSTRAINT territories_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES factions(faction_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: territories_territory_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY territories
    ADD CONSTRAINT territories_territory_status_id_fkey FOREIGN KEY (territory_status_id) REFERENCES territory_statuses(territory_status_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: zone_scenarios_scenario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY zone_scenarios
    ADD CONSTRAINT zone_scenarios_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES scenarios(scenario_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: zone_scenarios_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY zone_scenarios
    ADD CONSTRAINT zone_scenarios_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES zones(zone_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: zones_faction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY zones
    ADD CONSTRAINT zones_faction_id_fkey FOREIGN KEY (faction_id) REFERENCES factions(faction_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: zones_territory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY zones
    ADD CONSTRAINT zones_territory_id_fkey FOREIGN KEY (territory_id) REFERENCES territories(territory_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: zones_zone_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dlboom
--

ALTER TABLE ONLY zones
    ADD CONSTRAINT zones_zone_status_id_fkey FOREIGN KEY (zone_status_id) REFERENCES zone_statuses(zone_status_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

