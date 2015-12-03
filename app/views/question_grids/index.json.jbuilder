json.array!(@question_grids) do |question_grid|
  json.extract! question_grid, :id, :label, :literal, :instruction_id, :vertical_code_list_id, :horizontal_code_list_id, :roster_rows, :roster_label, :corner_label
  json.url question_grid_url(question_grid, format: :json)
end
