class Importers::TXT::Mapper::TopicV < Importers::TXT::Mapper::Dataset
  def import(options = {})
    variable_ids_to_delete = @object.variables.pluck(:id)
    @doc.each do |v, t|
      if @doc.config[0]&.include? :icase
        var = @object.variables.where('lower(name) = ?', v.downcase).first
      else
        var = @object.variables.find_by_name v
      end
      topic = Topic.find_by_code t
      unless var.nil? or topic.nil?
        variable_ids_to_delete.delete(var.id)
        var.topic = topic
        var.save!
      end
    end
    # Remove all topic links if the variable is not used in the import
    Link.where(target_type: 'Variable', target_id: variable_ids_to_delete).delete_all
  end
end
