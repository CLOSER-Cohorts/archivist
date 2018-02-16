class CreateConstructViews < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
        ALTER TABLE cc_conditions RENAME TO conditions;
        ALTER SEQUENCE cc_conditions_id_seq RENAME TO conditions_id_seq;
        ALTER TABLE cc_loops RENAME TO loops;
        ALTER SEQUENCE cc_loops_id_seq RENAME TO loops_id_seq;
        ALTER TABLE cc_questions RENAME TO questions;
        ALTER SEQUENCE cc_questions_id_seq RENAME TO questions_id_seq;
        ALTER TABLE cc_sequences RENAME TO sequences;
        ALTER SEQUENCE cc_sequences_id_seq RENAME TO sequences_id_seq;
        ALTER TABLE cc_statements RENAME TO statements;
        ALTER SEQUENCE cc_statements_id_seq RENAME TO statements_id_seq;

        CREATE VIEW cc_conditions AS (
          SELECT
          con.id,
          con.instrument_id,
          con.literal,
          con.logic,
          con.created_at,
          con.updated_at,
          cc.label,
          parent.construct_id as parent_id,
          parent.construct_type as parent_type,
          cc.position,
          cc.branch,
          links.topic_id
          FROM conditions AS con
          INNER JOIN control_constructs AS cc
          ON con.id = cc.construct_id AND cc.construct_type = 'CcCondition'
          LEFT OUTER JOIN control_constructs AS parent
          ON cc.parent_id = parent.id
          LEFT OUTER JOIN links
          ON con.id = links.target_id AND links.target_type = 'CcCondition'
          ORDER BY con.id
        );

        CREATE FUNCTION insert_cc_condition()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER insert_cc_condition
        INSTEAD OF INSERT ON cc_conditions
        FOR EACH ROW EXECUTE PROCEDURE insert_cc_condition();

        CREATE FUNCTION update_cc_condition()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER update_cc_condition
        INSTEAD OF UPDATE ON cc_conditions
        FOR EACH ROW EXECUTE PROCEDURE update_cc_condition();

        CREATE FUNCTION delete_cc_condition()
        RETURNS TRIGGER
        AS $$
        BEGIN
        DELETE FROM links WHERE target_id = old.id AND target_type = 'CcCondition';
        DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcCondition';
        DELETE FROM conditions WHERE id = old.id;
        RETURN old;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER delete_cc_condition
        INSTEAD OF DELETE ON cc_conditions
        FOR EACH ROW EXECUTE PROCEDURE delete_cc_condition();

        CREATE VIEW cc_loops AS (
          SELECT
          l.id,
          l.instrument_id,
          l.loop_var,
          l.start_val,
          l.end_val,
          l.loop_while,
          l.created_at,
          l.updated_at,
          cc.label,
          parent.construct_id as parent_id,
          parent.construct_type as parent_type,
          cc.position,
          cc.branch,
          links.topic_id
          FROM loops AS l
          INNER JOIN control_constructs AS cc
          ON l.id = cc.construct_id AND cc.construct_type = 'CcLoop'
          LEFT OUTER JOIN control_constructs AS parent
          ON cc.parent_id = parent.id
          LEFT OUTER JOIN links
          ON l.id = links.target_id AND links.target_type = 'CcLoop'
          ORDER BY l.id
        );

        CREATE FUNCTION insert_cc_loop()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER insert_cc_loop
        INSTEAD OF INSERT ON cc_loops
        FOR EACH ROW EXECUTE PROCEDURE insert_cc_loop();

        CREATE FUNCTION update_cc_loop()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER update_cc_loop
        INSTEAD OF UPDATE ON cc_loops
        FOR EACH ROW EXECUTE PROCEDURE update_cc_loop();

        CREATE FUNCTION delete_cc_loop()
        RETURNS TRIGGER
        AS $$
        BEGIN
        DELETE FROM links WHERE target_id = old.id AND target_type = 'CcLoop';
        DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcLoop';
        DELETE FROM loops WHERE id = old.id;
        RETURN old;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER delete_cc_loop
        INSTEAD OF DELETE ON cc_loops
        FOR EACH ROW EXECUTE PROCEDURE delete_cc_loop();

        CREATE VIEW cc_questions AS (
          SELECT
          q.id,
          q.instrument_id,
          q.question_id,
          q.question_type,
          q.response_unit_id,
          q.created_at,
          q.updated_at,
          cc.label,
          parent.construct_id as parent_id,
          parent.construct_type as parent_type,
          cc.position,
          cc.branch
          FROM questions AS q
          INNER JOIN control_constructs AS cc
          ON q.id = cc.construct_id AND cc.construct_type = 'CcQuestion'
          LEFT OUTER JOIN control_constructs AS parent
          ON cc.parent_id = parent.id
          ORDER BY q.id
        );

        CREATE FUNCTION insert_cc_question()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER insert_cc_question
        INSTEAD OF INSERT ON cc_questions
        FOR EACH ROW EXECUTE PROCEDURE insert_cc_question();

        CREATE FUNCTION update_cc_question()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER update_cc_question
        INSTEAD OF UPDATE ON cc_questions
        FOR EACH ROW EXECUTE PROCEDURE update_cc_question();

        CREATE FUNCTION delete_cc_question()
        RETURNS TRIGGER
        AS $$
        BEGIN
        DELETE FROM links WHERE target_id = old.id AND target_type = 'CcQuestion';
        DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcQuestion';
        DELETE FROM questions WHERE id = old.id;
        RETURN old;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER delete_cc_question
        INSTEAD OF DELETE ON cc_questions
        FOR EACH ROW EXECUTE PROCEDURE delete_cc_question();

        CREATE VIEW cc_sequences AS (
          SELECT
          s.id,
          s.instrument_id,
          s.literal,
          s.created_at,
          s.updated_at,
          cc.label,
          parent.construct_id as parent_id,
          parent.construct_type as parent_type,
          cc.position,
          cc.branch,
          links.topic_id
          FROM sequences AS s
          INNER JOIN control_constructs AS cc
          ON s.id = cc.construct_id AND cc.construct_type = 'CcSequence'
          LEFT OUTER JOIN control_constructs AS parent
          ON cc.parent_id = parent.id
          LEFT OUTER JOIN links
          ON s.id = links.target_id AND links.target_type = 'CcSequence'
          ORDER BY s.id
        );

        CREATE FUNCTION insert_cc_sequence()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER insert_cc_sequence
        INSTEAD OF INSERT ON cc_sequences
        FOR EACH ROW EXECUTE PROCEDURE insert_cc_sequence();

        CREATE FUNCTION update_cc_sequence()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER update_cc_sequence
        INSTEAD OF UPDATE ON cc_sequences
        FOR EACH ROW EXECUTE PROCEDURE update_cc_sequence();

        CREATE FUNCTION delete_cc_sequence()
        RETURNS TRIGGER
        AS $$
        BEGIN
        DELETE FROM links WHERE target_id = old.id AND target_type = 'CcSequence';
        DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcSequence';
        DELETE FROM sequences WHERE id = old.id;
        RETURN old;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER delete_cc_sequence
        INSTEAD OF DELETE ON cc_sequences
        FOR EACH ROW EXECUTE PROCEDURE delete_cc_sequence();

        CREATE VIEW cc_statements AS (
          SELECT
          s.id,
          s.instrument_id,
          s.literal,
          s.created_at,
          s.updated_at,
          cc.label,
          parent.construct_id as parent_id,
          parent.construct_type as parent_type,
          cc.position,
          cc.branch
          FROM statements AS s
          INNER JOIN control_constructs AS cc
          ON s.id = cc.construct_id AND cc.construct_type = 'CcStatement'
          LEFT OUTER JOIN control_constructs AS parent
          ON cc.parent_id = parent.id
          ORDER BY s.id
        );

        CREATE FUNCTION insert_cc_statement()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER insert_cc_statement
        INSTEAD OF INSERT ON cc_statements
        FOR EACH ROW EXECUTE PROCEDURE insert_cc_statement();

        CREATE FUNCTION update_cc_statement()
        RETURNS trigger
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
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER update_cc_statement
        INSTEAD OF UPDATE ON cc_statements
        FOR EACH ROW EXECUTE PROCEDURE update_cc_statement();

        CREATE FUNCTION delete_cc_statement()
        RETURNS TRIGGER
        AS $$
        BEGIN
        DELETE FROM control_constructs WHERE construct_id = old.id AND construct_type = 'CcStatement';
        DELETE FROM statements WHERE id = old.id;
        RETURN old;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER delete_cc_statement
        INSTEAD OF DELETE ON cc_statements
        FOR EACH ROW EXECUTE PROCEDURE delete_cc_statement();
        SQL
      end

      dir.down do
        execute <<~SQL
        DROP VIEW cc_conditions;
        DROP VIEW cc_loops;
        DROP VIEW cc_questions;
        DROP VIEW cc_sequences;
        DROP VIEW cc_statements;

        DROP FUNCTION insert_cc_condition();
        DROP FUNCTION update_cc_condition();
        DROP FUNCTION delete_cc_condition();

        DROP FUNCTION insert_cc_loop();
        DROP FUNCTION update_cc_loop();
        DROP FUNCTION delete_cc_loop();

        DROP FUNCTION insert_cc_question();
        DROP FUNCTION update_cc_question();
        DROP FUNCTION delete_cc_question();

        DROP FUNCTION insert_cc_sequence();
        DROP FUNCTION update_cc_sequence();
        DROP FUNCTION delete_cc_sequence();

        DROP FUNCTION insert_cc_statement();
        DROP FUNCTION update_cc_statement();
        DROP FUNCTION delete_cc_statement();

        ALTER TABLE conditions RENAME TO cc_conditions;
        ALTER SEQUENCE conditions_id_seq RENAME TO cc_conditions_id_seq;
        ALTER TABLE loops RENAME TO cc_loops;
        ALTER SEQUENCE loops_id_seq RENAME TO cc_loops_id_seq;
        ALTER TABLE questions RENAME TO cc_questions;
        ALTER SEQUENCE questions_id_seq RENAME TO cc_questions_id_seq;
        ALTER TABLE sequences RENAME TO cc_sequences;
        ALTER SEQUENCE sequences_id_seq RENAME TO cc_sequences_id_seq;
        ALTER TABLE statements RENAME TO cc_statements;
        ALTER SEQUENCE statements_id_seq RENAME TO cc_statements_id_seq;
        SQL
      end
    end
  end
end
