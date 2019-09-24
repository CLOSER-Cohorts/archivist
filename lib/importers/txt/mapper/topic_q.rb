class Importers::TXT::Mapper::TopicQ < Importers::TXT::Mapper::Instrument
  def import(options = {})
    cc_question_ids_to_delete = @object.cc_questions.pluck(:id)
    set_import_to_running
    @doc.each do |control_construct_scheme, q, t|
      log :input, "#{control_construct_scheme},#{q},#{t}"
      if control_construct_scheme.blank? || q.blank? || t.blank?
        @errors = true
        log :outcome, I18n.t('importers.txt.mapper.topic_q.wrong_number_of_columns', actual_number_of_columns: {a: control_construct_scheme, b: q, c: t}.compact.count)
        write_to_log
        next
      elsif control_construct_scheme != @object.control_construct_scheme
        @errors = true
        log :outcome, I18n.t('importers.txt.mapper.topic_q.record_invalid_control_construct_scheme', control_construct_scheme_from_line: control_construct_scheme, control_construct_scheme_from_object: @object.control_construct_scheme)
        write_to_log
        next
      end
      qc = @object.cc_questions.find_by_label q
      topic = Topic.find_by_code t
      log :matches, "matched to QuestionContruct(#{qc}) AND Topic (#{topic})"
      if qc.nil? || topic.nil?
        @errors = true
        log :outcome, "Record Invalid as QuestionContruct and Topic where not found"
      else
        qc.topic = topic
        if qc.save
          log :outcome, "Record Saved"
          cc_question_ids_to_delete.delete(qc.id)
        else
          @errors = true
          log :outcome, "Record Invalid : #{qc.errors.full_messages.to_sentence}"
        end
      end
      write_to_log
    end
    Link.where(target_type: 'CcQuestion', target_id: cc_question_ids_to_delete).delete_all
    set_import_to_finished
  end
end
