json.id @cluster.id
json.strands @cluster.strands do |strand|
  json.id strand.id
  json.good strand.good
  json.members strand.members do |member|
    json.id member.id
    json.type member.class.name
    json.label (member.is_a?(Variable) ? member.name : member.label)
    json.text (member.is_a?(Variable) ? member.label : member.question&.literal)
    json.topic member.topic, :id, :name, :code unless member.topic.nil?
    json.sources member.sources do |source|
      json.id source.id
      json.type source.class.name
      json.interstrand (member.is_a?(CcQuestion) || member.var_type == 'Normal')
    end if member.is_a?(Variable)
    json.level member.level
  end
  json.topic strand.topic, :id, :name, :code unless strand.topic.nil?
end
json.suggested_topic @cluster.suggested_topic, :id, :name, :code unless @cluster.suggested_topic.nil?