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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: count_rows(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.count_rows(schema text, tablename text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
  result integer;
  query varchar;
begin
  query := 'SELECT count(1) FROM ' || schema || '.' || tablename;
  execute query into result;
  return result;
end;
$$;


--
-- Name: delete_cc_condition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_cc_condition() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM links WHERE target_id = old.id AND target_type = 'CcCondition';
  DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcCondition';
  DELETE FROM conditions WHERE id = old.id;
  RETURN old;
END;
$$;


--
-- Name: delete_cc_loop(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_cc_loop() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM links WHERE target_id = old.id AND target_type = 'CcLoop';
  DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcLoop';
  DELETE FROM loops WHERE id = old.id;
  RETURN old;
END;
$$;


--
-- Name: delete_cc_question(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_cc_question() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM links WHERE target_id = old.id AND target_type = 'CcQuestion';
  DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcQuestion';
  DELETE FROM questions WHERE id = old.id;
  RETURN old;
END;
$$;


--
-- Name: delete_cc_sequence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_cc_sequence() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM links WHERE target_id = old.id AND target_type = 'CcSequence';
  DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcSequence';
  DELETE FROM sequences WHERE id = old.id;
  RETURN old;
END;
$$;


--
-- Name: delete_cc_statement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.delete_cc_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcStatement';
  DELETE FROM statements WHERE id = old.id;
  RETURN old;
END;
$$;


--
-- Name: insert_cc_condition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_cc_condition() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cond_id INTEGER;
BEGIN
  IF new.id IS NULL THEN
    INSERT INTO conditions(
                            instrument_id, 
                            literal, 
                            logic, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.instrument_id, 
                            new.literal, 
                            new.logic, 
                            new.created_at, 
                            new.updated_at
    ) RETURNING id INTO cond_id;
  ELSE
    INSERT INTO conditions(
                            id,
                            instrument_id, 
                            literal, 
                            logic, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.id,
                            new.instrument_id, 
                            new.literal, 
                            new.logic, 
                            new.created_at, 
                            new.updated_at
    );
    cond_id = new.id;
  END IF;
  INSERT INTO control_constructs(
                          label, 
                          parent_id, 
                          position, 
                          branch, 
                          construct_id,
                          construct_type,
                          instrument_id, 
                          created_at, 
                          updated_at
  )  VALUES (
                          new.label, 
                          (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
                          new.position, 
                          new.branch, 
                          cond_id,
                          'CcCondition',
                          new.instrument_id, 
                          new.created_at, 
                          new.updated_at
  );
  IF new.topic_id IS NOT NULL THEN
    INSERT INTO links(
                            target_id,
                            target_type,
                            topic_id,
                            created_at, 
                            updated_at
    ) VALUES (
                            cond_id,
                            'CcCondition',
                            new.topic_id, 
                            new.created_at, 
                            new.updated_at 
    );
  END IF;
  new.id = cond_id;
  RETURN new;
END;
$$;


--
-- Name: insert_cc_loop(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_cc_loop() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  loop_id INTEGER;
BEGIN
  IF new.id IS NULL THEN
    INSERT INTO loops(
                            instrument_id, 
                            loop_var, 
                            start_val, 
                            end_val, 
                            loop_while, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.instrument_id, 
                            new.loop_var, 
                            new.start_val, 
                            new.end_val, 
                            new.loop_while, 
                            new.created_at, 
                            new.updated_at
    ) RETURNING id INTO loop_id;
  ELSE
    INSERT INTO loops(
                            id,
                            instrument_id, 
                            loop_var, 
                            start_val, 
                            end_val, 
                            loop_while, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.id,
                            new.instrument_id, 
                            new.loop_var, 
                            new.start_val, 
                            new.end_val, 
                            new.loop_while, 
                            new.created_at, 
                            new.updated_at
    );
    loop_id = new.id;
  END IF;
  INSERT INTO control_constructs(
                          label, 
                          parent_id, 
                          position, 
                          branch, 
                          construct_id,
                          construct_type,
                          instrument_id, 
                          created_at, 
                          updated_at
  )  VALUES (
                          new.label, 
                          (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
                          new.position, 
                          new.branch, 
                          loop_id,
                          'CcLoop',
                          new.instrument_id, 
                          new.created_at, 
                          new.updated_at
  );
  IF new.topic_id IS NOT NULL THEN
    INSERT INTO links(
                            target_id,
                            target_type,
                            topic_id,
                            created_at, 
                            updated_at
    ) 
       VALUES (
                            loop_id,
                            'CcLoop',
                            new.topic_id, 
                            new.created_at, 
                            new.updated_at 
    );
  END IF;
  new.id = loop_id;
  RETURN new;
END;
$$;


--
-- Name: insert_cc_question(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_cc_question() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  quest_id INTEGER;
BEGIN
  IF new.id IS NULL THEN
    INSERT INTO questions(
                            instrument_id, 
                            question_id, 
                            question_type, 
                            response_unit_id, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.instrument_id, 
                            new.question_id, 
                            new.question_type, 
                            new.response_unit_id, 
                            new.created_at, 
                            new.updated_at
    ) RETURNING id INTO quest_id;
  ELSE
   INSERT INTO questions(
                            id,
                            instrument_id, 
                            question_id, 
                            question_type, 
                            response_unit_id, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.id,
                            new.instrument_id, 
                            new.question_id, 
                            new.question_type, 
                            new.response_unit_id, 
                            new.created_at, 
                            new.updated_at
    );
    quest_id = new.id;
  END IF;
  INSERT INTO control_constructs(
                          label, 
                          parent_id, 
                          position, 
                          branch, 
                          construct_id,
                          construct_type,
                          instrument_id, 
                          created_at, 
                          updated_at
  )  VALUES (
                          new.label, 
                          (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
                          new.position, 
                          new.branch, 
                          quest_id,
                          'CcQuestion',
                          new.instrument_id, 
                          new.created_at, 
                          new.updated_at
  );
  new.id = quest_id;
  RETURN new;
END;
$$;


--
-- Name: insert_cc_sequence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_cc_sequence() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  seq_id INTEGER;
BEGIN
  IF new.id IS NULL THEN
    INSERT INTO sequences(
                            instrument_id, 
                            literal, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.instrument_id, 
                            new.literal, 
                            new.created_at, 
                            new.updated_at
    ) RETURNING id INTO seq_id;
  ELSE
    INSERT INTO sequences(
                            id,
                            instrument_id, 
                            literal, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.id,
                            new.instrument_id, 
                            new.literal, 
                            new.created_at, 
                            new.updated_at
    );
    seq_id = new.id;
  END IF;
  INSERT INTO control_constructs(
                          label, 
                          parent_id, 
                          position, 
                          branch, 
                          construct_id,
                          construct_type,
                          instrument_id, 
                          created_at, 
                          updated_at
  )  VALUES (
                          new.label, 
                          (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
                          new.position, 
                          new.branch, 
                          seq_id,
                          'CcSequence',
                          new.instrument_id, 
                          new.created_at, 
                          new.updated_at
  );
  IF new.topic_id IS NOT NULL THEN
    INSERT INTO links(
                            target_id,
                            target_type,
                            topic_id,
                            created_at, 
                            updated_at
    ) 
       VALUES (
                            seq_id,
                            'CcSequence',
                            new.topic_id, 
                            new.created_at, 
                            new.updated_at 
    );
  END IF;
  new.id = seq_id;
  RETURN new;
END;
$$;


--
-- Name: insert_cc_statement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_cc_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  sta_id INTEGER;
BEGIN
  IF new.id IS NULL THEN 
    INSERT INTO statements(
                            instrument_id, 
                            literal, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.instrument_id, 
                            new.literal, 
                            new.created_at, 
                            new.updated_at
    ) RETURNING id INTO sta_id;
  ELSE
    INSERT INTO statements(
                            id,
                            instrument_id, 
                            literal, 
                            created_at, 
                            updated_at
    ) VALUES (
                            new.id,
                            new.instrument_id, 
                            new.literal, 
                            new.created_at, 
                            new.updated_at
    );
    sta_id = new.id;
  END IF;
  INSERT INTO control_constructs(
                          label, 
                          parent_id, 
                          position, 
                          branch, 
                          construct_id,
                          construct_type,
                          instrument_id, 
                          created_at, 
                          updated_at
  )  VALUES (
                          new.label, 
                          (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
                          new.position, 
                          new.branch, 
                          sta_id,
                          'CcStatement',
                          new.instrument_id, 
                          new.created_at, 
                          new.updated_at
  );
  new.id = sta_id;
  RETURN new;
END;
$$;


--
-- Name: update_cc_condition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cc_condition() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE conditions 
  SET
          literal     = new.literal, 
          logic       = new.logic, 
          updated_at  = new.updated_at
  WHERE id = new.id;
  UPDATE control_constructs 
  SET
          label       = new.label, 
          parent_id   = (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
          position    = new.position,
          branch      = new.branch, 
          updated_at = new.updated_at
  WHERE construct_id = new.id AND construct_type = 'CcCondition';
  IF new.topic_id <> old.topic_id THEN
    IF new.topic_id IS NULL THEN
      DELETE FROM links WHERE target_id = new.id AND target_type = 'CcCondition';
    ELSIF old.topic_id IS NULL THEN
      INSERT INTO links(
                            target_id,
                            target_type,
                            topic_id,
                            created_at, 
                            updated_at
      ) 
         VALUES (
                            new.id,
                            'CcCondition',
                            new.topic_id, 
                            new.created_at, 
                            new.updated_at 
      );
    ELSE
      UPDATE links SET topic_id = new.topic_id WHERE target_id = new.id AND target_type = 'CcCondition';
    END IF;
  END IF;
  RETURN new;
END;
$$;


--
-- Name: update_cc_loop(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cc_loop() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE loops 
  SET
          loop_var          = new.loop_var, 
          start_val         = new.start_val,
          end_val           = new.end_val,
          loop_while        = new.loop_while, 
          updated_at        = new.updated_at
  WHERE id = new.id;
  UPDATE control_constructs 
  SET
          label       = new.label, 
          parent_id   = (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
          position    = new.position,
          branch      = new.branch, 
          updated_at = new.updated_at
  WHERE construct_id = new.id AND construct_type = 'CcLoop';
  IF new.topic_id <> old.topic_id THEN
    IF new.topic_id IS NULL THEN
      DELETE FROM links WHERE target_id = new.id AND target_type = 'CcLoop';
    ELSIF old.topic_id IS NULL THEN
      INSERT INTO links(
                            target_id,
                            target_type,
                            topic_id,
                            created_at, 
                            updated_at
      ) 
         VALUES (
                            new.id,
                            'CcLoop',
                            new.topic_id, 
                            new.created_at, 
                            new.updated_at 
      );
    ELSE
      UPDATE links SET topic_id = new.topic_id WHERE target_id = new.id AND target_type = 'CcLoop';
    END IF;
  END IF;
  RETURN new;
END;
$$;


--
-- Name: update_cc_question(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cc_question() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE questions 
  SET
          question_id       = new.question_id, 
          question_type     = new.question_type,
          response_unit_id  = new.response_unit_id,
          updated_at        = new.updated_at
  WHERE id = new.id;
  UPDATE control_constructs 
  SET
          label       = new.label, 
          parent_id   = (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
          position    = new.position,
          branch      = new.branch, 
          updated_at = new.updated_at
  WHERE construct_id = new.id AND construct_type = 'CcQuestion';
  RETURN new;
END;
$$;


--
-- Name: update_cc_sequence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cc_sequence() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE sequences 
  SET
          literal           = new.literal, 
          updated_at        = new.updated_at
  WHERE id = new.id;
  UPDATE control_constructs 
  SET
          label       = new.label, 
          parent_id   = (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
          position    = new.position,
          branch      = new.branch, 
          updated_at = new.updated_at
  WHERE construct_id = new.id AND construct_type = 'CcSequence';
  IF new.topic_id <> old.topic_id THEN
    IF new.topic_id IS NULL THEN
      DELETE FROM links WHERE target_id = new.id AND target_type = 'CcSequence';
    ELSIF old.topic_id IS NULL THEN
      INSERT INTO links(
                            target_id,
                            target_type,
                            topic_id,
                            created_at, 
                            updated_at
      ) 
         VALUES (
                            new.id,
                            'CcSequence',
                            new.topic_id, 
                            new.created_at, 
                            new.updated_at 
      );
    ELSE
      UPDATE links SET topic_id = new.topic_id WHERE target_id = new.id AND target_type = 'CcSequence';
    END IF;
  END IF;
  RETURN new;
END;
$$;


--
-- Name: update_cc_statement(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cc_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE statements 
  SET
          literal           = new.literal, 
          updated_at        = new.updated_at
  WHERE id = new.id;
  UPDATE control_constructs 
  SET
          label       = new.label, 
          parent_id   = (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
          position    = new.position,
          branch      = new.branch, 
          updated_at = new.updated_at
  WHERE construct_id = new.id AND construct_type = 'CcStatement';
  RETURN new;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    label character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conditions (
    id integer NOT NULL,
    literal character varying,
    logic character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcCondition'::character varying
);


--
-- Name: control_constructs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_constructs (
    id integer NOT NULL,
    label character varying,
    construct_id integer NOT NULL,
    construct_type character varying NOT NULL,
    parent_id integer,
    "position" integer,
    branch integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.links (
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
-- Name: cc_conditions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cc_conditions AS
 SELECT con.id,
    con.instrument_id,
    con.literal,
    con.logic,
    con.created_at,
    con.updated_at,
    cc.label,
    parent.construct_id AS parent_id,
    parent.construct_type AS parent_type,
    cc."position",
    cc.branch,
    links.topic_id
   FROM (((public.conditions con
     JOIN public.control_constructs cc ON (((con.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcCondition'::text))))
     LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
     LEFT JOIN public.links ON (((con.id = links.target_id) AND ((links.target_type)::text = 'CcCondition'::text))))
  ORDER BY con.id;


--
-- Name: cc_links; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cc_links AS
 SELECT cc.id,
    cc.label,
    cc.construct_id,
    cc.construct_type,
    cc.parent_id,
    cc."position",
    cc.branch,
    cc.created_at,
    cc.updated_at,
    cc.instrument_id,
    l.topic_id
   FROM (public.control_constructs cc
     LEFT JOIN public.links l ON (((l.target_id = cc.construct_id) AND ((l.target_type)::text = (cc.construct_type)::text))))
  ORDER BY cc.id DESC;


--
-- Name: loops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loops (
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
-- Name: cc_loops; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cc_loops AS
 SELECT l.id,
    l.instrument_id,
    l.loop_var,
    l.start_val,
    l.end_val,
    l.loop_while,
    l.created_at,
    l.updated_at,
    cc.label,
    parent.construct_id AS parent_id,
    parent.construct_type AS parent_type,
    cc."position",
    cc.branch,
    links.topic_id
   FROM (((public.loops l
     JOIN public.control_constructs cc ON (((l.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcLoop'::text))))
     LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
     LEFT JOIN public.links ON (((l.id = links.target_id) AND ((links.target_type)::text = 'CcLoop'::text))))
  ORDER BY l.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id integer NOT NULL,
    question_id integer NOT NULL,
    question_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    response_unit_id integer NOT NULL,
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcQuestion'::character varying
);


--
-- Name: cc_questions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cc_questions AS
 SELECT q.id,
    q.instrument_id,
    q.question_id,
    q.question_type,
    q.response_unit_id,
    q.created_at,
    q.updated_at,
    cc.label,
    parent.construct_id AS parent_id,
    parent.construct_type AS parent_type,
    cc."position",
    cc.branch
   FROM ((public.questions q
     JOIN public.control_constructs cc ON (((q.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcQuestion'::text))))
     LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
  ORDER BY q.id;


--
-- Name: sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequences (
    id integer NOT NULL,
    literal character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcSequence'::character varying
);


--
-- Name: cc_sequences; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cc_sequences AS
 SELECT s.id,
    s.instrument_id,
    s.literal,
    s.created_at,
    s.updated_at,
    cc.label,
    parent.construct_id AS parent_id,
    parent.construct_type AS parent_type,
    cc."position",
    cc.branch,
    links.topic_id
   FROM (((public.sequences s
     JOIN public.control_constructs cc ON (((s.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcSequence'::text))))
     LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
     LEFT JOIN public.links ON (((s.id = links.target_id) AND ((links.target_type)::text = 'CcSequence'::text))))
  ORDER BY s.id;


--
-- Name: statements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statements (
    id integer NOT NULL,
    literal character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcStatement'::character varying
);


--
-- Name: cc_statements; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cc_statements AS
 SELECT s.id,
    s.instrument_id,
    s.literal,
    s.created_at,
    s.updated_at,
    cc.label,
    parent.construct_id AS parent_id,
    parent.construct_type AS parent_type,
    cc."position",
    cc.branch
   FROM ((public.statements s
     JOIN public.control_constructs cc ON (((s.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcStatement'::text))))
     LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
  ORDER BY s.id;


--
-- Name: code_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.code_lists (
    id integer NOT NULL,
    label character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: code_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.code_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: code_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.code_lists_id_seq OWNED BY public.code_lists.id;


--
-- Name: codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.codes (
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

CREATE SEQUENCE public.codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.codes_id_seq OWNED BY public.codes.id;


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conditions_id_seq OWNED BY public.conditions.id;


--
-- Name: control_constructs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.control_constructs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_constructs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.control_constructs_id_seq OWNED BY public.control_constructs.id;


--
-- Name: datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datasets (
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

CREATE SEQUENCE public.datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.datasets_id_seq OWNED BY public.datasets.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
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

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maps (
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
-- Name: variables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variables (
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

CREATE VIEW public.dv_mappings AS
 SELECT row_number() OVER () AS id,
    s.name AS source,
    v.name AS variable,
    v.dataset_id
   FROM ((public.maps m
     JOIN public.variables v ON ((m.variable_id = v.id)))
     JOIN public.variables s ON (((s.id = m.source_id) AND ((m.source_type)::text = 'Variable'::text))));


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id integer NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: item_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_groups (
    id integer NOT NULL,
    group_type integer,
    item_type character varying,
    label character varying,
    root_item_type character varying,
    root_item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: streamlined_groupings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.streamlined_groupings (
    id integer NOT NULL,
    item_group_id integer NOT NULL,
    item_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: groupings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.groupings AS
 SELECT sg.id,
    sg.item_id,
    g.item_type,
    sg.item_group_id,
    sg.created_at,
    sg.updated_at
   FROM (public.streamlined_groupings sg
     JOIN public.item_groups g ON ((sg.item_group_id = g.id)));


--
-- Name: identifiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identifiers (
    id integer NOT NULL,
    id_type character varying,
    value character varying,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: identifiers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.identifiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identifiers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.identifiers_id_seq OWNED BY public.identifiers.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imports (
    id integer NOT NULL,
    document_id integer,
    import_type character varying,
    dataset_id integer,
    state character varying,
    log text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer
);


--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imports_id_seq OWNED BY public.imports.id;


--
-- Name: instructions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instructions (
    id integer NOT NULL,
    text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instructions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instructions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instructions_id_seq OWNED BY public.instructions.id;


--
-- Name: instruments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instruments (
    id integer NOT NULL,
    agency character varying,
    version character varying,
    prefix character varying,
    label character varying,
    study character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying,
    signed_off boolean DEFAULT false
);


--
-- Name: instruments_datasets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instruments_datasets (
    id integer NOT NULL,
    instrument_id integer NOT NULL,
    dataset_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: instruments_datasets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instruments_datasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instruments_datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instruments_datasets_id_seq OWNED BY public.instruments_datasets.id;


--
-- Name: instruments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.instruments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instruments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.instruments_id_seq OWNED BY public.instruments.id;


--
-- Name: item_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_groups_id_seq OWNED BY public.item_groups.id;


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.links_id_seq OWNED BY public.links.id;


--
-- Name: loops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.loops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.loops_id_seq OWNED BY public.loops.id;


--
-- Name: maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maps_id_seq OWNED BY public.maps.id;


--
-- Name: question_grids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_grids (
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

CREATE SEQUENCE public.question_grids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_grids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.question_grids_id_seq OWNED BY public.question_grids.id;


--
-- Name: question_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_items (
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

CREATE SEQUENCE public.question_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.question_items_id_seq OWNED BY public.question_items.id;


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- Name: qv_mappings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.qv_mappings AS
 SELECT row_number() OVER () AS id,
    COALESCE(cc.label, '0'::character varying) AS question,
    v.name AS variable,
    m.x,
    m.y,
    qc.instrument_id,
    v.dataset_id
   FROM (((public.variables v
     LEFT JOIN public.maps m ON ((m.variable_id = v.id)))
     JOIN public.questions qc ON (((qc.id = m.source_id) AND ((m.source_type)::text = 'CcQuestion'::text))))
     JOIN public.control_constructs cc ON (((qc.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcQuestion'::text))));


--
-- Name: rds_qs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rds_qs (
    id integer NOT NULL,
    response_domain_id integer NOT NULL,
    response_domain_type character varying NOT NULL,
    question_id integer NOT NULL,
    question_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    code_id integer,
    instrument_id integer NOT NULL,
    rd_order integer
);


--
-- Name: rds_qs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rds_qs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rds_qs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rds_qs_id_seq OWNED BY public.rds_qs.id;


--
-- Name: response_domain_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_domain_codes (
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

CREATE SEQUENCE public.response_domain_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.response_domain_codes_id_seq OWNED BY public.response_domain_codes.id;


--
-- Name: response_domain_datetimes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_domain_datetimes (
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

CREATE SEQUENCE public.response_domain_datetimes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_datetimes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.response_domain_datetimes_id_seq OWNED BY public.response_domain_datetimes.id;


--
-- Name: response_domain_numerics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_domain_numerics (
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

CREATE SEQUENCE public.response_domain_numerics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_numerics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.response_domain_numerics_id_seq OWNED BY public.response_domain_numerics.id;


--
-- Name: response_domain_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_domain_texts (
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

CREATE SEQUENCE public.response_domain_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_domain_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.response_domain_texts_id_seq OWNED BY public.response_domain_texts.id;


--
-- Name: response_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.response_units (
    id integer NOT NULL,
    label character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL
);


--
-- Name: response_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.response_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: response_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.response_units_id_seq OWNED BY public.response_units.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sequences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sequences_id_seq OWNED BY public.sequences.id;


--
-- Name: statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.statements_id_seq OWNED BY public.statements.id;


--
-- Name: streamlined_groupings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.streamlined_groupings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: streamlined_groupings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.streamlined_groupings_id_seq OWNED BY public.streamlined_groupings.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topics (
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

CREATE SEQUENCE public.topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topics_id_seq OWNED BY public.topics.id;


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_groups (
    id integer NOT NULL,
    group_type character varying,
    label character varying,
    study character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_groups_id_seq OWNED BY public.user_groups.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
    locked_at timestamp without time zone,
    api_key character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: variables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.variables_id_seq OWNED BY public.variables.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: code_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_lists ALTER COLUMN id SET DEFAULT nextval('public.code_lists_id_seq'::regclass);


--
-- Name: codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes ALTER COLUMN id SET DEFAULT nextval('public.codes_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions ALTER COLUMN id SET DEFAULT nextval('public.conditions_id_seq'::regclass);


--
-- Name: control_constructs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_constructs ALTER COLUMN id SET DEFAULT nextval('public.control_constructs_id_seq'::regclass);


--
-- Name: datasets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datasets ALTER COLUMN id SET DEFAULT nextval('public.datasets_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: identifiers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identifiers ALTER COLUMN id SET DEFAULT nextval('public.identifiers_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports ALTER COLUMN id SET DEFAULT nextval('public.imports_id_seq'::regclass);


--
-- Name: instructions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instructions ALTER COLUMN id SET DEFAULT nextval('public.instructions_id_seq'::regclass);


--
-- Name: instruments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments ALTER COLUMN id SET DEFAULT nextval('public.instruments_id_seq'::regclass);


--
-- Name: instruments_datasets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments_datasets ALTER COLUMN id SET DEFAULT nextval('public.instruments_datasets_id_seq'::regclass);


--
-- Name: item_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_groups ALTER COLUMN id SET DEFAULT nextval('public.item_groups_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links ALTER COLUMN id SET DEFAULT nextval('public.links_id_seq'::regclass);


--
-- Name: loops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loops ALTER COLUMN id SET DEFAULT nextval('public.loops_id_seq'::regclass);


--
-- Name: maps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maps ALTER COLUMN id SET DEFAULT nextval('public.maps_id_seq'::regclass);


--
-- Name: question_grids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_grids ALTER COLUMN id SET DEFAULT nextval('public.question_grids_id_seq'::regclass);


--
-- Name: question_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_items ALTER COLUMN id SET DEFAULT nextval('public.question_items_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- Name: rds_qs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rds_qs ALTER COLUMN id SET DEFAULT nextval('public.rds_qs_id_seq'::regclass);


--
-- Name: response_domain_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_codes ALTER COLUMN id SET DEFAULT nextval('public.response_domain_codes_id_seq'::regclass);


--
-- Name: response_domain_datetimes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_datetimes ALTER COLUMN id SET DEFAULT nextval('public.response_domain_datetimes_id_seq'::regclass);


--
-- Name: response_domain_numerics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_numerics ALTER COLUMN id SET DEFAULT nextval('public.response_domain_numerics_id_seq'::regclass);


--
-- Name: response_domain_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_texts ALTER COLUMN id SET DEFAULT nextval('public.response_domain_texts_id_seq'::regclass);


--
-- Name: response_units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_units ALTER COLUMN id SET DEFAULT nextval('public.response_units_id_seq'::regclass);


--
-- Name: sequences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequences ALTER COLUMN id SET DEFAULT nextval('public.sequences_id_seq'::regclass);


--
-- Name: statements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statements ALTER COLUMN id SET DEFAULT nextval('public.statements_id_seq'::regclass);


--
-- Name: streamlined_groupings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streamlined_groupings ALTER COLUMN id SET DEFAULT nextval('public.streamlined_groupings_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics ALTER COLUMN id SET DEFAULT nextval('public.topics_id_seq'::regclass);


--
-- Name: user_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups ALTER COLUMN id SET DEFAULT nextval('public.user_groups_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: variables id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variables ALTER COLUMN id SET DEFAULT nextval('public.variables_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: conditions cc_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT cc_conditions_pkey PRIMARY KEY (id);


--
-- Name: loops cc_loops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loops
    ADD CONSTRAINT cc_loops_pkey PRIMARY KEY (id);


--
-- Name: questions cc_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT cc_questions_pkey PRIMARY KEY (id);


--
-- Name: sequences cc_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequences
    ADD CONSTRAINT cc_sequences_pkey PRIMARY KEY (id);


--
-- Name: statements cc_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statements
    ADD CONSTRAINT cc_statements_pkey PRIMARY KEY (id);


--
-- Name: code_lists code_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_lists
    ADD CONSTRAINT code_lists_pkey PRIMARY KEY (id);


--
-- Name: codes codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT codes_pkey PRIMARY KEY (id);


--
-- Name: control_constructs control_constructs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_constructs
    ADD CONSTRAINT control_constructs_pkey PRIMARY KEY (id);


--
-- Name: datasets datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: categories encapsulate_unique_for_categories; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT encapsulate_unique_for_categories UNIQUE (id, instrument_id);


--
-- Name: code_lists encapsulate_unique_for_code_lists; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.code_lists
    ADD CONSTRAINT encapsulate_unique_for_code_lists UNIQUE (id, instrument_id);


--
-- Name: control_constructs encapsulate_unique_for_control_constructs; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_constructs
    ADD CONSTRAINT encapsulate_unique_for_control_constructs UNIQUE (construct_id, construct_type, instrument_id);


--
-- Name: control_constructs encapsulate_unique_for_control_constructs_internally; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_constructs
    ADD CONSTRAINT encapsulate_unique_for_control_constructs_internally UNIQUE (id, instrument_id);


--
-- Name: instructions encapsulate_unique_for_instructions; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT encapsulate_unique_for_instructions UNIQUE (id, instrument_id);


--
-- Name: response_units encapsulate_unique_for_response_units; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_units
    ADD CONSTRAINT encapsulate_unique_for_response_units UNIQUE (id, instrument_id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: identifiers identifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identifiers
    ADD CONSTRAINT identifiers_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: instructions instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instructions
    ADD CONSTRAINT instructions_pkey PRIMARY KEY (id);


--
-- Name: instruments_datasets instruments_datasets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments_datasets
    ADD CONSTRAINT instruments_datasets_pkey PRIMARY KEY (id);


--
-- Name: instruments instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments
    ADD CONSTRAINT instruments_pkey PRIMARY KEY (id);


--
-- Name: item_groups item_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_groups
    ADD CONSTRAINT item_groups_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: question_grids question_grids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_grids
    ADD CONSTRAINT question_grids_pkey PRIMARY KEY (id);


--
-- Name: question_items question_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_items
    ADD CONSTRAINT question_items_pkey PRIMARY KEY (id);


--
-- Name: rds_qs rds_qs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rds_qs
    ADD CONSTRAINT rds_qs_pkey PRIMARY KEY (id);


--
-- Name: response_domain_codes response_domain_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_codes
    ADD CONSTRAINT response_domain_codes_pkey PRIMARY KEY (id);


--
-- Name: response_domain_datetimes response_domain_datetimes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_datetimes
    ADD CONSTRAINT response_domain_datetimes_pkey PRIMARY KEY (id);


--
-- Name: response_domain_numerics response_domain_numerics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_numerics
    ADD CONSTRAINT response_domain_numerics_pkey PRIMARY KEY (id);


--
-- Name: response_domain_texts response_domain_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_texts
    ADD CONSTRAINT response_domain_texts_pkey PRIMARY KEY (id);


--
-- Name: response_units response_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_units
    ADD CONSTRAINT response_units_pkey PRIMARY KEY (id);


--
-- Name: streamlined_groupings streamlined_groupings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streamlined_groupings
    ADD CONSTRAINT streamlined_groupings_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: rds_qs unique_for_rd_order_within_question; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rds_qs
    ADD CONSTRAINT unique_for_rd_order_within_question UNIQUE (question_id, question_type, rd_order) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: variables variables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT variables_pkey PRIMARY KEY (id);


--
-- Name: index_categories_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_instrument_id ON public.categories USING btree (instrument_id);


--
-- Name: index_categories_on_label; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_label ON public.categories USING btree (label);


--
-- Name: index_categories_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_label_and_instrument_id ON public.categories USING btree (label, instrument_id);


--
-- Name: index_cc_conditions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_conditions_on_instrument_id ON public.conditions USING btree (instrument_id);


--
-- Name: index_cc_loops_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_loops_on_instrument_id ON public.loops USING btree (instrument_id);


--
-- Name: index_cc_questions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_instrument_id ON public.questions USING btree (instrument_id);


--
-- Name: index_cc_questions_on_question_type_and_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_question_type_and_question_id ON public.questions USING btree (question_type, question_id);


--
-- Name: index_cc_questions_on_response_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_response_unit_id ON public.questions USING btree (response_unit_id);


--
-- Name: index_cc_sequences_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_sequences_on_instrument_id ON public.sequences USING btree (instrument_id);


--
-- Name: index_cc_statements_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_statements_on_instrument_id ON public.statements USING btree (instrument_id);


--
-- Name: index_code_lists_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_code_lists_on_instrument_id ON public.code_lists USING btree (instrument_id);


--
-- Name: index_code_lists_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_code_lists_on_label_and_instrument_id ON public.code_lists USING btree (label, instrument_id);


--
-- Name: index_codes_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_category_id ON public.codes USING btree (category_id);


--
-- Name: index_codes_on_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_code_list_id ON public.codes USING btree (code_list_id);


--
-- Name: index_codes_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_codes_on_instrument_id ON public.codes USING btree (instrument_id);


--
-- Name: index_control_constructs_on_construct_type_and_construct_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_construct_type_and_construct_id ON public.control_constructs USING btree (construct_type, construct_id);


--
-- Name: index_control_constructs_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_instrument_id ON public.control_constructs USING btree (instrument_id);


--
-- Name: index_control_constructs_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_control_constructs_on_label_and_instrument_id ON public.control_constructs USING btree (label, instrument_id);


--
-- Name: index_control_constructs_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_constructs_on_parent_id ON public.control_constructs USING btree (parent_id);


--
-- Name: index_documents_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_item_type_and_item_id ON public.documents USING btree (item_type, item_id);


--
-- Name: index_documents_on_md5_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_documents_on_md5_hash ON public.documents USING btree (md5_hash);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_type_and_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type_and_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_type, sluggable_id);


--
-- Name: index_identifiers_on_id_type_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_identifiers_on_id_type_and_value ON public.identifiers USING btree (id_type, value);


--
-- Name: index_identifiers_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identifiers_on_item_type_and_item_id ON public.identifiers USING btree (item_type, item_id);


--
-- Name: index_imports_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_imports_on_dataset_id ON public.imports USING btree (dataset_id);


--
-- Name: index_imports_on_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_imports_on_document_id ON public.imports USING btree (document_id);


--
-- Name: index_imports_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_imports_on_instrument_id ON public.imports USING btree (instrument_id);


--
-- Name: index_instructions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instructions_on_instrument_id ON public.instructions USING btree (instrument_id);


--
-- Name: index_instructions_on_text_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_instructions_on_text_and_instrument_id ON public.instructions USING btree (text, instrument_id);


--
-- Name: index_instruments_datasets_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_datasets_on_dataset_id ON public.instruments_datasets USING btree (dataset_id);


--
-- Name: index_instruments_datasets_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_instruments_datasets_on_instrument_id ON public.instruments_datasets USING btree (instrument_id);


--
-- Name: index_instruments_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_instruments_on_slug ON public.instruments USING btree (slug);


--
-- Name: index_item_groups_on_root_item_type_and_root_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_groups_on_root_item_type_and_root_item_id ON public.item_groups USING btree (root_item_type, root_item_id);


--
-- Name: index_links_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_target_type_and_target_id ON public.links USING btree (target_type, target_id);


--
-- Name: index_links_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_topic_id ON public.links USING btree (topic_id);


--
-- Name: index_maps_on_source_id_and_variable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_maps_on_source_id_and_variable_id ON public.maps USING btree (source_id, variable_id) WHERE ((source_type)::text = 'Variable'::text);


--
-- Name: index_maps_on_source_id_and_variable_id_and_x_and_y; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_maps_on_source_id_and_variable_id_and_x_and_y ON public.maps USING btree (source_id, variable_id, x, y) WHERE ((source_type)::text = 'Question'::text);


--
-- Name: index_maps_on_source_type_and_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_source_type_and_source_id ON public.maps USING btree (source_type, source_id);


--
-- Name: index_maps_on_variable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_variable_id ON public.maps USING btree (variable_id);


--
-- Name: index_question_grids_on_horizontal_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_horizontal_code_list_id ON public.question_grids USING btree (horizontal_code_list_id);


--
-- Name: index_question_grids_on_instruction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_instruction_id ON public.question_grids USING btree (instruction_id);


--
-- Name: index_question_grids_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_instrument_id ON public.question_grids USING btree (instrument_id);


--
-- Name: index_question_grids_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_question_grids_on_label_and_instrument_id ON public.question_grids USING btree (label, instrument_id);


--
-- Name: index_question_grids_on_vertical_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_grids_on_vertical_code_list_id ON public.question_grids USING btree (vertical_code_list_id);


--
-- Name: index_question_items_on_instruction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_items_on_instruction_id ON public.question_items USING btree (instruction_id);


--
-- Name: index_question_items_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_items_on_instrument_id ON public.question_items USING btree (instrument_id);


--
-- Name: index_question_items_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_question_items_on_label_and_instrument_id ON public.question_items USING btree (label, instrument_id);


--
-- Name: index_rds_qs_on_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_code_id ON public.rds_qs USING btree (code_id);


--
-- Name: index_rds_qs_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_instrument_id ON public.rds_qs USING btree (instrument_id);


--
-- Name: index_rds_qs_on_question_type_and_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_question_type_and_question_id ON public.rds_qs USING btree (question_type, question_id);


--
-- Name: index_rds_qs_on_response_domain_type_and_response_domain_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rds_qs_on_response_domain_type_and_response_domain_id ON public.rds_qs USING btree (response_domain_type, response_domain_id);


--
-- Name: index_response_domain_codes_on_code_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_codes_on_code_list_id ON public.response_domain_codes USING btree (code_list_id);


--
-- Name: index_response_domain_codes_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_codes_on_instrument_id ON public.response_domain_codes USING btree (instrument_id);


--
-- Name: index_response_domain_datetimes_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_datetimes_on_instrument_id ON public.response_domain_datetimes USING btree (instrument_id);


--
-- Name: index_response_domain_numerics_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_numerics_on_instrument_id ON public.response_domain_numerics USING btree (instrument_id);


--
-- Name: index_response_domain_texts_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_domain_texts_on_instrument_id ON public.response_domain_texts USING btree (instrument_id);


--
-- Name: index_response_units_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_response_units_on_instrument_id ON public.response_units USING btree (instrument_id);


--
-- Name: index_streamlined_groupings_on_item_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_streamlined_groupings_on_item_group_id ON public.streamlined_groupings USING btree (item_group_id);


--
-- Name: index_topics_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topics_on_parent_id ON public.topics USING btree (parent_id);


--
-- Name: index_users_on_api_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_api_key ON public.users USING btree (api_key);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_group_id ON public.users USING btree (group_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_variables_on_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_variables_on_dataset_id ON public.variables USING btree (dataset_id);


--
-- Name: index_variables_on_name_and_dataset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_variables_on_name_and_dataset_id ON public.variables USING btree (name, dataset_id);


--
-- Name: unique_linking; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_linking ON public.links USING btree (target_id, target_type, topic_id, x, y);


--
-- Name: unique_mapping; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_mapping ON public.maps USING btree (source_id, source_type, variable_id, x, y);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: groupings groupings_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE groupings_delete AS
    ON DELETE TO public.groupings DO INSTEAD  DELETE FROM public.streamlined_groupings
  WHERE (streamlined_groupings.id = old.id);


--
-- Name: groupings groupings_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE groupings_insert AS
    ON INSERT TO public.groupings DO INSTEAD  INSERT INTO public.streamlined_groupings (item_id, item_group_id, created_at, updated_at)
  VALUES (new.item_id, new.item_group_id, new.created_at, new.updated_at)
  RETURNING streamlined_groupings.id,
    streamlined_groupings.item_id,
    ( SELECT item_groups.item_type
           FROM public.item_groups
          WHERE (streamlined_groupings.item_group_id = item_groups.id)) AS item_type,
    streamlined_groupings.item_group_id,
    streamlined_groupings.created_at,
    streamlined_groupings.updated_at;


--
-- Name: cc_conditions delete_cc_condition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_condition INSTEAD OF DELETE ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.delete_cc_condition();


--
-- Name: cc_loops delete_cc_loop; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_loop INSTEAD OF DELETE ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.delete_cc_loop();


--
-- Name: cc_questions delete_cc_question; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_question INSTEAD OF DELETE ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.delete_cc_question();


--
-- Name: cc_sequences delete_cc_sequence; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_sequence INSTEAD OF DELETE ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.delete_cc_sequence();


--
-- Name: cc_statements delete_cc_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_statement INSTEAD OF DELETE ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.delete_cc_statement();


--
-- Name: cc_conditions insert_cc_condition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_condition INSTEAD OF INSERT ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.insert_cc_condition();


--
-- Name: cc_loops insert_cc_loop; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_loop INSTEAD OF INSERT ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.insert_cc_loop();


--
-- Name: cc_questions insert_cc_question; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_question INSTEAD OF INSERT ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.insert_cc_question();


--
-- Name: cc_sequences insert_cc_sequence; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_sequence INSTEAD OF INSERT ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.insert_cc_sequence();


--
-- Name: cc_statements insert_cc_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_statement INSTEAD OF INSERT ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.insert_cc_statement();


--
-- Name: cc_conditions update_cc_condition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_condition INSTEAD OF UPDATE ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.update_cc_condition();


--
-- Name: cc_loops update_cc_loop; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_loop INSTEAD OF UPDATE ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.update_cc_loop();


--
-- Name: cc_questions update_cc_question; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_question INSTEAD OF UPDATE ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.update_cc_question();


--
-- Name: cc_sequences update_cc_seqeunce; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_seqeunce INSTEAD OF UPDATE ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.update_cc_sequence();


--
-- Name: cc_statements update_cc_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_statement INSTEAD OF UPDATE ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.update_cc_statement();


--
-- Name: conditions encapsulate_cc_conditions_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conditions
    ADD CONSTRAINT encapsulate_cc_conditions_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES public.control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: loops encapsulate_cc_loops_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loops
    ADD CONSTRAINT encapsulate_cc_loops_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES public.control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: questions encapsulate_cc_questions_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT encapsulate_cc_questions_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES public.control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: questions encapsulate_cc_questions_and_response_units; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT encapsulate_cc_questions_and_response_units FOREIGN KEY (response_unit_id, instrument_id) REFERENCES public.response_units(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: sequences encapsulate_cc_sequences_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequences
    ADD CONSTRAINT encapsulate_cc_sequences_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES public.control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: statements encapsulate_cc_statements_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statements
    ADD CONSTRAINT encapsulate_cc_statements_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES public.control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: codes encapsulate_codes_and_categories; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT encapsulate_codes_and_categories FOREIGN KEY (category_id, instrument_id) REFERENCES public.categories(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: codes encapsulate_codes_and_codes_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT encapsulate_codes_and_codes_lists FOREIGN KEY (code_list_id, instrument_id) REFERENCES public.code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: control_constructs encapsulate_control_constructs_to_its_self; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_constructs
    ADD CONSTRAINT encapsulate_control_constructs_to_its_self FOREIGN KEY (parent_id, instrument_id) REFERENCES public.control_constructs(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_grids encapsulate_question_grids_and_horizontal_code_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists FOREIGN KEY (horizontal_code_list_id, instrument_id) REFERENCES public.code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_grids encapsulate_question_grids_and_instructions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_instructions FOREIGN KEY (instruction_id, instrument_id) REFERENCES public.instructions(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_grids encapsulate_question_grids_and_vertical_code_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_vertical_code_lists FOREIGN KEY (vertical_code_list_id, instrument_id) REFERENCES public.code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: question_items encapsulate_question_items_and_instructions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_items
    ADD CONSTRAINT encapsulate_question_items_and_instructions FOREIGN KEY (instruction_id, instrument_id) REFERENCES public.instructions(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: codes fk_rails_1d78394359; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT fk_rails_1d78394359 FOREIGN KEY (instrument_id) REFERENCES public.instruments(id);


--
-- Name: variables fk_rails_33f3b47104; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT fk_rails_33f3b47104 FOREIGN KEY (dataset_id) REFERENCES public.datasets(id);


--
-- Name: instruments_datasets fk_rails_3d0d853840; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments_datasets
    ADD CONSTRAINT fk_rails_3d0d853840 FOREIGN KEY (dataset_id) REFERENCES public.datasets(id);


--
-- Name: response_domain_codes fk_rails_572ea44f7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_codes
    ADD CONSTRAINT fk_rails_572ea44f7b FOREIGN KEY (code_list_id) REFERENCES public.code_lists(id);


--
-- Name: topics fk_rails_5f3c091f12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT fk_rails_5f3c091f12 FOREIGN KEY (parent_id) REFERENCES public.topics(id);


--
-- Name: response_domain_codes fk_rails_948d561862; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.response_domain_codes
    ADD CONSTRAINT fk_rails_948d561862 FOREIGN KEY (instrument_id) REFERENCES public.instruments(id);


--
-- Name: links fk_rails_9e38e93f70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT fk_rails_9e38e93f70 FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: control_constructs fk_rails_aebc678501; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_constructs
    ADD CONSTRAINT fk_rails_aebc678501 FOREIGN KEY (instrument_id) REFERENCES public.instruments(id);


--
-- Name: imports fk_rails_b78b46b8f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_rails_b78b46b8f1 FOREIGN KEY (dataset_id) REFERENCES public.datasets(id);


--
-- Name: maps fk_rails_ce690a0b27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT fk_rails_ce690a0b27 FOREIGN KEY (variable_id) REFERENCES public.variables(id);


--
-- Name: streamlined_groupings fk_rails_d75780fc8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streamlined_groupings
    ADD CONSTRAINT fk_rails_d75780fc8c FOREIGN KEY (item_group_id) REFERENCES public.item_groups(id);


--
-- Name: instruments_datasets fk_rails_d7ce9bc772; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instruments_datasets
    ADD CONSTRAINT fk_rails_d7ce9bc772 FOREIGN KEY (instrument_id) REFERENCES public.instruments(id);


--
-- Name: codes fk_rails_db1a343fc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT fk_rails_db1a343fc8 FOREIGN KEY (code_list_id) REFERENCES public.code_lists(id);


--
-- Name: rds_qs fk_rails_e49dc1bfb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rds_qs
    ADD CONSTRAINT fk_rails_e49dc1bfb6 FOREIGN KEY (instrument_id) REFERENCES public.instruments(id);


--
-- Name: control_constructs fk_rails_f312241fda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_constructs
    ADD CONSTRAINT fk_rails_f312241fda FOREIGN KEY (parent_id) REFERENCES public.control_constructs(id);


--
-- Name: users fk_rails_f40b3f4da6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_f40b3f4da6 FOREIGN KEY (group_id) REFERENCES public.user_groups(id);


--
-- Name: codes fk_rails_f8e439e0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codes
    ADD CONSTRAINT fk_rails_f8e439e0d7 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: imports fk_rails_fcc3f98dc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_rails_fcc3f98dc1 FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
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
('20151211153924'),
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
('20170302132849'),
('20170505135010'),
('20170517105644'),
('20170517153047'),
('20170519102218'),
('20170525155249'),
('20170601154431'),
('20170605112157'),
('20171124115905'),
('20171212182936'),
('20181106140729'),
('20190812092806'),
('20190812092819'),
('20190813092806'),
('20190829124508'),
('20190905215804'),
('20201021193720');


