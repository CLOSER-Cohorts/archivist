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

desc 'To fix labels that violate constrainsts'
task 'fix_labels' => :environment do

  make_unique_duplicates = lambda do |klass|
    klass
        .select(:label, :instrument_id)
        .group(:label, :instrument_id)
        .having('count(*) > 1').map do |x|
      klass.where(
          label: x.label,
          instrument_id: x.instrument_id
      ).to_a
    end.each do |set|
      counter = 0
      set.each do |cc|
        counter += 1
        if cc.label.nil?
          cc.label = 'MISSING LABEL_' + ('i' * counter)
        else
          cc.label = cc.label + '_' + ('i' * counter)
        end
        cc.save!
      end
    end
  end

  make_unique_duplicates.call ControlConstruct
  make_unique_duplicates.call CodeList

  dedupe = lambda do |klass, field|
    klass
        .select(field, :instrument_id)
        .group(field, :instrument_id)
        .having('count(*) > 1').map do |x|
      klass.where(
          field => x[field],
          instrument_id: x.instrument_id
      ).to_a
    end.each do |set|
      Rails.logger.debug set
      base_obj = set.shift
      set.each do |obj|
        klass.reflections.each do |k, r|
          next unless r.macro == :has_many
          obj.send(k).each do |user|
            user
                .association(obj.class.name.underscore.to_sym)
                .writer(base_obj)
            user.save!
          end
        end
        obj.destroy
      end
    end
  end

  dedupe.call Category,     :label
  dedupe.call Instruction,  :text
end

desc 'Perform pre-startup tasks'
task :prepare_to_start => ['clear_task', 'assets:precompile', ] do
  Rails.logger.info 'Pre-startup completed.'
end