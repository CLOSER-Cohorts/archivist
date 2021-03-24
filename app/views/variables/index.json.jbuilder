json.array!(@collection) do |variable|
  json.extract! variable, :id, :name, :label, :var_type, :dataset_id
  if variable.var_type == 'Normal'
    json.sources variable.questions, :id, :label, :class
  else
    json.sources variable.src_variables, :id, :name, :class
  end
  json.used_bys variable.der_variables, :id, :name, :label, :var_type
  if variable.topic.nil?
    json.topic nil
  else
    json.topic variable.topic, :id, :code, :name, :parent_id
  end
  json.errors variable.errors.full_messages.to_sentence unless variable.valid?
  json.resolved_topic variable.resolved_topic
  json.sources_topic variable.question_topics.first
end
