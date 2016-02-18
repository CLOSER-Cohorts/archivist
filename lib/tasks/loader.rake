desc 'Loads instrument'
task :load_instruments => :environment do
  Dir.chdir 'M:/bundles'
  folders = Dir.entries(".").reject { |x| x[0,1] == "." }

  folders.each do |folder|

    if File.exist? folder + '/ddi.xml'

      im = XML::Instrument::Importer.new(folder + '/ddi.xml')
      im.parse

    end

  end

end