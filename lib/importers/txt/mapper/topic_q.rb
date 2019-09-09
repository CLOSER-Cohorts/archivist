class Importers::TXT::Mapper::TopicQ < Importers::TXT::Mapper::Instrument
  def import(options = {})
    set_import_to_running
    @doc.each do |q, t|
      log :input, "#{q},#{t}"
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
        else
          @errors = true
          log :outcome, "Record Invalid : #{qc.errors.full_messages.to_sentence}"
        end
      end
      write_to_log
    end
    set_import_to_finished
  end
end
