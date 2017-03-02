--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


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
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcCondition'::character varying
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
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcLoop'::character varying
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
    question_type character varying NOT NULL,
    question_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    response_unit_id integer NOT NULL,
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcQuestion'::character varying
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
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcSequence'::character varying
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
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcStatement'::character varying
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
    label character varying NOT NULL,
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
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
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
    construct_type character varying NOT NULL,
    construct_id integer NOT NULL,
    parent_id integer,
    "position" integer,
    branch integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
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
    updated_at timestamp without time zone NOT NULL,
    study character varying
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
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents (
    id integer NOT NULL,
    filename character varying,
    content_type character varying,
    file_contents bytea,
    md5_hash character varying(32),
    item_type character varying,
    item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE maps (
    id integer NOT NULL,
    source_type character varying NOT NULL,
    source_id integer NOT NULL,
    variable_id integer NOT NULL,
    x integer,
    y integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


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
-- Name: dv_mappings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW dv_mappings AS
 SELECT row_number() OVER () AS id,
    s.name AS source,
    v.name AS variable,
    v.dataset_id
   FROM ((maps m
     JOIN variables v ON ((m.variable_id = v.id)))
     JOIN variables s ON (((s.id = m.source_id) AND ((m.source_type)::text = 'Variable'::text))));


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE groups (
    id integer NOT NULL,
    group_type character varying,
    label character varying,
    study character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


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
    target_type character varying NOT NULL,
    target_id integer NOT NULL,
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
    label character varying NOT NULL,
    literal character varying,
    instruction_id integer,
    vertical_code_list_id integer,
    horizontal_code_list_id integer NOT NULL,
    roster_rows integer DEFAULT 0,
    roster_label character varying,
    corner_label character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL,
    question_type character varying DEFAULT 'QuestionGrid'::character varying
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
    label character varying NOT NULL,
    literal character varying,
    instruction_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL,
    question_type character varying DEFAULT 'QuestionItem'::character varying
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
-- Name: qv_mappings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW qv_mappings AS
 SELECT row_number() OVER () AS id,
    COALESCE(cc.label, '0'::character varying) AS question,
    v.name AS variable,
    m.x,
    m.y,
    qc.instrument_id,
    v.dataset_id
   FROM (((variables v
     LEFT JOIN maps m ON ((m.variable_id = v.id)))
     JOIN cc_questions qc ON (((qc.id = m.source_id) AND ((m.source_type)::text = 'CcQuestion'::text))))
     JOIN control_constructs cc ON (((qc.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcQuestion'::text))));


--
-- Name: rds_qs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rds_qs (
    id integer NOT NULL,
    response_domain_type character varying NOT NULL,
    response_domain_id integer NOT NULL,
    question_type character varying NOT NULL,
    question_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    code_id integer,
    instrument_id integer NOT NULL,
    rd_order integer
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
    updated_at timestamp without time zone NOT NULL,
    response_domain_type character varying DEFAULT 'ResponseDomainCode'::character varying,
    instrument_id integer NOT NULL,
    min_responses integer DEFAULT 1 NOT NULL,
    max_responses integer DEFAULT 1 NOT NULL
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
    instrument_id integer NOT NULL,
    response_domain_type character varying DEFAULT 'ResponseDomainDatetime'::character varying
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
    instrument_id integer NOT NULL,
    response_domain_type character varying DEFAULT 'ResponseDomainNumeric'::character varying
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
    instrument_id integer NOT NULL,
    response_domain_type character varying DEFAULT 'ResponseDomainText'::character varying
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
    updated_at timestamp without time zone NOT NULL,
    description text
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
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    first_name character varying DEFAULT ''::character varying NOT NULL,
    last_name character varying DEFAULT ''::character varying NOT NULL,
    group_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer,
    unlock_token character varying,
    locked_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


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
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: cc_conditions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_conditions ALTER COLUMN id SET DEFAULT nextval('cc_conditions_id_seq'::regclass);


--
-- Name: cc_loops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_loops ALTER COLUMN id SET DEFAULT nextval('cc_loops_id_seq'::regclass);


--
-- Name: cc_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_questions ALTER COLUMN id SET DEFAULT nextval('cc_questions_id_seq'::regclass);


--
-- Name: cc_sequences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_sequences ALTER COLUMN id SET DEFAULT nextval('cc_sequences_id_seq'::regclass);


--
-- Name: cc_statements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_statements ALTER COLUMN id SET DEFAULT nextval('cc_statements_id_seq'::regclass);


--
-- Name: code_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_lists ALTER COLUMN id SET DEFAULT nextval('code_lists_id_seq'::regclass);


--
-- Name: codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes ALTER COLUMN id SET DEFAULT nextval('codes_id_seq'::regclass);


--
-- Name: control_constructs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs ALTER COLUMN id SET DEFAULT nextval('control_constructs_id_seq'::regclass);


--
-- Name: datasets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets ALTER COLUMN id SET DEFAULT nextval('datasets_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: instructions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructions ALTER COLUMN id SET DEFAULT nextval('instructions_id_seq'::regclass);


--
-- Name: instruments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments ALTER COLUMN id SET DEFAULT nextval('instruments_id_seq'::regclass);


--
-- Name: instruments_datasets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets ALTER COLUMN id SET DEFAULT nextval('instruments_datasets_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: maps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps ALTER COLUMN id SET DEFAULT nextval('maps_id_seq'::regclass);


--
-- Name: question_grids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids ALTER COLUMN id SET DEFAULT nextval('question_grids_id_seq'::regclass);


--
-- Name: question_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_items ALTER COLUMN id SET DEFAULT nextval('question_items_id_seq'::regclass);


--
-- Name: rds_qs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs ALTER COLUMN id SET DEFAULT nextval('rds_qs_id_seq'::regclass);


--
-- Name: response_domain_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes ALTER COLUMN id SET DEFAULT nextval('response_domain_codes_id_seq'::regclass);


--
-- Name: response_domain_datetimes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_datetimes ALTER COLUMN id SET DEFAULT nextval('response_domain_datetimes_id_seq'::regclass);


--
-- Name: response_domain_numerics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_numerics ALTER COLUMN id SET DEFAULT nextval('response_domain_numerics_id_seq'::regclass);


--
-- Name: response_domain_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_texts ALTER COLUMN id SET DEFAULT nextval('response_domain_texts_id_seq'::regclass);


--
-- Name: response_units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_units ALTER COLUMN id SET DEFAULT nextval('response_units_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: variables id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY variables ALTER COLUMN id SET DEFAULT nextval('variables_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cc_conditions cc_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_conditions
    ADD CONSTRAINT cc_conditions_pkey PRIMARY KEY (id);


--
-- Name: cc_loops cc_loops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_loops
    ADD CONSTRAINT cc_loops_pkey PRIMARY KEY (id);


--
-- Name: cc_questions cc_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_questions
    ADD CONSTRAINT cc_questions_pkey PRIMARY KEY (id);


--
-- Name: cc_sequences cc_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_sequences
    ADD CONSTRAINT cc_sequences_pkey PRIMARY KEY (id);


--
-- Name: cc_statements cc_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_statements
    ADD CONSTRAINT cc_statements_pkey PRIMARY KEY (id);


--
-- Name: code_lists code_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_lists
    ADD CONSTRAINT code_lists_pkey PRIMARY KEY (id);


--
-- Name: codes codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT codes_pkey PRIMARY KEY (id);


--
-- Name: control_constructs control_constructs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT control_constructs_pkey PRIMARY KEY (id);


--
-- Name: datasets datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: categories encapsulate_unique_for_categories; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT encapsulate_unique_for_categories UNIQUE (id, instrument_id);


--
-- Name: code_lists encapsulate_unique_for_code_lists; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_lists
    ADD CONSTRAINT encapsulate_unique_for_code_lists UNIQUE (id, instrument_id);


--
-- Name: control_constructs encapsulate_unique_for_control_constructs; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT encapsulate_unique_for_control_constructs UNIQUE (construct_id, construct_type, instrument_id);


--
-- Name: control_constructs encapsulate_unique_for_control_constructs_internally; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT encapsulate_unique_for_control_constructs_internally UNIQUE (id, instrument_id);


--
-- Name: instructions encapsulate_unique_for_instructions; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructions
    ADD CONSTRAINT encapsulate_unique_for_instructions UNIQUE (id, instrument_id);


--
-- Name: response_units encapsulate_unique_for_response_units; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_units
    ADD CONSTRAINT encapsulate_unique_for_response_units UNIQUE (id, instrument_id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: instructions instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructions
    ADD CONSTRAINT instructions_pkey PRIMARY KEY (id);


--
-- Name: instruments_datasets instruments_datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets
    ADD CONSTRAINT instruments_datasets_pkey PRIMARY KEY (id);


--
-- Name: instruments instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments
    ADD CONSTRAINT instruments_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: question_grids question_grids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT question_grids_pkey PRIMARY KEY (id);


--
-- Name: question_items question_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_items
    ADD CONSTRAINT question_items_pkey PRIMARY KEY (id);


--
-- Name: rds_qs rds_qs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs
    ADD CONSTRAINT rds_qs_pkey PRIMARY KEY (id);


--
-- Name: response_domain_codes response_domain_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes
    ADD CONSTRAINT response_domain_codes_pkey PRIMARY KEY (id);


--
-- Name: response_domain_datetimes response_domain_datetimes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_datetimes
    ADD CONSTRAINT response_domain_datetimes_pkey PRIMARY KEY (id);


--
-- Name: response_domain_numerics response_domain_numerics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_numerics
    ADD CONSTRAINT response_domain_numerics_pkey PRIMARY KEY (id);


--
-- Name: response_domain_texts response_domain_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_texts
    ADD CONSTRAINT response_domain_texts_pkey PRIMARY KEY (id);


--
-- Name: response_units response_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_units
    ADD CONSTRAINT response_units_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: rds_qs unique_for_rd_order_within_question; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs
    ADD CONSTRAINT unique_for_rd_order_within_question UNIQUE (question_id, question_type, rd_order) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: variables variables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
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
-- Name: index_categories_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_label_and_instrument_id ON categories USING btree (label, instrument_id);


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
-- Name: index_code_lists_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_code_lists_on_label_and_instrument_id ON code_lists USING btree (label, instrument_id);


--
-- Name: index_codes_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_category_id ON codes USING btree (category_id);


--
-- Name: index_codes_on_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_code_list_id ON codes USING btree (code_list_id);


--
-- Name: index_codes_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_instrument_id ON codes USING btree (instrument_id);


--
-- Name: index_control_constructs_on_construct_type_and_construct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_construct_type_and_construct_id ON control_constructs USING btree (construct_type, construct_id);


--
-- Name: index_control_constructs_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_instrument_id ON control_constructs USING btree (instrument_id);


--
-- Name: index_control_constructs_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_control_constructs_on_label_and_instrument_id ON control_constructs USING btree (label, instrument_id);


--
-- Name: index_control_constructs_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_parent_id ON control_constructs USING btree (parent_id);


--
-- Name: index_documents_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_item_type_and_item_id ON documents USING btree (item_type, item_id);


--
-- Name: index_documents_on_md5_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_documents_on_md5_hash ON documents USING btree (md5_hash);


--
-- Name: index_instructions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instructions_on_instrument_id ON instructions USING btree (instrument_id);


--
-- Name: index_instructions_on_text_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_instructions_on_text_and_instrument_id ON instructions USING btree (text, instrument_id);


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
-- Name: index_maps_on_source_id_and_variable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_maps_on_source_id_and_variable_id ON maps USING btree (source_id, variable_id) WHERE ((source_type)::text = 'Variable'::text);


--
-- Name: index_maps_on_source_id_and_variable_id_and_x_and_y; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_maps_on_source_id_and_variable_id_and_x_and_y ON maps USING btree (source_id, variable_id, x, y) WHERE ((source_type)::text = 'Question'::text);


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
-- Name: index_question_grids_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_question_grids_on_label_and_instrument_id ON question_grids USING btree (label, instrument_id);


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
-- Name: index_question_items_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_question_items_on_label_and_instrument_id ON question_items USING btree (label, instrument_id);


--
-- Name: index_rds_qs_on_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_code_id ON rds_qs USING btree (code_id);


--
-- Name: index_rds_qs_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_instrument_id ON rds_qs USING btree (instrument_id);


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
-- Name: index_response_domain_codes_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_codes_on_instrument_id ON response_domain_codes USING btree (instrument_id);


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
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_group_id ON users USING btree (group_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


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
-- Name: cc_conditions encapsulate_cc_conditions_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_conditions
    ADD CONSTRAINT encapsulate_cc_conditions_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: cc_loops encapsulate_cc_loops_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_loops
    ADD CONSTRAINT encapsulate_cc_loops_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: cc_questions encapsulate_cc_questions_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_questions
    ADD CONSTRAINT encapsulate_cc_questions_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: cc_questions encapsulate_cc_questions_and_response_units; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_questions
    ADD CONSTRAINT encapsulate_cc_questions_and_response_units FOREIGN KEY (response_unit_id, instrument_id) REFERENCES response_units(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: cc_sequences encapsulate_cc_sequences_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_sequences
    ADD CONSTRAINT encapsulate_cc_sequences_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: cc_statements encapsulate_cc_statements_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cc_statements
    ADD CONSTRAINT encapsulate_cc_statements_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: codes encapsulate_codes_and_categories; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT encapsulate_codes_and_categories FOREIGN KEY (category_id, instrument_id) REFERENCES categories(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: codes encapsulate_codes_and_codes_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT encapsulate_codes_and_codes_lists FOREIGN KEY (code_list_id, instrument_id) REFERENCES code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: control_constructs encapsulate_control_constructs_to_its_self; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT encapsulate_control_constructs_to_its_self FOREIGN KEY (parent_id, instrument_id) REFERENCES control_constructs(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_grids encapsulate_question_grids_and_horizontal_code_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists FOREIGN KEY (horizontal_code_list_id, instrument_id) REFERENCES code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_grids encapsulate_question_grids_and_instructions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_instructions FOREIGN KEY (instruction_id, instrument_id) REFERENCES instructions(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_grids encapsulate_question_grids_and_vertical_code_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_vertical_code_lists FOREIGN KEY (vertical_code_list_id, instrument_id) REFERENCES code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_items encapsulate_question_items_and_instructions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_items
    ADD CONSTRAINT encapsulate_question_items_and_instructions FOREIGN KEY (instruction_id, instrument_id) REFERENCES instructions(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: codes fk_rails_1d78394359; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT fk_rails_1d78394359 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: instruments_datasets fk_rails_3d0d853840; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets
    ADD CONSTRAINT fk_rails_3d0d853840 FOREIGN KEY (dataset_id) REFERENCES datasets(id);


--
-- Name: response_domain_codes fk_rails_572ea44f7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes
    ADD CONSTRAINT fk_rails_572ea44f7b FOREIGN KEY (code_list_id) REFERENCES code_lists(id);


--
-- Name: topics fk_rails_5f3c091f12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT fk_rails_5f3c091f12 FOREIGN KEY (parent_id) REFERENCES topics(id);


--
-- Name: response_domain_codes fk_rails_948d561862; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes
    ADD CONSTRAINT fk_rails_948d561862 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: links fk_rails_9e38e93f70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT fk_rails_9e38e93f70 FOREIGN KEY (topic_id) REFERENCES topics(id);


--
-- Name: control_constructs fk_rails_aebc678501; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT fk_rails_aebc678501 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: maps fk_rails_ce690a0b27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps
    ADD CONSTRAINT fk_rails_ce690a0b27 FOREIGN KEY (variable_id) REFERENCES variables(id);


--
-- Name: instruments_datasets fk_rails_d7ce9bc772; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instruments_datasets
    ADD CONSTRAINT fk_rails_d7ce9bc772 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: codes fk_rails_db1a343fc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT fk_rails_db1a343fc8 FOREIGN KEY (code_list_id) REFERENCES code_lists(id);


--
-- Name: rds_qs fk_rails_e49dc1bfb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs
    ADD CONSTRAINT fk_rails_e49dc1bfb6 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: control_constructs fk_rails_f312241fda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT fk_rails_f312241fda FOREIGN KEY (parent_id) REFERENCES control_constructs(id);


--
-- Name: users fk_rails_f40b3f4da6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_f40b3f4da6 FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: codes fk_rails_f8e439e0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT fk_rails_f8e439e0d7 FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES
('20151129203547'),
('20151129204534'),
('20151129204903'),
('20151129205538'),
('20151129205758'),
('20151129210043'),
('20151130062018'),
('20151130062219'),
('20151130062608'),
('20151130063811'),
('20151130142555'),
('20151130143016'),
('20151130143420'),
('20151201094202'),
('20151201094926'),
('20151201095143'),
('20151201095347'),
('20151201095532'),
('20151201095541'),
('20151203122424'),
('20151204181052'),
('20151204193654'),
('20151206105535'),
('20151206110030'),
('20151206165407'),
('20151206165603'),
('20151206165726'),
('20151206185120'),
('20151206185659'),
('20151206205100'),
('20160121070958'),
('20160216154523'),
('20160413095800'),
('20160413100019'),
('20160419094600'),
('20160419165130'),
('20160603113436'),
('20160712131146'),
('20160716150053'),
('20160716164426'),
('20160805093216'),
('20160808100337'),
('20160913201152'),
('20160930113839'),
('20161027133806'),
('20161121112227'),
('20161209155519'),
('20161213091354'),
('20170302132603'),
('20170302132849');


