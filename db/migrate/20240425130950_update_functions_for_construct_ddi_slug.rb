class UpdateFunctionsForConstructDdiSlug < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
          --
          -- Name: update_cc_condition(); Type: FUNCTION; Schema: public; Owner: -
          --

          CREATE OR REPLACE FUNCTION public.update_cc_condition() RETURNS trigger
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
                    ddi_slug    = new.ddi_slug, 
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

          CREATE OR REPLACE FUNCTION public.update_cc_loop() RETURNS trigger
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
                    ddi_slug    = new.ddi_slug, 
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

          CREATE OR REPLACE FUNCTION public.update_cc_question() RETURNS trigger
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
                    ddi_slug    = new.ddi_slug, 
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

          CREATE OR REPLACE FUNCTION public.update_cc_sequence() RETURNS trigger
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
                    ddi_slug    = new.ddi_slug, 
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

          CREATE OR REPLACE FUNCTION public.update_cc_statement() RETURNS trigger
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
                    ddi_slug    = new.ddi_slug, 
                    parent_id   = (SELECT id FROM control_constructs WHERE construct_type = new.parent_type AND construct_id = new.parent_id), 
                    position    = new.position,
                    branch      = new.branch, 
                    updated_at = new.updated_at
            WHERE construct_id = new.id AND construct_type = 'CcStatement';
            RETURN new;
          END;
          $$;
        SQL
      end

      dir.down do
        execute <<~SQL
          --
          -- Name: update_cc_condition(); Type: FUNCTION; Schema: public; Owner: -
          --

          CREATE OR REPLACE FUNCTION public.update_cc_condition() RETURNS trigger
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

          CREATE OR REPLACE FUNCTION public.update_cc_loop() RETURNS trigger
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

          CREATE OR REPLACE FUNCTION public.update_cc_question() RETURNS trigger
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

          CREATE OR REPLACE FUNCTION public.update_cc_sequence() RETURNS trigger
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

          CREATE OR REPLACE FUNCTION public.update_cc_statement() RETURNS trigger
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
        SQL
      end
    end
  end
end
