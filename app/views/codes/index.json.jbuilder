json.array!(@codes) do |code|
  json.extract! code, :id, :value, :order, :code_list_id, :category_id
end
