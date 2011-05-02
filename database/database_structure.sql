--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bases; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE bases (
    base_id serial NOT NULL,
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
-- Name: command_bases; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE command_bases (
    command_base_id serial NOT NULL,
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
-- Name: command_factions; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE command_factions (
    command_faction_id serial NOT NULL,
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
-- Name: command_ranks; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE command_ranks (
    command_rank_id serial NOT NULL,
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
-- Name: commanders; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE commanders (
    commander_id serial NOT NULL,
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
-- Name: extensions; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE extensions (
    extension_id serial NOT NULL,
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
-- Name: factions; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE factions (
    faction_id serial NOT NULL,
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
-- Name: ranks; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE ranks (
    rank_id serial NOT NULL,
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
-- Name: scenarios; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE scenarios (
    scenario_id serial NOT NULL,
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
-- Name: territories; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE territories (
    territory_x integer NOT NULL,
    territory_y integer NOT NULL,
    faction_id integer,
    territory_status_id integer,
    territory_id serial NOT NULL
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
-- Name: territory_statuses; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE territory_statuses (
    territory_status_id serial NOT NULL,
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
    zone_scenario_id serial NOT NULL,
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
-- Name: zone_statuses; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE zone_statuses (
    zone_status_name character varying(40),
    zone_status_id serial NOT NULL
);


ALTER TABLE public.zone_statuses OWNER TO dlboom;

--
-- Name: COLUMN zone_statuses.zone_status_id; Type: COMMENT; Schema: public; Owner: dlboom
--

COMMENT ON COLUMN zone_statuses.zone_status_id IS 'Unique identifier for each particular zone state';


--
-- Name: zones; Type: TABLE; Schema: public; Owner: dlboom; Tablespace: 
--

CREATE TABLE zones (
    zone_index integer NOT NULL,
    territory_id integer NOT NULL,
    zone_status_id smallint,
    faction_id integer,
    zone_id serial NOT NULL
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
-- Name: bases_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY bases
    ADD CONSTRAINT bases_pkey PRIMARY KEY (base_id);


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
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (rank_id);


--
-- Name: scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: dlboom; Tablespace: 
--

ALTER TABLE ONLY scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (scenario_id);


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

