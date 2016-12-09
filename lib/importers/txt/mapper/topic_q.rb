class Importers::TXT::Mapper::TopicQ
  def initialize(filepath, instrument)
    @doc = File.open(filepath) { |f| Importers::TXT::TabDelimited.new(f) }
    @instrument = instrument
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