json.array!(@collection) do |variable|
  json.extract! variable, :id, :name, :label, :var_type, :dataset_id
  if variable.var_type == 'Normal'
    json.sources variable.questions, :id, :label, :class
  else
    json.sources variable.src_variables, :id, :name, :class
  end
  json.used_bys variable.der_variables, :id, :name, :label, :var_type
  json.topic variable.topic, :id, :code, :name, :parent_id unless variable.topic.nil?
  json.strand_topic variable.get_topic, :id, :code, :name, :parent_id unless variable.get_topic.nil?
  json.suggested_topic variable.get_suggested_topic, :id, :code, :name, :parent_id unless variable.get_suggested_topic.nil?
end
