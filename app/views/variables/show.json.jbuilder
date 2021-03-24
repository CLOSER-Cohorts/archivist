json.extract! @object, :id, :name, :label, :var_type, :dataset_id
json.type 'Variable'
if @object.var_type == 'Normal'
  json.sources @object.questions, :id, :label, :class
else
  json.sources @object.src_variables, :id, :name, :class
end
json.used_bys @object.der_variables, :id, :name, :label, :var_type
json.topic @object.topic, :id, :code, :name, :parent_id unless @object.topic.nil?
json.resolved_topic @object.resolved_topic
json.sources_topic @object.question_topics.first
json.errors 'Validation failed: ' + @object.errors.full_messages.to_sentence if @object.errors.present?
