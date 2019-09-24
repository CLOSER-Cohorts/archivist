class Importers::TXT::Mapper::TopicV < Importers::TXT::Mapper::Dataset
  def import(options = {})
    variable_ids_to_delete = @object.variables.pluck(:id)
    set_import_to_running
    vars = @object.variables.includes(:questions, :src_variables, :der_variables, :topic)
    @doc.each do |dataset, v, t|
      log :input, "#{dataset},#{v},#{t}"
      if dataset.blank? || v.blank? || t.blank?
        @errors = true
        log :outcome, I18n.t('importers.txt.mapper.topic_v.wrong_number_of_columns', actual_number_of_columns: {a: dataset, b: v, c: t}.compact.count)
        write_to_log
        next
      elsif dataset != @object.instance_name
        @errors = true
        log :outcome, I18n.t('importers.txt.mapper.topic_v.record_invalid_dataset', dataset_from_line: dataset, dataset_from_object: @object.instance_name)
        write_to_log
        next
      end
      if @doc.config[0]&.include? :icase
        var = vars.where('lower(name) = ?', v.downcase).first
      else
        var = vars.find_by_name v
      end
      topic = Topic.find_by_code t
      log :matches, "matched to Variable (#{var}) AND Topic (#{topic})"
      if var.nil? || topic.nil?
        @errors = true
        log :outcome, "Record Invalid as Variable and Topic where not found"
      else
        variable_ids_to_delete.delete(var.id)
        var.topic = topic
        if var.save
          log :outcome, "Record Saved"
        else
          @errors = true
          log :outcome, "Record Invalid : #{var.errors.full_messages.to_sentence}"
        end
      end
      write_to_log
    end
    # Remove all topic links if the variable is not used in the import
    Link.where(target_type: 'Variable', target_id: variable_ids_to_delete).delete_all
    set_import_to_finished
  end
end
