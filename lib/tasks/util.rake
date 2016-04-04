desc 'Clear Archivist\' tmp files (uploads)'
task :clear_tmp do

  directories = [
      'tmp/uploads'
  ]

  directories.each do |directory|
    begin
    Dir.foreach(directory) do |filename|
      next if filename == '.' or filename == '..'

      if (Time.now - File.stat(directory + '/' + filename).mtime).to_i > 86400
        File.delete directory + '/' + filename
      end
    end
    rescue Exception
    end
  end
end