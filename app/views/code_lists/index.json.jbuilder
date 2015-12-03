json.array!(@code_lists) do |code_list|
  json.extract! code_list, :id, :label
  json.url code_list_url(code_list, format: :json)
end
