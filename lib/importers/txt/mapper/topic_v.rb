class Importers::TXT::Mapper::TopicV < Importers::TXT::Mapper::Dataset
  def import(options = {})
    @doc.each do |v, t|
      if @doc.config[0]&.include? :icase
        var = @object.variables.where('lower(name) = ?', v.downcase).first
      else
        var = @object.variables.find_by_name v
      end
      topic = Topic.find_by_code t
      unless var.nil? or topic.nil?
        var.topic = topic
        var.save!
      end
    end
  end
end