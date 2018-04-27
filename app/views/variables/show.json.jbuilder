json.extract! @object, :id, :name, :label, :var_type, :dataset_id
json.type 'Variable'
if @object.var_type == 'Normal'
  json.sources @object.questions, :id, :label, :class
else
  json.sources @object.src_variables, :id, :name, :class
end
json.used_bys @object.der_variables, :id, :name, :label, :var_type
json.topic @object.topic, :id, :code, :name, :parent_id unless @object.topic.nil?
json.strand do
  json.topic @object.strand.topic, :id, :code, :name, :parent_id
  json.good @object.strand.good
end unless @object.strand.topic.nil?
json.suggested_topic @object.get_suggested_topic, :id, :code, :name, :parent_id unless @object.get_suggested_topic.nil?
