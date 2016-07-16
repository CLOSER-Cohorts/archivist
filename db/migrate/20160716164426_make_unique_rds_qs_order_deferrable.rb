class MakeUniqueRdsQsOrderDeferrable < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE rds_qs
          DROP CONSTRAINT unique_for_rd_order_within_question;
          ALTER TABLE rds_qs
          ADD CONSTRAINT unique_for_rd_order_within_question
          UNIQUE (question_id, question_type, rd_order)
          DEFERRABLE  INITIALLY DEFERRED;
        SQL
      end

      dir.down do
        execute <<-SQL
          ALTER TABLE rds_qs
          DROP CONSTRAINT unique_for_rd_order_within_question;
          ALTER TABLE rds_qs
          ADD CONSTRAINT unique_for_rd_order_within_question
          UNIQUE (question_id, question_type, rd_order);
        SQL
      end
    end
  end
end
