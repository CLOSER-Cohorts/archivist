json.array!(@cc_loops) do |cc_loop|
  json.extract! cc_loop, :id, :loop_var, :start_val, :end_val, :loop_while, :position
  json.label cc_loop.label
  json.children cc_loop.children do |child|
    json.id child.construct.id
    json.type child.construct.class.name
  end
end
