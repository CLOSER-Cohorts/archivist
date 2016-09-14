HireFire::Resource.configure do |config|
  config.dyno(:in_out_worker) do
    HireFire::Macro::Resque.queue(:in_and_out)
  end
end