json.array!(@collection) do |variable|
  json.extract! variable, :id, :name, :label, :var_type, :dataset_id
  if variable.var_type == 'Normal'
    json.sources variable.questions, :id, :label, :class
  else
    json.sources variable.src_variables, :id, :name, :class
  end
  json.used_bys variable.der_variables, :id, :name, :label, :var_type
  json.topic variable.topic, :id, :code, :name, :parent_id unless variable.topic.nil?
  json.strand do
    json.topic do
      json.id = variable.strand.topic.id
      json.code = variable.strand.topic.code
      json.name = variable.strand.topic.name
      json.parent_id = variable.strand.topic.parent_id
    end
    json.good variable.strand.good
  end unless variable.strand.topic.nil?
  json.suggested_topic variable.get_suggested_topic, :id, :code, :name, :parent_id unless variable.get_suggested_topic.nil?
end
