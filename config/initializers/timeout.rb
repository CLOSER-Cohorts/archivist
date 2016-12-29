
if ENV["RACK_TIMEOUT_SERVICE_TIMEOUT"]
  rack_timeout_service_timeout = ENV["RACK_TIMEOUT_SERVICE_TIMEOUT"].to_i
else
  rack_timeout_service_timeout = 25
end

Rack::Timeout.service_timeout = rack_timeout_service_timeout
