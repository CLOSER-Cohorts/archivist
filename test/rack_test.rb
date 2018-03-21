require "rack"
require "rack/test_app" # https://github.com/kwatch/rack-test_app
require "benchmark"

app = -> (env) do
  puts Benchmark.realtime { Rack::Request.new(env).params } # trigger multipart parsing
  [200, {}, []]
end

File.write("file.txt", "a" * 100*1024*1024)

test_app = Rack::TestApp.wrap(app)
test_app.post("/", multipart: {file: File.open("file.txt")})
