class AddSlugsForConstructs < ActiveRecord::Migration[6.1]
  def up

    execute "DROP VIEW IF EXISTS public.cc_conditions CASCADE;"

    # Recreate cc_conditions with ddi_slug     
    execute %Q|
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
       cc.ddi_slug,
       cc."position",
       cc.branch,
       links.topic_id
      FROM (((public.conditions con
        JOIN public.control_constructs cc ON (((con.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcCondition'::text))))
        LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
        LEFT JOIN public.links ON (((con.id = links.target_id) AND ((links.target_type)::text = 'CcCondition'::text))))
     ORDER BY con.id;
    |    

    execute "DROP VIEW IF EXISTS public.cc_links CASCADE;"

    # Recreate cc_links with ddi_slug     
    execute %Q|
    CREATE VIEW public.cc_links AS
    SELECT cc.id,
       cc.label,
       cc.construct_id,
       cc.construct_type,
       cc.parent_id,
       cc.ddi_slug,
       cc."position",
       cc.branch,
       cc.created_at,
       cc.updated_at,
       cc.instrument_id,
       l.topic_id
      FROM (public.control_constructs cc
        LEFT JOIN public.links l ON (((l.target_id = cc.construct_id) AND ((l.target_type)::text = (cc.construct_type)::text))))
     ORDER BY cc.id DESC;
    |       

    execute "DROP VIEW IF EXISTS public.cc_loops CASCADE;"

    # Recreate cc_loops with ddi_slug
    execute %Q|
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
       cc.ddi_slug,
       cc."position",
       cc.branch,
       links.topic_id
      FROM (((public.loops l
        JOIN public.control_constructs cc ON (((l.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcLoop'::text))))
        LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
        LEFT JOIN public.links ON (((l.id = links.target_id) AND ((links.target_type)::text = 'CcLoop'::text))))
     ORDER BY l.id;
    |

    execute "DROP VIEW IF EXISTS public.cc_questions CASCADE;"

    # Recreate cc_questions with ddi_slug
    execute %Q|
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
       cc.ddi_slug,
       cc."position",
       cc.branch
      FROM ((public.questions q
        JOIN public.control_constructs cc ON (((q.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcQuestion'::text))))
        LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
     ORDER BY q.id;
    |

    execute "DROP VIEW IF EXISTS public.cc_statements CASCADE;"

    # Recreate cc_statements with ddi_slug
    execute %Q|
      CREATE VIEW public.cc_statements AS
      SELECT s.id,
         s.instrument_id,
         s.literal,
         s.created_at,
         s.updated_at,
         cc.label,
         parent.construct_id AS parent_id,
         parent.construct_type AS parent_type,
         cc.ddi_slug,
         cc.position,
         cc.branch
        FROM ((public.statements s
          JOIN public.control_constructs cc ON (((s.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcStatement'::text))))
          LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
       ORDER BY s.id;
    |

    execute "DROP VIEW IF EXISTS public.cc_sequences CASCADE;"

    # Recreate cc_sequences with ddi_slug
    execute %Q|
    CREATE VIEW public.cc_sequences AS
    SELECT s.id,
       s.instrument_id,
       s.literal,
       s.created_at,
       s.updated_at,
       cc.label,
       parent.construct_id AS parent_id,
       parent.construct_type AS parent_type,
       cc.ddi_slug,
       cc."position",
       cc.branch,
       links.topic_id
      FROM (((public.sequences s
        JOIN public.control_constructs cc ON (((s.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcSequence'::text))))
        LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
        LEFT JOIN public.links ON (((s.id = links.target_id) AND ((links.target_type)::text = 'CcSequence'::text))))
     ORDER BY s.id;
     |     

    execute "DROP FUNCTION IF EXISTS insert_cc_condition() CASCADE;"    
    execute "DROP FUNCTION IF EXISTS insert_cc_loop() CASCADE;"
    execute "DROP FUNCTION IF EXISTS insert_cc_question() CASCADE;"    
    execute "DROP FUNCTION IF EXISTS insert_cc_sequence() CASCADE;"
    execute "DROP FUNCTION IF EXISTS insert_cc_statement() CASCADE;"     

    execute %Q|    
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
                               ddi_slug,
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
                               new.ddi_slug,
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
                               ddi_slug,
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
                               new.ddi_slug,
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
                               ddi_slug,
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
                               new.ddi_slug,
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
                               ddi_slug,
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
                               new.ddi_slug,
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
                               ddi_slug,
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
                               new.ddi_slug,
                               new.created_at, 
                               new.updated_at
       );
       new.id = sta_id;
       RETURN new;
     END;
     $$;
     | 

     execute %Q|    
      CREATE TRIGGER delete_cc_condition INSTEAD OF DELETE ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.delete_cc_condition();
      CREATE TRIGGER delete_cc_loop INSTEAD OF DELETE ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.delete_cc_loop();
      CREATE TRIGGER delete_cc_question INSTEAD OF DELETE ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.delete_cc_question();
      CREATE TRIGGER delete_cc_sequence INSTEAD OF DELETE ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.delete_cc_sequence();
      CREATE TRIGGER delete_cc_statement INSTEAD OF DELETE ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.delete_cc_statement();
      CREATE TRIGGER insert_cc_condition INSTEAD OF INSERT ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.insert_cc_condition();
      CREATE TRIGGER insert_cc_loop INSTEAD OF INSERT ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.insert_cc_loop();
      CREATE TRIGGER insert_cc_question INSTEAD OF INSERT ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.insert_cc_question();
      CREATE TRIGGER insert_cc_sequence INSTEAD OF INSERT ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.insert_cc_sequence();
      CREATE TRIGGER insert_cc_statement INSTEAD OF INSERT ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.insert_cc_statement();
      CREATE TRIGGER update_cc_condition INSTEAD OF UPDATE ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.update_cc_condition();
      CREATE TRIGGER update_cc_loop INSTEAD OF UPDATE ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.update_cc_loop();
      CREATE TRIGGER update_cc_question INSTEAD OF UPDATE ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.update_cc_question();
      CREATE TRIGGER update_cc_seqeunce INSTEAD OF UPDATE ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.update_cc_sequence();
      CREATE TRIGGER update_cc_statement INSTEAD OF UPDATE ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.update_cc_statement();
    |         
  end

  def down
    execute "DROP VIEW IF EXISTS public.cc_conditions CASCADE;"

    execute %Q|
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
    |    

    execute "DROP VIEW IF EXISTS public.cc_links CASCADE;"

    execute %Q|
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
    |    

    execute "DROP VIEW IF EXISTS public.cc_loops CASCADE;"

    execute %Q|
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
    |

    execute "DROP VIEW IF EXISTS public.cc_questions CASCADE;"

    execute %Q|
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
    |

    execute "DROP VIEW IF EXISTS public.cc_sequences CASCADE;"
    
    execute %Q|
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
    |

    execute "DROP VIEW IF EXISTS public.cc_statements CASCADE;"
    
    execute %Q|
      CREATE VIEW public.cc_statements AS
      SELECT s.id,
         s.instrument_id,
         s.literal,
         s.created_at,
         s.updated_at,
         cc.label,
         parent.construct_id AS parent_id,
         parent.construct_type AS parent_type,
         cc.position,
         cc.branch
        FROM ((public.statements s
          JOIN public.control_constructs cc ON (((s.id = cc.construct_id) AND ((cc.construct_type)::text = 'CcStatement'::text))))
          LEFT JOIN public.control_constructs parent ON ((cc.parent_id = parent.id)))
       ORDER BY s.id;
    |
    
    execute "DROP FUNCTION IF EXISTS insert_cc_condition() CASCADE;"    
    execute "DROP FUNCTION IF EXISTS insert_cc_loop() CASCADE;"
    execute "DROP FUNCTION IF EXISTS insert_cc_question() CASCADE;"    
    execute "DROP FUNCTION IF EXISTS insert_cc_sequence() CASCADE;"
    execute "DROP FUNCTION IF EXISTS insert_cc_statement() CASCADE;"

    execute %Q|    
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
     | 

    execute %Q|    
      CREATE TRIGGER delete_cc_condition INSTEAD OF DELETE ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.delete_cc_condition();
      CREATE TRIGGER delete_cc_loop INSTEAD OF DELETE ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.delete_cc_loop();
      CREATE TRIGGER delete_cc_question INSTEAD OF DELETE ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.delete_cc_question();
      CREATE TRIGGER delete_cc_sequence INSTEAD OF DELETE ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.delete_cc_sequence();
      CREATE TRIGGER delete_cc_statement INSTEAD OF DELETE ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.delete_cc_statement();
      CREATE TRIGGER insert_cc_condition INSTEAD OF INSERT ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.insert_cc_condition();
      CREATE TRIGGER insert_cc_loop INSTEAD OF INSERT ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.insert_cc_loop();
      CREATE TRIGGER insert_cc_question INSTEAD OF INSERT ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.insert_cc_question();
      CREATE TRIGGER insert_cc_sequence INSTEAD OF INSERT ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.insert_cc_sequence();
      CREATE TRIGGER insert_cc_statement INSTEAD OF INSERT ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.insert_cc_statement();
      CREATE TRIGGER update_cc_condition INSTEAD OF UPDATE ON public.cc_conditions FOR EACH ROW EXECUTE FUNCTION public.update_cc_condition();
      CREATE TRIGGER update_cc_loop INSTEAD OF UPDATE ON public.cc_loops FOR EACH ROW EXECUTE FUNCTION public.update_cc_loop();
      CREATE TRIGGER update_cc_question INSTEAD OF UPDATE ON public.cc_questions FOR EACH ROW EXECUTE FUNCTION public.update_cc_question();
      CREATE TRIGGER update_cc_seqeunce INSTEAD OF UPDATE ON public.cc_sequences FOR EACH ROW EXECUTE FUNCTION public.update_cc_sequence();
      CREATE TRIGGER update_cc_statement INSTEAD OF UPDATE ON public.cc_statements FOR EACH ROW EXECUTE FUNCTION public.update_cc_statement();
    |    
    
  end
end
