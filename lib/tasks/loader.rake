desc 'Loads instrument'
task :load_instruments => :environment do
  Dir.chdir ENV['LOAD_PATH']
  files = Dir.entries(".").reject { |x| x[0,1] == "." }

  files.each do |file|

    if File.exist? file

      im = Importers::XML::DDI::Instrument.new file
      im.import

    end

  end

end

desc 'Loads dataset'
task :load_datasets => :environment do
  Dir.chdir ENV['LOAD_PATH']
  files = Dir.entries('.').reject { |x| x[0, 1] == '.' }

  files.each do |file|

    if File.exist? file
      doc = Document.new file: File.open(file)
      doc.save_or_get

      da = Importers::XML::DDI::Dataset.new(doc)
      da.import
      doc.item = da.dataset
      doc.save!

    end

  end

end

desc 'Loads a mapping.txt'
task :load_mapping => :environment do
  Dir.chdir ENV['LOAD_PATH']
  files = Dir.entries(".").reject { |x| x[0,1] == '.' }

  files.each do |file|

    if File.exist? file
      prefix = file.split('.')[0]
      i = Instrument.find_by_prefix prefix
      unless i.nil?
        im = Importers::TXT::Mapper::Mapping.new(file, i)
        im.import
      end
    end

  end
end

desc 'Loads a dv.txt'
task :load_dv => :environment do
  Dir.chdir ENV['LOAD_PATH']
  files = Dir.entries('.').reject { |x| x[0,1] == '.' }

  files.each do |file|

    if File.exist? file
      prefix = file.split('.')[0]
      d = Dataset.find_by_filename prefix + '.ddi32.rp.xml'
      unless d.nil?
        im = Importers::TXT::Mapper::DV.new(file, d)
        im.import
      end
    end

  end
end

desc 'Loads a topic-q.txt'
task :load_topicq => :environment do
  Dir.chdir ENV['LOAD_PATH']
  files = Dir.entries('.').reject { |x| x[0, 1] == '.' }

  files.each do |file|

    if File.exist? file
      prefix = file.split('.')[0]
      i = Instrument.find_by_prefix prefix
      unless i.nil?
        im = Importers::TXT::Mapper::TopicQ.new(file, i)
        im.import
      end
    end

  end
end

desc 'Loads a topic-v.txt'
task :load_topicv => :environment do
  Dir.chdir ENV['LOAD_PATH']
  files = Dir.entries('.').reject { |x| x[0, 1] == '.' }

  files.each do |file|

    if File.exist? file
      prefix = file.split('.')[0]
      d = Dataset.find_by_filename prefix + '.ddi32.rp.xml'
      unless d.nil?
        im = Importers::TXT::Mapper::TopicV.new(file, d)
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
        instruction = i.instructions.find_by_text link['instruction']
        if q.nil? || instruction.nil?
          raise 'One of q or instruction could not be found'
        else
          q.instruction_id = instruction.id
          q.save!
        end
      rescue => e
        puts e.message
        puts "Instrument: \t" + link['instrument']
        puts "Question: \t" + link['question']
        puts "Instruction: \t" + link['instruction']
      end
    end
  end
end