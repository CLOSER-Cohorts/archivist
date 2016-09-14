desc 'Find similar variables'
task :similar_variables => :environment do

  filename = 'C:/CLOSER/Code/archivist/nounlist.txt'

  if File.exist? filename
    f = File.open filename

    nouns = f.read
    f.close

    groups = {}
    total = nouns.lines.count / 100.0
    counter = 0
    nouns.lines.each do |noun|
      vs = Variable.where("label ~*  ?", "[[:<:]]#{noun.strip}[[:>:]]")
      if vs.length > 1
        groups[noun.strip] = vs.collect { |x| {name: x.name, label: x.label, file: x.dataset.filename} }
      end
      counter += 1
      print "\r" + (counter / total).to_int.to_s + "%"
    end

    variables = {}
    groups.each do |key, arr|
      f = File.open "keywords/#{key}.txt", 'w'
      arr.each do |v|
        f.write "#{v[:name]}\t#{v[:label]}\t#{v[:file].sub(/.ddi32.rp.xml/,'')}\n"
        if variables[v[:name]].nil?
          variables[v[:name]] = {label: v[:label], keywords: []}
        end
        variables[v[:name]][:keywords] << key
      end
    end

    f = File.open 'variable-keywords.txt', 'w'
    variables.each do |key, obj|
      f.write key + "\t" + obj[:label] + "\t" + obj[:keywords].join("\t") + "\n"
    end
    f.close
  end
end