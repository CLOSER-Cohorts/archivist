--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE categories (
    id integer NOT NULL,
    label character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: cc_conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cc_conditions (
    id integer NOT NULL,
    literal character varying,
    logic character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: cc_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cc_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cc_conditions_id_seq OWNED BY cc_conditions.id;


--
-- Name: cc_loops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cc_loops (
    id integer NOT NULL,
    loop_var character varying,
    start_val character varying,
    end_val character varying,
    loop_while character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: cc_loops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cc_loops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_loops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cc_loops_id_seq OWNED BY cc_loops.id;


--
-- Name: cc_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cc_questions (
    id integer NOT NULL,
    question_id integer NOT NULL,
    question_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    response_unit_id integer NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: cc_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cc_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cc_questions_id_seq OWNED BY cc_questions.id;


--
-- Name: cc_sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cc_sequences (
    id integer NOT NULL,
    literal character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: cc_sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cc_sequences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cc_sequences_id_seq OWNED BY cc_sequences.id;


--
-- Name: cc_statements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cc_statements (
    id integer NOT NULL,
    literal character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: cc_statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cc_statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cc_statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cc_statements_id_seq OWNED BY cc_statements.id;


--
-- Name: code_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE code_lists (
    id integer NOT NULL,
    label character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: code_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE code_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE code_lists_id_seq OWNED BY code_lists.id;


--
-- Name: codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE codes (
    id integer NOT NULL,
    value character varying,
    "order" integer,
    code_list_id integer NOT NULL,
    category_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE codes_id_seq OWNED BY codes.id;


--
-- Name: control_constructs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE control_constructs (
    id integer NOT NULL,
    label character varying,
    construct_id integer NOT NULL,
    construct_type character varying NOT NULL,
    parent_id integer,
    "position" integer,
    branch integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: control_constructs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE control_constructs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_constructs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE control_constructs_id_seq OWNED BY control_constructs.id;


--
-- Name: datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE datasets (
    id integer NOT NULL,
    name character varying NOT NULL,
    doi character varying,
    filename character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE datasets_id_seq OWNED BY datasets.id;


--
-- Name: instructions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE instructions (
    id integer NOT NULL,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instructions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instructions_id_seq OWNED BY instructions.id;


--
-- Name: instruments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE instruments (
    id integer NOT NULL,
    agency character varying,
    version character varying,
    prefix character varying,
    label character varying,
    study character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instruments_datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE instruments_datasets (
    id integer NOT NULL,
    instrument_id integer NOT NULL,
    dataset_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instruments_datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instruments_datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instruments_datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instruments_datasets_id_seq OWNED BY instruments_datasets.id;


--
-- Name: instruments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instruments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instruments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE instruments_id_seq OWNED BY instruments.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE links (
    id integer NOT NULL,
    target_id integer NOT NULL,
    target_type character varying NOT NULL,
    topic_id integer NOT NULL,
    x integer,
    y integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE links_id_seq OWNED BY links.id;


--
-- Name: maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE maps (
    id integer NOT NULL,
    source_id integer NOT NULL,
    source_type character varying NOT NULL,
    variable_id integer NOT NULL,
    x integer,
    y integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE maps_id_seq OWNED BY maps.id;


--
-- Name: question_grids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE question_grids (
    id integer NOT NULL,
    label character varying,
    literal character varying,
    instruction_id integer,
    vertical_code_list_id integer,
    horizontal_code_list_id integer NOT NULL,
    roster_rows integer DEFAULT 0,
    roster_label character varying,
    corner_label character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: question_grids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_grids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_grids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_grids_id_seq OWNED BY question_grids.id;


--
-- Name: question_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE question_items (
    id integer NOT NULL,
    label character varying,
    literal character varying,
    instruction_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: question_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_items_id_seq OWNED BY question_items.id;


--
-- Name: rds_qs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rds_qs (
    id integer NOT NULL,
    response_domain_id integer NOT NULL,
    response_domain_type character varying NOT NULL,
    question_id integer NOT NULL,
    question_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    code_id integer
);


--
-- Name: rds_qs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rds_qs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rds_qs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rds_qs_id_seq OWNED BY rds_qs.id;


--
-- Name: response_domain_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE response_domain_codes (
    id integer NOT NULL,
    code_list_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: response_domain_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE response_domain_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE response_domain_codes_id_seq OWNED BY response_domain_codes.id;


--
-- Name: response_domain_datetimes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE response_domain_datetimes (
    id integer NOT NULL,
    datetime_type character varying,
    label character varying,
    format character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: response_domain_datetimes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE response_domain_datetimes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_datetimes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE response_domain_datetimes_id_seq OWNED BY response_domain_datetimes.id;


--
-- Name: response_domain_numerics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE response_domain_numerics (
    id integer NOT NULL,
    numeric_type character varying,
    label character varying,
    min numeric,
    max numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: response_domain_numerics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE response_domain_numerics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_numerics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE response_domain_numerics_id_seq OWNED BY response_domain_numerics.id;


--
-- Name: response_domain_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE response_domain_texts (
    id integer NOT NULL,
    label character varying,
    maxlen integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: response_domain_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE response_domain_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE response_domain_texts_id_seq OWNED BY response_domain_texts.id;


--
-- Name: response_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE response_units (
    id integer NOT NULL,
    label character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: response_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE response_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE response_units_id_seq OWNED BY response_units.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE topics (
    id integer NOT NULL,
    name character varying NOT NULL,
    parent_id integer,
    code character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topics_id_seq OWNED BY topics.id;


--
-- Name: variables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE variables (
    id integer NOT NULL,
    name character varying NOT NULL,
    label character varying,
    var_type character varying NOT NULL,
    dataset_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: variables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE variables_id_seq OWNED BY variables.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_conditions ALTER COLUMN id SET DEFAULT nextval('cc_conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_loops ALTER COLUMN id SET DEFAULT nextval('cc_loops_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_questions ALTER COLUMN id SET DEFAULT nextval('cc_questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_sequences ALTER COLUMN id SET DEFAULT nextval('cc_sequences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_statements ALTER COLUMN id SET DEFAULT nextval('cc_statements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_lists ALTER COLUMN id SET DEFAULT nextval('code_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes ALTER COLUMN id SET DEFAULT nextval('codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs ALTER COLUMN id SET DEFAULT nextval('control_constructs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets ALTER COLUMN id SET DEFAULT nextval('datasets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructions ALTER COLUMN id SET DEFAULT nextval('instructions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments ALTER COLUMN id SET DEFAULT nextval('instruments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets ALTER COLUMN id SET DEFAULT nextval('instruments_datasets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps ALTER COLUMN id SET DEFAULT nextval('maps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids ALTER COLUMN id SET DEFAULT nextval('question_grids_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_items ALTER COLUMN id SET DEFAULT nextval('question_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs ALTER COLUMN id SET DEFAULT nextval('rds_qs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes ALTER COLUMN id SET DEFAULT nextval('response_domain_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_datetimes ALTER COLUMN id SET DEFAULT nextval('response_domain_datetimes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_numerics ALTER COLUMN id SET DEFAULT nextval('response_domain_numerics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_texts ALTER COLUMN id SET DEFAULT nextval('response_domain_texts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_units ALTER COLUMN id SET DEFAULT nextval('response_units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY variables ALTER COLUMN id SET DEFAULT nextval('variables_id_seq'::regclass);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cc_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_conditions
    ADD CONSTRAINT cc_conditions_pkey PRIMARY KEY (id);


--
-- Name: cc_loops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_loops
    ADD CONSTRAINT cc_loops_pkey PRIMARY KEY (id);


--
-- Name: cc_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_questions
    ADD CONSTRAINT cc_questions_pkey PRIMARY KEY (id);


--
-- Name: cc_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_sequences
    ADD CONSTRAINT cc_sequences_pkey PRIMARY KEY (id);


--
-- Name: cc_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_statements
    ADD CONSTRAINT cc_statements_pkey PRIMARY KEY (id);


--
-- Name: code_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_lists
    ADD CONSTRAINT code_lists_pkey PRIMARY KEY (id);


--
-- Name: codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT codes_pkey PRIMARY KEY (id);


--
-- Name: control_constructs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT control_constructs_pkey PRIMARY KEY (id);


--
-- Name: datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructions
    ADD CONSTRAINT instructions_pkey PRIMARY KEY (id);


--
-- Name: instruments_datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets
    ADD CONSTRAINT instruments_datasets_pkey PRIMARY KEY (id);


--
-- Name: instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments
    ADD CONSTRAINT instruments_pkey PRIMARY KEY (id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: question_grids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT question_grids_pkey PRIMARY KEY (id);


--
-- Name: question_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_items
    ADD CONSTRAINT question_items_pkey PRIMARY KEY (id);


--
-- Name: rds_qs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs
    ADD CONSTRAINT rds_qs_pkey PRIMARY KEY (id);


--
-- Name: response_domain_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes
    ADD CONSTRAINT response_domain_codes_pkey PRIMARY KEY (id);


--
-- Name: response_domain_datetimes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_datetimes
    ADD CONSTRAINT response_domain_datetimes_pkey PRIMARY KEY (id);


--
-- Name: response_domain_numerics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_numerics
    ADD CONSTRAINT response_domain_numerics_pkey PRIMARY KEY (id);


--
-- Name: response_domain_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_texts
    ADD CONSTRAINT response_domain_texts_pkey PRIMARY KEY (id);


--
-- Name: response_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_units
    ADD CONSTRAINT response_units_pkey PRIMARY KEY (id);


--
-- Name: topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: variables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY variables
    ADD CONSTRAINT variables_pkey PRIMARY KEY (id);


--
-- Name: index_categories_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_instrument_id ON categories USING btree (instrument_id);


--
-- Name: index_categories_on_label; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_label ON categories USING btree (label);


--
-- Name: index_cc_conditions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_conditions_on_instrument_id ON cc_conditions USING btree (instrument_id);


--
-- Name: index_cc_loops_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_loops_on_instrument_id ON cc_loops USING btree (instrument_id);


--
-- Name: index_cc_questions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_instrument_id ON cc_questions USING btree (instrument_id);


--
-- Name: index_cc_questions_on_question_type_and_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_question_type_and_question_id ON cc_questions USING btree (question_type, question_id);


--
-- Name: index_cc_questions_on_response_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_response_unit_id ON cc_questions USING btree (response_unit_id);


--
-- Name: index_cc_sequences_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_sequences_on_instrument_id ON cc_sequences USING btree (instrument_id);


--
-- Name: index_cc_statements_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_statements_on_instrument_id ON cc_statements USING btree (instrument_id);


--
-- Name: index_code_lists_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_lists_on_instrument_id ON code_lists USING btree (instrument_id);


--
-- Name: index_codes_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_category_id ON codes USING btree (category_id);


--
-- Name: index_codes_on_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_code_list_id ON codes USING btree (code_list_id);


--
-- Name: index_control_constructs_on_construct_type_and_construct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_construct_type_and_construct_id ON control_constructs USING btree (construct_type, construct_id);


--
-- Name: index_control_constructs_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_parent_id ON control_constructs USING btree (parent_id);


--
-- Name: index_instructions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instructions_on_instrument_id ON instructions USING btree (instrument_id);


--
-- Name: index_instruments_datasets_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_datasets_on_dataset_id ON instruments_datasets USING btree (dataset_id);


--
-- Name: index_instruments_datasets_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_datasets_on_instrument_id ON instruments_datasets USING btree (instrument_id);


--
-- Name: index_links_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_target_type_and_target_id ON links USING btree (target_type, target_id);


--
-- Name: index_links_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_topic_id ON links USING btree (topic_id);


--
-- Name: index_maps_on_source_type_and_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_source_type_and_source_id ON maps USING btree (source_type, source_id);


--
-- Name: index_maps_on_variable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_variable_id ON maps USING btree (variable_id);


--
-- Name: index_question_grids_on_horizontal_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_horizontal_code_list_id ON question_grids USING btree (horizontal_code_list_id);


--
-- Name: index_question_grids_on_instruction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_instruction_id ON question_grids USING btree (instruction_id);


--
-- Name: index_question_grids_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_instrument_id ON question_grids USING btree (instrument_id);


--
-- Name: index_question_grids_on_vertical_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_vertical_code_list_id ON question_grids USING btree (vertical_code_list_id);


--
-- Name: index_question_items_on_instruction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_items_on_instruction_id ON question_items USING btree (instruction_id);


--
-- Name: index_question_items_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_items_on_instrument_id ON question_items USING btree (instrument_id);


--
-- Name: index_rds_qs_on_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_code_id ON rds_qs USING btree (code_id);


--
-- Name: index_rds_qs_on_question_type_and_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_question_type_and_question_id ON rds_qs USING btree (question_type, question_id);


--
-- Name: index_rds_qs_on_response_domain_type_and_response_domain_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_response_domain_type_and_response_domain_id ON rds_qs USING btree (response_domain_type, response_domain_id);


--
-- Name: index_response_domain_codes_on_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_codes_on_code_list_id ON response_domain_codes USING btree (code_list_id);


--
-- Name: index_response_domain_datetimes_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_datetimes_on_instrument_id ON response_domain_datetimes USING btree (instrument_id);


--
-- Name: index_response_domain_numerics_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_numerics_on_instrument_id ON response_domain_numerics USING btree (instrument_id);


--
-- Name: index_response_domain_texts_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_texts_on_instrument_id ON response_domain_texts USING btree (instrument_id);


--
-- Name: index_response_units_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_units_on_instrument_id ON response_units USING btree (instrument_id);


--
-- Name: index_topics_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topics_on_parent_id ON topics USING btree (parent_id);


--
-- Name: index_variables_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_variables_on_dataset_id ON variables USING btree (dataset_id);


--
-- Name: index_variables_on_name_and_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_variables_on_name_and_dataset_id ON variables USING btree (name, dataset_id);


--
-- Name: unique_linking; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_linking ON links USING btree (target_id, target_type, topic_id, x, y);


--
-- Name: unique_mapping; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_mapping ON maps USING btree (source_id, source_type, variable_id, x, y);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_21c0390148; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT fk_rails_21c0390148 FOREIGN KEY (horizontal_code_list_id) REFERENCES code_lists(id);


--
-- Name: fk_rails_33f3b47104; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY variables
    ADD CONSTRAINT fk_rails_33f3b47104 FOREIGN KEY (dataset_id) REFERENCES datasets(id);


--
-- Name: fk_rails_3d0d853840; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets
    ADD CONSTRAINT fk_rails_3d0d853840 FOREIGN KEY (dataset_id) REFERENCES datasets(id);


--
-- Name: fk_rails_572ea44f7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes
    ADD CONSTRAINT fk_rails_572ea44f7b FOREIGN KEY (code_list_id) REFERENCES code_lists(id);


--
-- Name: fk_rails_5f3c091f12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT fk_rails_5f3c091f12 FOREIGN KEY (parent_id) REFERENCES topics(id);


--
-- Name: fk_rails_9e38e93f70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT fk_rails_9e38e93f70 FOREIGN KEY (topic_id) REFERENCES topics(id);


--
-- Name: fk_rails_ce690a0b27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps
    ADD CONSTRAINT fk_rails_ce690a0b27 FOREIGN KEY (variable_id) REFERENCES variables(id);


--
-- Name: fk_rails_d7ce9bc772; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets
    ADD CONSTRAINT fk_rails_d7ce9bc772 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: fk_rails_db1a343fc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT fk_rails_db1a343fc8 FOREIGN KEY (code_list_id) REFERENCES code_lists(id);


--
-- Name: fk_rails_e0f057a9d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT fk_rails_e0f057a9d7 FOREIGN KEY (instruction_id) REFERENCES instructions(id);


--
-- Name: fk_rails_effac2db69; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT fk_rails_effac2db69 FOREIGN KEY (vertical_code_list_id) REFERENCES code_lists(id);


--
-- Name: fk_rails_f312241fda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT fk_rails_f312241fda FOREIGN KEY (parent_id) REFERENCES control_constructs(id);


--
-- Name: fk_rails_f3b15ab029; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_items
    ADD CONSTRAINT fk_rails_f3b15ab029 FOREIGN KEY (instruction_id) REFERENCES instructions(id);


--
-- Name: fk_rails_f8e439e0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT fk_rails_f8e439e0d7 FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20151129203547');

INSERT INTO schema_migrations (version) VALUES ('20151129204534');

INSERT INTO schema_migrations (version) VALUES ('20151129204903');

INSERT INTO schema_migrations (version) VALUES ('20151129205538');

INSERT INTO schema_migrations (version) VALUES ('20151129205758');

INSERT INTO schema_migrations (version) VALUES ('20151129210043');

INSERT INTO schema_migrations (version) VALUES ('20151130062018');

INSERT INTO schema_migrations (version) VALUES ('20151130062219');

INSERT INTO schema_migrations (version) VALUES ('20151130062608');

INSERT INTO schema_migrations (version) VALUES ('20151130063811');

INSERT INTO schema_migrations (version) VALUES ('20151130142555');

INSERT INTO schema_migrations (version) VALUES ('20151130143016');

INSERT INTO schema_migrations (version) VALUES ('20151130143420');

INSERT INTO schema_migrations (version) VALUES ('20151201094202');

INSERT INTO schema_migrations (version) VALUES ('20151201094926');

INSERT INTO schema_migrations (version) VALUES ('20151201095143');

INSERT INTO schema_migrations (version) VALUES ('20151201095347');

INSERT INTO schema_migrations (version) VALUES ('20151201095532');

INSERT INTO schema_migrations (version) VALUES ('20151201095541');

INSERT INTO schema_migrations (version) VALUES ('20151203122424');

INSERT INTO schema_migrations (version) VALUES ('20151204181052');

INSERT INTO schema_migrations (version) VALUES ('20151204193654');

INSERT INTO schema_migrations (version) VALUES ('20151206105535');

INSERT INTO schema_migrations (version) VALUES ('20151206110030');

INSERT INTO schema_migrations (version) VALUES ('20151206165407');

INSERT INTO schema_migrations (version) VALUES ('20151206165603');

INSERT INTO schema_migrations (version) VALUES ('20151206165726');

INSERT INTO schema_migrations (version) VALUES ('20151206185120');

INSERT INTO schema_migrations (version) VALUES ('20151206185659');

INSERT INTO schema_migrations (version) VALUES ('20151206205100');

INSERT INTO schema_migrations (version) VALUES ('20160121070958');

INSERT INTO schema_migrations (version) VALUES ('20160216154523');

