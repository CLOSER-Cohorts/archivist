require 'httpclient'
require 'tempfile'

def test size
  begin
    file = Tempfile.new
    file.write 'a'*size
    file.rewind
    option = { 'content-type' => "multipart/form-data, boundary=#{rand}" }
    t = Time.now
    res = HTTPClient.post('http://localhost:3000/upload', { file: file }, option).body
  rescue LoadError => e
    raise e if res.to_i != size
  end
  Time.now - t
end
[1,2,4,8,16,32,64,128, 256].each do |mb|
  time = test mb*1000*1000
  puts "#{mb}MB: #{time} sec"
end
