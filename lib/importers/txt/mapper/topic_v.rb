class Importers::TXT::Mapper::TopicV < Importers::TXT::Mapper::Dataset
  def import(options = {})
    variable_ids_to_delete = @object.variables.pluck(:id)
    set_import_to_running
    vars = @object.variables.includes(:questions, :src_variables, :der_variables, :topic)
    @doc.each do |v, t|
      log "#{v},#{t} - "
      if @doc.config[0]&.include? :icase
        var = vars.where('lower(name) = ?', v.downcase).first
      else
        var = vars.find_by_name v
      end
      topic = Topic.find_by_code t
      log "matched to Variable (#{var}) AND Topic (#{topic})"
      unless var.nil? or topic.nil?
        variable_ids_to_delete.delete(var.id)
        var.topic = topic
        if var.save
          log "- Record Saved"
        else
          errors = true
          log "- Record Invalid : #{var.errors.full_messages.to_sentence}"
        end
        log '\n'
      end
    end
    # Remove all topic links if the variable is not used in the import
    Link.where(target_type: 'Variable', target_id: variable_ids_to_delete).delete_all
    set_import_to_finished
  end
end
