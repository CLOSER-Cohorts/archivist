json.array!(@collection) do |variable|
  json.extract! variable, :id, :name, :label, :var_type, :dataset_id
  if variable.var_type == 'Normal'
    json.sources variable.questions, :id, :label, :class
  else
    json.sources variable.src_variables, :id, :name, :class
  end
  json.used_bys variable.der_variables, :id, :name, :label, :var_type
  json.topic variable.topic, :id, :code, :name, :parent_id unless variable.topic.nil?
  json.errors variable.errors.full_messages.to_sentence unless variable.valid?
  json.resolved_topic variable.resolved_topic
end
