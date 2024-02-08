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

    execute "DROP VIEW IF EXISTS public.cc_sequesnces CASCADE;"
    
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
  end
end
