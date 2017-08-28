class Importers::TXT::Mapper::TopicQ
  def initialize(thing, instrument)
    if thing.is_a? String
      @doc = open(thing) { |f| Importers::TXT::TabDelimited.new(f) }
    else
      document = Document.find thing
      @doc = Importers::TXT::TabDelimited.new document.file_contents
    end
    @instrument = instrument
  end

  def cancel
  end

  def import
    @doc.each do |q, t|
      qc = @instrument.cc_questions.find_by_label q
      topic = Topic.find_by_code t
      unless qc.nil? or topic.nil?
        qc.topic = topic
        qc.save!
      end
    end
  end
end