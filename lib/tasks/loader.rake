desc 'Loads instrument'
task :load_instruments => :environment do
  Dir.chdir 'N:/CLOSER/Studies/XMLs/repo'
  files = Dir.entries(".").reject { |x| x[0,1] == "." }

  files.each do |file|

    if File.exist? file

      im = XML::CADDIES::Importer.new file
      im.parse

    end

  end

end

desc 'Loads dataset'
task :load_datasets => :environment do
  Dir.chdir 'M:/build/datasets'
  files = Dir.entries(".").reject { |x| x[0,1] == "." }

  files.each do |file|

    if File.exist? file

      da = XML::Sledgehammer::Importer.new(file)
      da.parse

    end

  end

end

desc 'Loads a mapping.txt'
task :load_mapping => :environment do
  Dir.chdir 'M:/build/qvlinking'
  files = Dir.entries(".").reject { |x| x[0,1] == "." }

  files.each do |file|

    if File.exist? file
      prefix = file.split('.')[0]
      puts prefix
      i = Instrument.find_by_prefix prefix
      unless i.nil?
        im = TXT::Mapper::Mapping::Importer.new(file, i)
        im.import
      end
    end

  end
end

desc 'Loads instrument_references.json'
task :load_instrument_references, [:path] => [:environment] do |t, args|
  open args.path do |f|
    links = JSON.parse f.read
    links.each do |link|
      begin
        i = Instrument.find_by_prefix link['instrument']
        q = i.question_items.find_by_label link['question']
        instruction = i.instructions.find_by_literal link['instruction']
        if q.nil? || instruction.nil?
          raise
        else
          q.association(:instruction).writer instruction
          q.save!
        end
      rescue
        puts "Instrument: \t" + link['instrument']
        puts "Question: \t" + link['question']
        puts "Instruction: \t" + link['instruction']
      end
    end
  end
end