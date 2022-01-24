# frozen_string_literal: true

json.array!(@collection) do |dataset|
  json.extract! dataset, :id, :name, :study, :filename
  json.dvs @dv_counts[dataset.id]
  json.qvs @qv_counts[dataset.id]
  json.variables @var_counts[dataset.id]
  json.instruments dataset.instruments do |instrument|
    json.id instrument.id
    json.prefix instrument.prefix
    json.label instrument.label
  end
end
