class Importers::TXT::Mapper::TopicQ < Importers::TXT::Mapper::Instrument
  def import
    @doc.each do |q, t|
      qc = @object.cc_questions.find_by_label q
      topic = Topic.find_by_code t
      unless qc.nil? or topic.nil?
        qc.topic = topic
        qc.save!
      end
    end
  end
end