json.array!(@cc_questions) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type
  json.url cc_question_url(cc_question, format: :json)
end
