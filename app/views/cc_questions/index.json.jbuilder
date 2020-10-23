json.array!(@collection) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type, :position, :branch, :response_unit_id
  json.label cc_question.label
  json.variables cc_question.variables, :id, :name, :label
  if cc_question.question_type == 'QuestionGrid'
    json.cols cc_question.question.horizontal_code_list.codes do |x|
      json.label x.category.label
      json.value x.value
    end
    json.rows cc_question.question.rows do |y|
      json.label y.try(:category).try(:label)
      json.order y.value
      json.cols do
        json.array! cc_question.question.max_x.times.collect do | x |
          json.x x + 1
          json.y y.value
          json.variables cc_question.maps.where(x: x + 1, y: y.value), :variable_id, :x, :y, :variable_name, :variable_label
        end
      end
    end
  end
  json.topic cc_question.topic
  json.ancestral_topic cc_question.get_ancestral_topic, :id, :code, :name, :parent_id unless cc_question.topic.nil?
  json.parent_id cc_question.parent_id
  json.parent_type cc_question.parent_type
  json.base_label cc_question.base_label
  json.response_unit_label cc_question.response_unit_label
  json.resolved_topic cc_question.resolved_topic
  json.errors cc_question.errors.full_messages.to_sentence unless cc_question.valid?
end
