desc 'Clear Archivist\'s tmp files (uploads)'
task :clear_task do

  directories = [
      'public/assets',
      'public/assets/templates/**'
  ]

  directories.each do |directory|
    puts directory
    begin
      if directory[-2..-1] == '**'
        recursive = true
        directory = directory[0...-2]
      else
        recursive = false
      end
      Dir.foreach(directory) do |filename|
        next if filename == '.' or filename == '..'
        if File.directory? directory + '/' + filename
          if recursive
            directories << directory + '/' + filename + '/**'
          end
          next
        end

        if (Time.now - File.stat(directory + '/' + filename).mtime).to_i > 86400
          File.delete directory + '/' + filename
        end
      end
    rescue Exception
    end
  end
end

desc 'Perform pre-startup tasks'
task :prepare_to_start => ['clear_task', 'assets:precompile', ] do
  Rails.logger.info 'Pre-startup completed.'
end