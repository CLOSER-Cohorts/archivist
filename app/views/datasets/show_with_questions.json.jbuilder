# frozen_string_literal: true

json.extract! @object, :id, :name, :study, :filename, :doi
json.variables @object.variables.count
json.questions @object.questions, :id, :label, :topic, :resolved_topic
