class Importers::TXT::Mapper::TopicV < Importers::TXT::Mapper::Dataset
  def import(options = {})
    variable_ids_to_delete = @object.variables.pluck(:id)
    set_import_to_running
    vars = @object.variables.includes(:questions, :src_variables, :der_variables, :topic)
    @doc.each do |v, t|
      log :input, "#{v},#{t}"
      if @doc.config[0]&.include? :icase
        var = vars.where('lower(name) = ?', v.downcase).first
      else
        var = vars.find_by_name v
      end
      t = '000' if t == '0'
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
