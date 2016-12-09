module Importers::TXT::Mapper::TopicV
  def initialize(filepath, dataset)
    @doc = File.open(filepath) { |f| Importers::TXT::TabDelimited.new(f) }
    @dataset = dataset
  end

  def import
    @doc.each do |v, t|
      var = @dataset.variables.find_by_name v
      topic = Topic.find_by_code t
      unless var.nil? or topic.nil?
        var.topic = topic
        var.save!
      end
    end
  end
end