json.extract! @object, :id, :question_id, :question_type, :position, :branch, :response_unit_id
json.label @object.label
json.parent_id @object.parent_id
json.parent_type @object.parent_type
json.base_label @object.base_label
json.response_unit_label @object.response_unit_label
json.variables @object.variables, :id, :name, :label
json.topic @object.topic
json.ancestral_topic @object.get_ancestral_topic, :id, :code, :name, :parent_id unless @object.topic.nil?
json.type 'CcQuestion'
if @object.question_type == 'QuestionGrid'
  json.cols @object.question.horizontal_code_list.codes do |x|
    json.label x.category.label
    json.value x.value
  end
  json.rows @object.question.rows do |y|
    json.label y.try(:category).try(:label)
    json.order y.value
    json.cols do
      json.array! @object.question.max_x.times.collect do | x |
        json.x x + 1
        json.y y.value
        json.variables @object.maps.where(x: x + 1, y: y.value), :variable_id, :x, :y, :variable_name, :variable_label
      end
    end
  end
end
