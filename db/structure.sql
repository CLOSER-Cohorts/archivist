--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.11
-- Dumped by pg_dump version 9.5.11

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

--
-- Name: delete_cc_condition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_cc_condition() RETURNS trigger
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

CREATE FUNCTION delete_cc_loop() RETURNS trigger
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

CREATE FUNCTION delete_cc_question() RETURNS trigger
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

CREATE FUNCTION delete_cc_sequence() RETURNS trigger
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

CREATE FUNCTION delete_cc_statement() RETURNS trigger
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

CREATE FUNCTION insert_cc_condition() RETURNS trigger
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

CREATE FUNCTION insert_cc_loop() RETURNS trigger
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

CREATE FUNCTION insert_cc_question() RETURNS trigger
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

CREATE FUNCTION insert_cc_sequence() RETURNS trigger
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

CREATE FUNCTION insert_cc_statement() RETURNS trigger
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
-- Name: refresh_ancestral_topics(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION refresh_ancestral_topics() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  REFRESH MATERIALIZED VIEW ancestral_topic;
  RETURN NULL;
END;
$$;


--
-- Name: update_cc_condition(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_cc_condition() RETURNS trigger
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

CREATE FUNCTION update_cc_loop() RETURNS trigger
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

CREATE FUNCTION update_cc_question() RETURNS trigger
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

CREATE FUNCTION update_cc_sequence() RETURNS trigger
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

CREATE FUNCTION update_cc_statement() RETURNS trigger
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

SET default_with_oids = false;

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
-- Name: cc_links; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW cc_links AS
 SELECT cc.id,
    cc.label,
    cc.construct_type,
    cc.construct_id,
    cc.parent_id,
    cc."position",
    cc.branch,
    cc.created_at,
    cc.updated_at,
    cc.instrument_id,
    l.topic_id
   FROM (control_constructs cc
     LEFT JOIN links l ON (((l.target_id = cc.construct_id) AND ((l.target_type)::text = (cc.construct_type)::text))))
  ORDER BY cc.id DESC;


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
-- Name: ancestral_topic; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW ancestral_topic AS
 WITH RECURSIVE cc_tree AS (
         SELECT ccl.id,
            ccl.label,
            ccl.construct_type,
            ccl.construct_id,
            ccl.parent_id,
            ccl."position",
            ccl.branch,
            ccl.created_at,
            ccl.updated_at,
            ccl.instrument_id,
            ccl.topic_id,
            1 AS level
           FROM cc_links ccl
        UNION ALL
         SELECT ccl.id,
            ccl.label,
            ccl.construct_type,
            ccl.construct_id,
            ccl.parent_id,
            ccl."position",
            ccl.branch,
            ccl.created_at,
            ccl.updated_at,
            ccl.instrument_id,
            ccl.topic_id,
            (tree_1.level + 1)
           FROM (cc_links ccl
             JOIN cc_tree tree_1 ON ((tree_1.parent_id = ccl.id)))
        )
 SELECT t.id,
    t.name,
    t.parent_id,
    t.code,
    t.created_at,
    t.updated_at,
    t.description,
    tree.construct_id,
    tree.construct_type
   FROM (cc_tree tree
     JOIN topics t ON ((tree.topic_id = t.id)))
  WHERE (tree.topic_id IS NOT NULL)
  ORDER BY tree.level
  WITH NO DATA;


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
-- Name: conditions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE conditions (
    id integer NOT NULL,
    literal character varying,
    logic character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    instrument_id integer NOT NULL,
    construct_type character varying DEFAULT 'CcCondition'::character varying
);


--
-- Name: cc_conditions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW cc_conditions AS
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
   FROM (((conditions con
     JOIN control_constructs cc ON (((con.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcCondition'::text))))
     LEFT JOIN control_constructs parent ON ((cc.parent_id = parent.id)))
     LEFT JOIN links ON (((con.id = links.target_id) AND ((links.target_type)::text = 'CcCondition'::text))))
  ORDER BY con.id;


--
-- Name: loops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE loops (
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

CREATE VIEW cc_loops AS
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
   FROM (((loops l
     JOIN control_constructs cc ON (((l.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcLoop'::text))))
     LEFT JOIN control_constructs parent ON ((cc.parent_id = parent.id)))
     LEFT JOIN links ON (((l.id = links.target_id) AND ((links.target_type)::text = 'CcLoop'::text))))
  ORDER BY l.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE questions (
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
-- Name: cc_questions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW cc_questions AS
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
   FROM ((questions q
     JOIN control_constructs cc ON (((q.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcQuestion'::text))))
     LEFT JOIN control_constructs parent ON ((cc.parent_id = parent.id)))
  ORDER BY q.id;


--
-- Name: sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sequences (
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

CREATE VIEW cc_sequences AS
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
   FROM (((sequences s
     JOIN control_constructs cc ON (((s.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcSequence'::text))))
     LEFT JOIN control_constructs parent ON ((cc.parent_id = parent.id)))
     LEFT JOIN links ON (((s.id = links.target_id) AND ((links.target_type)::text = 'CcSequence'::text))))
  ORDER BY s.id;


--
-- Name: statements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE statements (
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

CREATE VIEW cc_statements AS
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
   FROM ((statements s
     JOIN control_constructs cc ON (((s.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcStatement'::text))))
     LEFT JOIN control_constructs parent ON ((cc.parent_id = parent.id)))
  ORDER BY s.id;


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
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conditions_id_seq OWNED BY conditions.id;


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
-- Name: item_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE item_groups (
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

CREATE TABLE streamlined_groupings (
    id integer NOT NULL,
    item_group_id integer NOT NULL,
    item_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: groupings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW groupings AS
 SELECT sg.id,
    sg.item_id,
    g.item_type,
    sg.item_group_id,
    sg.created_at,
    sg.updated_at
   FROM (streamlined_groupings sg
     JOIN item_groups g ON ((sg.item_group_id = g.id)));


--
-- Name: identifiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE identifiers (
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

CREATE SEQUENCE identifiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identifiers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE identifiers_id_seq OWNED BY identifiers.id;


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
-- Name: item_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE item_groups_id_seq OWNED BY item_groups.id;


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
-- Name: loops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loops_id_seq OWNED BY loops.id;


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
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questions_id_seq OWNED BY questions.id;


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
     JOIN questions qc ON (((qc.id = m.source_id) AND ((m.source_type)::text = 'CcQuestion'::text))))
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
-- Name: sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sequences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sequences_id_seq OWNED BY sequences.id;


--
-- Name: statements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE statements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE statements_id_seq OWNED BY statements.id;


--
-- Name: streamlined_groupings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE streamlined_groupings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: streamlined_groupings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE streamlined_groupings_id_seq OWNED BY streamlined_groupings.id;


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
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_groups (
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

CREATE SEQUENCE user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_groups_id_seq OWNED BY user_groups.id;


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
    locked_at timestamp without time zone,
    api_key character varying
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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


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

ALTER TABLE ONLY conditions ALTER COLUMN id SET DEFAULT nextval('conditions_id_seq'::regclass);


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

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY identifiers ALTER COLUMN id SET DEFAULT nextval('identifiers_id_seq'::regclass);


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

ALTER TABLE ONLY item_groups ALTER COLUMN id SET DEFAULT nextval('item_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY links ALTER COLUMN id SET DEFAULT nextval('links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loops ALTER COLUMN id SET DEFAULT nextval('loops_id_seq'::regclass);


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

ALTER TABLE ONLY questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


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

ALTER TABLE ONLY sequences ALTER COLUMN id SET DEFAULT nextval('sequences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY statements ALTER COLUMN id SET DEFAULT nextval('statements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY streamlined_groupings ALTER COLUMN id SET DEFAULT nextval('streamlined_groupings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_groups ALTER COLUMN id SET DEFAULT nextval('user_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY variables ALTER COLUMN id SET DEFAULT nextval('variables_id_seq'::regclass);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: cc_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT cc_conditions_pkey PRIMARY KEY (id);


--
-- Name: cc_loops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loops
    ADD CONSTRAINT cc_loops_pkey PRIMARY KEY (id);


--
-- Name: cc_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT cc_questions_pkey PRIMARY KEY (id);


--
-- Name: cc_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sequences
    ADD CONSTRAINT cc_sequences_pkey PRIMARY KEY (id);


--
-- Name: cc_statements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY statements
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
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: encapsulate_unique_for_categories; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT encapsulate_unique_for_categories UNIQUE (id, instrument_id);


--
-- Name: encapsulate_unique_for_code_lists; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY code_lists
    ADD CONSTRAINT encapsulate_unique_for_code_lists UNIQUE (id, instrument_id);


--
-- Name: encapsulate_unique_for_control_constructs; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT encapsulate_unique_for_control_constructs UNIQUE (construct_id, construct_type, instrument_id);


--
-- Name: encapsulate_unique_for_control_constructs_internally; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT encapsulate_unique_for_control_constructs_internally UNIQUE (id, instrument_id);


--
-- Name: encapsulate_unique_for_instructions; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY instructions
    ADD CONSTRAINT encapsulate_unique_for_instructions UNIQUE (id, instrument_id);


--
-- Name: encapsulate_unique_for_response_units; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_units
    ADD CONSTRAINT encapsulate_unique_for_response_units UNIQUE (id, instrument_id);


--
-- Name: identifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY identifiers
    ADD CONSTRAINT identifiers_pkey PRIMARY KEY (id);


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
-- Name: item_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_groups
    ADD CONSTRAINT item_groups_pkey PRIMARY KEY (id);


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
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: streamlined_groupings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY streamlined_groupings
    ADD CONSTRAINT streamlined_groupings_pkey PRIMARY KEY (id);


--
-- Name: topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: unique_for_rd_order_within_question; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs
    ADD CONSTRAINT unique_for_rd_order_within_question UNIQUE (question_id, question_type, rd_order) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


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
-- Name: index_categories_on_label_and_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_label_and_instrument_id ON categories USING btree (label, instrument_id);


--
-- Name: index_cc_conditions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_conditions_on_instrument_id ON conditions USING btree (instrument_id);


--
-- Name: index_cc_loops_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_loops_on_instrument_id ON loops USING btree (instrument_id);


--
-- Name: index_cc_questions_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_instrument_id ON questions USING btree (instrument_id);


--
-- Name: index_cc_questions_on_question_type_and_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_question_type_and_question_id ON questions USING btree (question_type, question_id);


--
-- Name: index_cc_questions_on_response_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_questions_on_response_unit_id ON questions USING btree (response_unit_id);


--
-- Name: index_cc_sequences_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_sequences_on_instrument_id ON sequences USING btree (instrument_id);


--
-- Name: index_cc_statements_on_instrument_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cc_statements_on_instrument_id ON statements USING btree (instrument_id);


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
-- Name: index_identifiers_on_id_type_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_identifiers_on_id_type_and_value ON identifiers USING btree (id_type, value);


--
-- Name: index_identifiers_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identifiers_on_item_type_and_item_id ON identifiers USING btree (item_type, item_id);


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
-- Name: index_item_groups_on_root_item_type_and_root_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_groups_on_root_item_type_and_root_item_id ON item_groups USING btree (root_item_type, root_item_id);


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
-- Name: index_streamlined_groupings_on_item_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_streamlined_groupings_on_item_group_id ON streamlined_groupings USING btree (item_group_id);


--
-- Name: index_topics_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topics_on_parent_id ON topics USING btree (parent_id);


--
-- Name: index_users_on_api_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_api_key ON users USING btree (api_key);


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
-- Name: groupings_delete; Type: RULE; Schema: public; Owner: -
--

CREATE RULE groupings_delete AS
    ON DELETE TO groupings DO INSTEAD  DELETE FROM streamlined_groupings
  WHERE (streamlined_groupings.id = old.id);


--
-- Name: groupings_insert; Type: RULE; Schema: public; Owner: -
--

CREATE RULE groupings_insert AS
    ON INSERT TO groupings DO INSTEAD  INSERT INTO streamlined_groupings (item_id, item_group_id, created_at, updated_at)
  VALUES (new.item_id, new.item_group_id, new.created_at, new.updated_at)
  RETURNING streamlined_groupings.id,
    streamlined_groupings.item_id,
    ( SELECT item_groups.item_type
           FROM item_groups
          WHERE (streamlined_groupings.item_group_id = item_groups.id)) AS item_type,
    streamlined_groupings.item_group_id,
    streamlined_groupings.created_at,
    streamlined_groupings.updated_at;


--
-- Name: delete_cc_condition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_condition INSTEAD OF DELETE ON cc_conditions FOR EACH ROW EXECUTE PROCEDURE delete_cc_condition();


--
-- Name: delete_cc_loop; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_loop INSTEAD OF DELETE ON cc_loops FOR EACH ROW EXECUTE PROCEDURE delete_cc_loop();


--
-- Name: delete_cc_question; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_question INSTEAD OF DELETE ON cc_questions FOR EACH ROW EXECUTE PROCEDURE delete_cc_question();


--
-- Name: delete_cc_sequence; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_sequence INSTEAD OF DELETE ON cc_sequences FOR EACH ROW EXECUTE PROCEDURE delete_cc_sequence();


--
-- Name: delete_cc_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_cc_statement INSTEAD OF DELETE ON cc_statements FOR EACH ROW EXECUTE PROCEDURE delete_cc_statement();


--
-- Name: insert_cc_condition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_condition INSTEAD OF INSERT ON cc_conditions FOR EACH ROW EXECUTE PROCEDURE insert_cc_condition();


--
-- Name: insert_cc_loop; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_loop INSTEAD OF INSERT ON cc_loops FOR EACH ROW EXECUTE PROCEDURE insert_cc_loop();


--
-- Name: insert_cc_question; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_question INSTEAD OF INSERT ON cc_questions FOR EACH ROW EXECUTE PROCEDURE insert_cc_question();


--
-- Name: insert_cc_sequence; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_sequence INSTEAD OF INSERT ON cc_sequences FOR EACH ROW EXECUTE PROCEDURE insert_cc_sequence();


--
-- Name: insert_cc_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_cc_statement INSTEAD OF INSERT ON cc_statements FOR EACH ROW EXECUTE PROCEDURE insert_cc_statement();


--
-- Name: update_cc_condition; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_condition INSTEAD OF UPDATE ON cc_conditions FOR EACH ROW EXECUTE PROCEDURE update_cc_condition();


--
-- Name: update_cc_loop; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_loop INSTEAD OF UPDATE ON cc_loops FOR EACH ROW EXECUTE PROCEDURE update_cc_loop();


--
-- Name: update_cc_question; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_question INSTEAD OF UPDATE ON cc_questions FOR EACH ROW EXECUTE PROCEDURE update_cc_question();


--
-- Name: update_cc_seqeunce; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_seqeunce INSTEAD OF UPDATE ON cc_sequences FOR EACH ROW EXECUTE PROCEDURE update_cc_sequence();


--
-- Name: update_cc_statement; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_cc_statement INSTEAD OF UPDATE ON cc_statements FOR EACH ROW EXECUTE PROCEDURE update_cc_statement();


--
-- Name: update_links; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_links AFTER INSERT OR DELETE OR UPDATE OR TRUNCATE ON links FOR EACH STATEMENT EXECUTE PROCEDURE refresh_ancestral_topics();


--
-- Name: encapsulate_cc_conditions_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT encapsulate_cc_conditions_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_cc_loops_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loops
    ADD CONSTRAINT encapsulate_cc_loops_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_cc_questions_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT encapsulate_cc_questions_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_cc_questions_and_response_units; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT encapsulate_cc_questions_and_response_units FOREIGN KEY (response_unit_id, instrument_id) REFERENCES response_units(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_cc_sequences_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sequences
    ADD CONSTRAINT encapsulate_cc_sequences_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_cc_statements_and_control_constructs; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY statements
    ADD CONSTRAINT encapsulate_cc_statements_and_control_constructs FOREIGN KEY (id, construct_type, instrument_id) REFERENCES control_constructs(construct_id, construct_type, instrument_id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_codes_and_categories; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT encapsulate_codes_and_categories FOREIGN KEY (category_id, instrument_id) REFERENCES categories(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_codes_and_codes_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT encapsulate_codes_and_codes_lists FOREIGN KEY (code_list_id, instrument_id) REFERENCES code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_control_constructs_to_its_self; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT encapsulate_control_constructs_to_its_self FOREIGN KEY (parent_id, instrument_id) REFERENCES control_constructs(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_question_grids_and_horizontal_code_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_horizontal_code_lists FOREIGN KEY (horizontal_code_list_id, instrument_id) REFERENCES code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_question_grids_and_instructions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_instructions FOREIGN KEY (instruction_id, instrument_id) REFERENCES instructions(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_question_grids_and_vertical_code_lists; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_grids
    ADD CONSTRAINT encapsulate_question_grids_and_vertical_code_lists FOREIGN KEY (vertical_code_list_id, instrument_id) REFERENCES code_lists(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: encapsulate_question_items_and_instructions; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_items
    ADD CONSTRAINT encapsulate_question_items_and_instructions FOREIGN KEY (instruction_id, instrument_id) REFERENCES instructions(id, instrument_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: fk_rails_1d78394359; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT fk_rails_1d78394359 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


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
-- Name: fk_rails_948d561862; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY response_domain_codes
    ADD CONSTRAINT fk_rails_948d561862 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: fk_rails_9e38e93f70; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY links
    ADD CONSTRAINT fk_rails_9e38e93f70 FOREIGN KEY (topic_id) REFERENCES topics(id);


--
-- Name: fk_rails_aebc678501; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT fk_rails_aebc678501 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: fk_rails_ce690a0b27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps
    ADD CONSTRAINT fk_rails_ce690a0b27 FOREIGN KEY (variable_id) REFERENCES variables(id);


--
-- Name: fk_rails_d75780fc8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY streamlined_groupings
    ADD CONSTRAINT fk_rails_d75780fc8c FOREIGN KEY (item_group_id) REFERENCES item_groups(id);


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
-- Name: fk_rails_e49dc1bfb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rds_qs
    ADD CONSTRAINT fk_rails_e49dc1bfb6 FOREIGN KEY (instrument_id) REFERENCES instruments(id);


--
-- Name: fk_rails_f312241fda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_constructs
    ADD CONSTRAINT fk_rails_f312241fda FOREIGN KEY (parent_id) REFERENCES control_constructs(id);


--
-- Name: fk_rails_f40b3f4da6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_f40b3f4da6 FOREIGN KEY (group_id) REFERENCES user_groups(id);


--
-- Name: fk_rails_f8e439e0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY codes
    ADD CONSTRAINT fk_rails_f8e439e0d7 FOREIGN KEY (category_id) REFERENCES categories(id);


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
('20171212182936');


