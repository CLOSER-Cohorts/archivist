class Importers::TXT::Mapper::TopicV
  def initialize(thing, dataset)
    if thing.is_a? String
      @doc = open(thing) { |f| Importers::TXT::TabDelimited.new(f) }
    else
      document = Document.find thing
      @doc = Importers::TXT::TabDelimited.new document.file_contents
    end
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