json.array!(@cc_loops) do |cc_loop|
  json.extract! cc_loop, :id, :loop_var, :start_val, :end_val, :loop_while
  json.url cc_loop_url(cc_loop, format: :json)
end
