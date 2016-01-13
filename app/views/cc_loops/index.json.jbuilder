json.array!(@cc_loops) do |cc_loop|
  json.extract! cc_loop, :id, :loop_var, :start_val, :end_val, :loop_while
  json.label cc_loop.label
  json.url cc_loop_url(cc_loop, format: :json)
  json.children cc_loop.children do |child|
    json.id child.construct.id
    json.type child.construct.class.name
  end
end
